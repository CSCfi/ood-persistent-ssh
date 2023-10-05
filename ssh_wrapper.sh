#!/bin/bash
# REPO VERSION

# TODO: Move this somewhere else?
login_host=$(yq read /etc/ood/config/clusters.d/lumi.yaml 'v2.login.host')

ood_instance=$SLURM_OOD_ENV
tmux_path=/appl/local/ood/$ood_instance/soft/tmux/bin/
export TERM=xterm-256color

if [[ -z "$(echo "$@" | grep '^lumi\|^193\|^uan'  )" ]]; then
    export SLURM_JOB_ID="$(squeue --me --nodelist="$1" --noheader --format="%i" --name='sys/dashboard/sys/ood-persistent-ssh,sys/dashboard/dev/ood-persistent-ssh' | head -n 1)"

    if [[ -n "$SLURM_JOB_ID" ]];then
      # SSH to compute node (persistent)
      /usr/bin/ssh "$login_host" -tt srun --overlap --jobid="$SLURM_JOB_ID" --nodelist="$1" test -f "$tmux_path/tmux" &>/dev/null

      if [[ $? -eq 0 ]];then
          /usr/bin/ssh "$login_host" -tt "cd $HOME ; srun --pty --overlap --jobid='$SLURM_JOB_ID' --nodelist='$1' '$(dirname "$tmux_path")/start_tmux.sh'"
      else
          RED='\033[0;31m'
          NC='\033[0m'

          echo -e "[${RED}INTERNAL ERROR${NC}] tmux binary not found.\n\tNo persistent session created\n\tPlease contact the CSC service desk" >&2
          if [[ -z "$ood_instance" ]];then
              echo "SSH wrapper failed, failed to resolve OOD instance CSC_OOD_ENVIRONMENT empty" | logger
          else
              echo "SSH wrapper failed, executable $tmux_path/tmux does not exist" | logger
          fi
          /usr/bin/ssh "$login_host" -tt "cd $HOME ; srun --pty --overlap --jobid='$SLURM_JOB_ID' --nodelist='$1' '$SHELL'"
      fi
    else
      # SSH to compute node (non-persistent)
      export SLURM_JOB_ID="$(squeue --me --nodelist="$1" --noheader --format="%i" | head -n 1)"
      if [[ -n "$SLURM_JOB_ID" ]];then
        /usr/bin/ssh "$login_host" -tt "cd $HOME ; srun --pty --overlap --jobid='$SLURM_JOB_ID' --nodelist='$1' '$SHELL'"
      else
        echo "No job found on node $1"
      fi
    fi
else
    # SSH to login node
    /usr/bin/ssh $@
fi
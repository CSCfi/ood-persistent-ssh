#!/bin/bash
# REPO VERSION

# TODO: read this from cluster config
login_host="puhti.csc.fi"

if [ "$#" -gt 1 ]; then
  # SSH to login node, directory specified. Adds env -u PROMPT_COMMAND to fix shell app title.
  set -- "${@:1:2}" "${3/exec \$\{SHELL\} -l/exec env -u PROMPT_COMMAND \$\{SHELL\} -l}" "${@:4}"
fi

ood_instance=$SLURM_OOD_ENV
tmux_path=/appl/opt/ood/$ood_instance/soft/tmux/bin/

if [[ -z "$(echo "$1" | grep '^puhti'  )" ]]; then

    node="$(echo "$1" | cut -d'.' -f1)"
    # Job id specified in URL.
    job_id=$(echo "$3" | sed "s#^cd '/\\([[:digit:]]\\+\\).*\$#\\1#; t; q1")
    if [ $? -eq 0 ]; then
      export SLURM_JOB_ID="$job_id"
    else
      export SLURM_JOB_ID="$(squeue --me --nodelist="$node" --noheader --format="%i" --name='sys/dashboard/sys/ood-persistent-ssh,sys/dashboard/dev/ood-persistent-ssh' | head -n 1)"
    fi

    if [[ -n "$SLURM_JOB_ID" ]]; then
      /usr/bin/ssh "$login_host" -tt srun --overlap --jobid="$SLURM_JOB_ID" --nodelist="$node" test -f "$tmux_path/tmux" &>/dev/null
      if [[ $? -eq 0 ]];then
        /usr/bin/ssh "$login_host" -tt "srun --pty --overlap --jobid='$SLURM_JOB_ID' --nodelist='$node' '$(dirname "$tmux_path")/start_tmux.sh'"
      else
          RED='\033[0;31m'
          NC='\033[0m'

          echo -e "[${RED}INTERNAL ERROR${NC}] tmux binary not found.\n\tNo persistent session created\n\tPlease contact the CSC service desk" >&2
          if [[ -z "$ood_instance" ]];then
              echo "SSH wrapper failed, failed to resolve OOD instance CSC_OOD_ENVIRONMENT empty" | logger
          else
              echo "SSH wrapper failed, executable $tmux_path/tmux does not exist" | logger
          fi
          /usr/bin/ssh "$login_host" -tt "env -u PPROMPT_COMMAND srun --pty --overlap --jobid='$SLURM_JOB_ID' --nodelist='$node' '$SHELL'"
      fi
    else
      # SSH to compute node (non-persistent)
      export SLURM_JOB_ID="$(squeue --me --nodelist="$node" --noheader --format="%i" | head -n 1)"
      if [[ -n "$SLURM_JOB_ID" ]];then
        /usr/bin/ssh "$login_host" -tt "env -u PROMPT_COMMAND srun --pty --overlap --jobid='$SLURM_JOB_ID' --nodelist='$node' '$SHELL'"
      else
        echo "No job found on node $1"
      fi
    fi

else
   /usr/bin/ssh $@
fi

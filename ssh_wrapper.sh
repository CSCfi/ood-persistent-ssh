#!/bin/bash
# REPO VERSION

# TODO: read this from cluster config
login_host="roihu-cpu.csc.fi"

if [ "$#" -gt 1 ]; then
  # SSH to login node, directory specified. Adds env -u PROMPT_COMMAND to fix shell app title.
  set -- "${@:1:2}" "${3/exec \$\{SHELL\} -l/exec env -u PROMPT_COMMAND \$\{SHELL\} -l}" "${@:4}"
fi

TMUX_VERSION=3.6b
SSH_CONF="/etc/ssh/ssh_config"

tmux_path="/appl/soft/manual/ood/$SLURM_OOD_ENV/\$(uname -m)/soft/tmux/$TMUX_VERSION/bin"

if [[ -z "$(echo "$1" | grep '^roihu'  )" ]]; then

    node="$(echo "$1" | cut -d'.' -f1)"
    # Job id specified in URL.
    job_id=$(echo "$3" | sed "s#^cd '/\\([[:digit:]]\\+\\).*\$#\\1#; t; q1")
    if [ $? -eq 0 ]; then
      export SLURM_JOB_ID="$job_id"
    else
      export SLURM_JOB_ID="$(squeue --me --nodelist="$node" --noheader --format="%i" --name='sys/dashboard/sys/ood-persistent-ssh,sys/dashboard/dev/ood-persistent-ssh' | head -n 1)"
    fi

    if [[ -n "$SLURM_JOB_ID" ]]; then
      /usr/bin/ssh "$login_host" -F "$SSH_CONF" -tt srun --argos=no --overlap --export=HOME,TERM --jobid="$SLURM_JOB_ID" --nodelist="$node" /bin/test -f "$tmux_path/tmux" &>/dev/null
      if [[ $? -eq 0 ]]; then
        /usr/bin/ssh "$login_host" -F "$SSH_CONF" -tt "srun --argos=no --pty --overlap --export=HOME,TERM --jobid='$SLURM_JOB_ID' --nodelist='$node' /appl/soft/manual/ood/$SLURM_OOD_ENV/common/soft/scripts/start_tmux.sh"
      else
          RED='\033[0;31m'
          NC='\033[0m'

          echo -e "[${RED}INTERNAL ERROR${NC}] tmux binary not found.\n\tNo persistent session created\n\tPlease contact the CSC service desk" >&2
          if [[ -z "$SLURM_OOD_ENV" ]];then
              echo "SSH wrapper failed, failed to resolve OOD instance SLURM_OOD_ENV empty" | logger
          else
              echo "SSH wrapper failed, executable $tmux_path/tmux does not exist" | logger
          fi
          /usr/bin/ssh "$login_host" -F "$SSH_CONF" -tt "env -u PPROMPT_COMMAND srun --argos=no --pty --overlap --export=HOME,TERM --jobid='$SLURM_JOB_ID' --nodelist='$node' '$SHELL'"
      fi
    else
      # SSH to compute node (non-persistent)
      export SLURM_JOB_ID="$(squeue --me --nodelist="$node" --noheader --format="%i" | head -n 1)"
      if [[ -n "$SLURM_JOB_ID" ]];then
        /usr/bin/ssh "$login_host" -F "$SSH_CONF" -tt "env -u PROMPT_COMMAND srun --argos=no --pty --overlap --export=HOME,TERM --jobid='$SLURM_JOB_ID' --nodelist='$node' '$SHELL' -il"
      else
        echo "No job found on node $1"
      fi
    fi

else
   /usr/bin/ssh -F "$SSH_CONF" $@
fi

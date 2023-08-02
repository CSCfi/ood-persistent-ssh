#!/bin/bash
# REPO VERSION

# TODO: Move this somewhere else?
login_host=lumi.csc.fi

ood_instance=$SLURM_OOD_ENV
tmux_path=/appl/local/ood/$ood_instance/soft/tmux/bin/


if [[ -z "$(echo "$@" | grep '^lumi'  )" ]]; then
    export SLURM_JOB_ID="$(squeue --me --nodelist="$*" --noheader --format="%i" --name='sys/dashboard/sys/ood-persistent-ssh,sys/dashboard/dev/ood-persistent-ssh' | head -n 1)"

    /usr/bin/ssh "$login_host" -tt srun --overlap --jobid="$SLURM_JOB_ID" --nodelist="$*" --chdir "$HOME" test -f "$tmux_path/tmux" &>/dev/null

    if [[ $? -eq 0 ]];then
        /usr/bin/ssh "$login_host" -tt srun --pty --overlap --jobid="$SLURM_JOB_ID" --nodelist="$*" --chdir "$HOME" "$(dirname "$tmux_path")/start_tmux.sh"
    else
        RED='\033[0;31m'
        NC='\033[0m'

        echo -e "[${RED}INTERNAL ERROR${NC}] tmux binary not found.\n\tNo persistent session created\n\tPlease contact the CSC service desk" >&2
        if [[ -z "$ood_instance" ]];then
            echo "SSH wrapper failed, failed to resolve OOD instance CSC_OOD_ENVIRONMENT empty" | logger
        else
            echo "SSH wrapper failed, executable $tmux_path/tmux does not exist" | logger
        fi
        /usr/bin/ssh "$login_host" -tt srun --pty --overlap --jobid="$SLURM_JOB_ID" --nodelist="$*" --chdir "$HOME" "$SHELL"
    fi
else
   /usr/bin/ssh $@
fi

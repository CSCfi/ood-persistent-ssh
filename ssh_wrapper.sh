#!/bin/bash
# REPO VERSION
set -x
ood_instance=$SLURM_OOD_ENV
tmux_path=/appl/local/ood/$ood_instance/soft/tmux/bin/

export SLURM_JOB_ID="$(squeue --me --nodelist="$@" --noheader --format="%i" --name='sys/dashboard/sys/ood-persistent-ssh,sys/dashboard/dev/ood-persistent-ssh' | head -n 1)"
export APP_TMP=/dev/shm/$USER/$SLURM_JOB_ID/

cmd="export TMPDIR=/tmp/\$USER/\$SLURM_JOB_ID ; \
test -d /run/nvme/job_\$SLURM_JOB_ID/tmp/ && export TMPDIR=/run/nvme/job_\$SLURM_JOB_ID/tmp; mkdir -p \$TMPDIR ; \
test -f /dev/shm/$USER/\$SLURM_JOB_ID/persist_ssh && \
{ export PATH=\"$tmux_path:\$PATH\" ;  \
    { \
        test -f /tmp/\$USER/\$SLURM_JOB_ID/custom_tmux_conf && export _CSC_TMUX_CONF=\"\" \
        ||\
        export _CSC_TMUX_CONF='-f <(echo -e \"set -g status off\nsetw -g mouse on\"    )'  \
    ;} ; \
    { \
        tmux ls 2>/dev/null && /appl/local/ood/$ood_instance/soft/tmux/time_helper.sh &>/dev/null & tmux attach -t \$SLURM_JOB_ID &>/dev/null \
    ;} \
    || eval \"tmux \$_CSC_TMUX_CONF new-session -s \$SLURM_JOB_ID\" \
;} \
|| bash"
if [[ -z "$(echo "$@" | grep '^lumi'  )" ]]; then

    srun --pty --overlap --nodelist="$@" --jobid="$SLURM_JOB_ID" --chdir "$HOME" test -f $tmux_path/tmux &>/dev/null

    if [[ $? -eq 0 ]];then
        srun --overlap --pty --jobid="$SLURM_JOB_ID" --nodelist="$@" --chdir "$HOME" bash -c "$cmd"
    else
        RED='\033[0;31m'
        NC='\033[0m'

        echo -e "[${RED}INTERNAL ERROR${NC}] tmux binary not found.\n\tNo persistent session created\n\tPlease contact the CSC service desk" >&2
        if [[ -z "$ood_instance" ]];then
            echo "SSH wrapper failed, failed to resolve OOD instance CSC_OOD_ENVIRONMENT empty" | logger
        else
            echo "SSH wrapper failed, executable $tmux_path/tmux does not exist" | logger
        fi
        srun --overlap --pty --jobid="$SLURM_JOB_ID" --nodelist="$@" --chdir "$HOME" $SHELL
    fi
else
   /usr/bin/ssh $@
fi

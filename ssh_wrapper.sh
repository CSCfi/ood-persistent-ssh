#!/bin/bash
# REPO VERSION

ood_instance=$CSC_OOD_ENVIRONMENT
tmux_path=/appl/opt/ood/$ood_instance/soft/tmux/bin/


cmd="export TMPDIR=/tmp/\$USER/\$SLURM_JOB_ID ; \
test -d /run/nvme/job_\$SLURM_JOB_ID/tmp/ && export TMPDIR=/run/nvme/job_\$SLURM_JOB_ID/tmp; \
test -f /tmp/\$USER/\$SLURM_JOB_ID/persist_ssh && \
{ export PATH=\"$tmux_path:\$PATH\" ;  \
    { \
        test -f /tmp/\$USER/\$SLURM_JOB_ID/custom_tmux_conf && export _CSC_TMUX_CONF=\"\" \
        ||\
        export _CSC_TMUX_CONF='-f <(echo -e \"set -g status off\nsetw -g mouse on\"    )'  \
    ;} ; \
    { \
        tmux ls 2>/dev/null && /appl/opt/ood/$ood_instance/soft/tmux/time_helper.sh &>/dev/null & tmux attach -t \$SLURM_JOB_ID &>/dev/null \
    ;} \
    || eval \"tmux \$_CSC_TMUX_CONF new-session -s \$SLURM_JOB_ID\" \
;} \
|| bash"
if [[ ! -f $tmux_path/tmux ]];then
    RED='\033[0;31m'
    NC='\033[0m'

    echo -e "[${RED}INTERNAL ERROR${NC}] tmux binary not found.\n\tNo persistent session created\n\tPlease contact the CSC service desk" >&2
    if [[ -z "$ood_instance" ]];then
        echo "SSH wrapper failed, failed to resolve OOD instance CSC_OOD_ENVIRONMENT empty" | logger 
    else
        echo "SSH wrapper failed, executable $tmux_path/tmux does not exist" | logger
    fi
    /usr/bin/ssh $@ 
elif [[ -z "$(echo "$@" | grep 'puhti'  )" ]]; then 
    /usr/bin/ssh $@ -tt "$cmd"
else
   /usr/bin/ssh $@ 
fi

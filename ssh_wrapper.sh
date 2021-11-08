#!/bin/bash
if [[ -z "$(echo "$@" | grep 'puhti'  )" ]]; then 
    /usr/bin/ssh $@ -tt 'test -f /tmp/$USER/$SLURM_JOB_ID/persist_ssh && { { tmux ls 2>/dev/null && tmux attach -t $SLURM_JOB_ID  ;} || tmux -f <(echo "set -g status off") new-session -s $SLURM_JOB_ID ;} || bash'
else
   /usr/bin/ssh $@ 
fi

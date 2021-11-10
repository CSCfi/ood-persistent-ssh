#!/bin/bash

function check_tty(){
    tmux_tty=$(ps -fu $USER | grep tmux | grep  "$SLURM_JOB_ID" | grep -v "grep" | grep pts | awk '{ print $6 }')
    if [[ ! -z "$tmux_tty" ]];then                                                                               
        tmux set-option -g display-time 600000
        time_msg="$(date --date "@$(($end_time-$current_time))" "+%d days %H hours and %M minutes")"
        tmux display-message " INFO: $time_msg left of job runtime"
        return 0
    else
        return 1
    fi
}

# epoch
end_time=$(cat /tmp/$USER/$SLURM_JOB_ID/shell_job_end_time) 
current_time=$(date +%s)

# Check a total of 4 times then give up
sleep 1
check_tty && exit 0
sleep 2
check_tty && exit 0
sleep 4
check_tty && exit 0
sleep 8
check_tty && exit 0

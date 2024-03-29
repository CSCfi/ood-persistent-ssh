#!/bin/bash

function check_tty(){
    tmux_tty="$(ps -fu $USER | grep tmux | grep  "$SLURM_JOB_ID" | grep -v "grep" | grep pts | awk '{ print $6 }')"
    if [[ ! -z "$tmux_tty" ]];then                                                                               
        tmux set-option -g display-time 600000
        secs="$(( $end_time - $current_time))"
        d=$(( secs / 86400 ))
        h=$(( (secs / 3600 ) % 24 ))
        m=$(( ( secs / 60 ) % 60 ))
        s=$(( secs % 60 ))
        time_msg="$d days $h hours and $m minutes"
        while IFS= read -r tx ; do
            tmux display-message -c /dev/$tx " INFO: $time_msg left of job runtime"
        done <<< "$tmux_tty"
        return 0
    else
        return 1
    fi
}

# epoch
export APP_TMP=/dev/shm/$USER/$SLURM_JOB_ID/
end_time=$(cat $APP_TMP/shell_job_end_time) 
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

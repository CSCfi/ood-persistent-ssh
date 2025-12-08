#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export TMPDIR=/tmp/$USER/$SLURM_JOB_ID
test -d "/run/nvme/job_$SLURM_JOB_ID/tmp/" && export TMPDIR=/run/nvme/job_$SLURM_JOB_ID/tmp
export TMUX_TMPDIR=$TMPDIR/tmux

export PATH="$SCRIPT_DIR/bin:$PATH"
{
    tmux has-session -t "$SLURM_JOB_ID" 2>/dev/null && "$SCRIPT_DIR/time_helper.sh" &>/dev/null & tmux attach -t "$SLURM_JOB_ID" &>/dev/null
} \
|| eval "tmux -N new-session -s $SLURM_JOB_ID"


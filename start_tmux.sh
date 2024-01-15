#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export TMPDIR=/tmp/$USER/$SLURM_JOB_ID

test -d "/run/nvme/job_$SLURM_JOB_ID/tmp/" && export TMPDIR=/run/nvme/job_$SLURM_JOB_ID/tmp
mkdir -p "$TMPDIR"
mkdir -p $TMPDIR/tmux
chmod og-rwx -R $TMPDIR/tmux
export TMUX_TMPDIR=$TMPDIR/tmux


test -f "/dev/shm/$USER/$SLURM_JOB_ID/persist_ssh" && \
{
  export PATH="$SCRIPT_DIR/bin:$PATH"
  test -f "/dev/shm/$USER/$SLURM_JOB_ID/custom_tmux_conf" && export _CSC_TMUX_CONF="" \
  || export _CSC_TMUX_CONF="-f <(echo -e \"set -g status off\nsetw -g mouse on\")"
  {
      tmux ls 2>/dev/null && "$SCRIPT_DIR/time_helper.sh" &>/dev/null & tmux attach -t "$SLURM_JOB_ID" &>/dev/null
  } \
  || eval "tmux $_CSC_TMUX_CONF new-session -s $SLURM_JOB_ID"
} || bash


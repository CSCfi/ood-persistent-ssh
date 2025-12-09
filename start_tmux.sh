#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export TMPDIR=/tmp/$USER/$SLURM_JOB_ID
test -d "/run/nvme/job_$SLURM_JOB_ID/tmp/" && export TMPDIR=/run/nvme/job_$SLURM_JOB_ID/tmp
export TMUX_TMPDIR="$TMPDIR/tmux"
mkdir -p "$TMUX_TMPDIR"
chmod og-rwx -R "$TMUX_TMPDIR"

test -f "$TMPDIR/custom_tmux_conf" && export _CSC_TMUX_CONF="" || export _CSC_TMUX_CONF="-f <(echo -e \"set -g status off\nsetw -g mouse on\nset -g exit-empty off\nset -g exit-unattached off\nset -g set-titles on\nset -g set-titles-string 'Compute node shell (#h)'\")"

export PATH="/appl/opt/ood/test/soft/tmux/bin:$PATH"
{
    tmux has-session -t "$SLURM_JOB_ID" 2>/dev/null && "$SCRIPT_DIR/time_helper.sh" &>/dev/null & tmux attach -t "$SLURM_JOB_ID" &>/dev/null
} \
|| eval "tmux $_CSC_TMUX_CONF new-session -s $SLURM_JOB_ID"

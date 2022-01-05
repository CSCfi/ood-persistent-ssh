# OOD Persistent SSH
Application and ssh wrapper for enabling persistent ssh shells on compute nodes using tmux.

The app requires ood-util and ood-initializers to work.

## About
The app creates a file `/tmp/$USER/$SLURM_JOB_ID/persist_ssh` on the node that it launches on and just provides the user a link to the OOD shell app (`/pun/sys/shell/ssh/<node>`).
When the user tries to SSH to the node through OOD the `OOD_SSH_WRAPPER` script (`ssh_wrapper.sh`) checks if a file `/tmp/$USER/$SLURM_JOB_ID/persist_ssh` exists on the target.
If it exists a tmux session is resumed, otherwise a new session is started.


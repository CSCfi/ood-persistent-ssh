

(cd $TMPDIR && wget https://github.com/tmux/tmux/releases/download/3.1c/tmux-3.1c.tar.gz && tar -xvf tmux-3.1c.tar.gz && cd tmux-3.1c  && ./configure --prefix=/appl/opt/ood/$1/soft/tmux && make && make install  )
rm $TMPDIR/tmux-3.1c.tar.gz
rm -r $TMPDIR/tmux-3.1c

ln -fns ../../../deps/util/forms/form_validated.js form.js
cp ssh_wrapper.sh ../../../deps/ssh_wrapper
cp time_helper.sh /appl/opt/ood/$1/soft/tmux
chmod +x /appl/opt/ood/$1/soft/tmux/time_helper.sh
chmod +x ../../../deps/ssh_wrapper

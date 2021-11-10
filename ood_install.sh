

(cd $TMPDIR && wget https://github.com/tmux/tmux/releases/download/3.2a/tmux-3.2a.tar.gz && tar -xvf tmux-3.2a.tar.gz && cd tmux-3.2a  && ./configure --prefix=/appl/opt/ood/$1/soft/tmux && make && make install  )
rm $TMPDIR/tmux-3.2a.tar.gz
rm -r $TMPDIR/tmux-3.2a

ln -fns ../../../deps/util/forms/form_validated.js form.js
cp ssh_wrapper.sh ../../../deps/ssh_wrapper
cp time_helper.sh /appl/opt/ood/$1/soft/tmux
chmod +x /appl/opt/ood/$1/soft/tmux/time_helper.sh
chmod +x ../../../deps/ssh_wrapper

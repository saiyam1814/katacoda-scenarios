import os,pty,subprocess,select,time
master,slave=pty.openpty()
p=subprocess.Popen(['kubectl','-n','book-cks-host','exec','-it','shell-target','--','sh','-c','echo book-shell-event'],stdin=slave,stdout=slave,stderr=slave)
os.close(slave)
try:
 deadline=time.time()+3
 while p.poll() is None and time.time()<deadline:
  if select.select([master],[],[],.1)[0]:
   try:os.read(master,4096)
   except OSError:break
 if p.wait(timeout=1):raise RuntimeError('TTY exec failed')
finally:os.close(master)

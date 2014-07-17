import subprocess, time

while subprocess.check_output(['ss','--tcp','-a']).find(b':8090') == -1:
    time.sleep(1)
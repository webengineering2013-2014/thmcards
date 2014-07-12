import subprocess, time

while subprocess.check_output(['ss','--tcp','-a']).find(b'*:couchdb') == -1:
    time.sleep(1)
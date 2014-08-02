
# Author: Roman Domnich ( workaddr [ at ] yahoo.de )

import subprocess, time

while subprocess.check_output(['ss','--tcp','-a']).find('*:couchdb') == -1:
    time.sleep(1)
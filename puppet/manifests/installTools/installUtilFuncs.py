
# Author: Roman Domnich ( workaddr [ at ] yahoo.de )

import sys

def edgeString(s):
    hBorder = '#'*(len(s)+4)
    return  hBorder + '\n# ' + s + ' #\n' + hBorder

def immediateSysStdoutWrite(s):
    sys.stdout.write(s)
    sys.stdout.flush()
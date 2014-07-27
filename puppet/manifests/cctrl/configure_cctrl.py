#!/usr/bin/env python2

import sys, pexpect, re, cctrlUtilFuncs

CC_TIMEOUT = 420

cctrl = cctrlUtilFuncs.CloudControl()

cctrlKeyUploader = pexpect.spawn('cctrluser key.add', timeout=CC_TIMEOUT)
cctrlKeyUploader.logfile_read = sys.stdout

cctrlKeyUploader.expect(re.compile('type.+?yes.+?to.+?generate.*?:', re.IGNORECASE))
cctrlKeyUploader.sendline('Yes')

for i in range(2):
    cctrlKeyUploader.expect(re.compile('enter.+?passphrase.*?:', re.IGNORECASE))
    cctrlKeyUploader.sendline()

cctrl.reactToCctrlToolResponse(cctrlKeyUploader)
cctrl.reactToCctrlToolResponse(pexpect.spawn('cctrlapp ' + cctrl.APPNAME + ' create nodejs', timeout=CC_TIMEOUT))

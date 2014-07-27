import pexpect, sys

class CloudControl:
    def __init__(self):
        f = open('/vagrant/CLOUDCONTROL.CREDENTIALS')
        self.EMAIL, self.PASSWORD, self.APPNAME = [s.strip() for s in f if len(s.strip()) > 0]
        f.close()

    def reactToCctrlToolResponse(self, p):
        p.logfile_read = sys.stdout
        
        while True:
            response = p.expect(['Email.*?:', 'Password.*?:', pexpect.EOF])
            
            if response == 0:
                p.sendline(self.EMAIL)
            elif response == 1:
                p.sendline(self.PASSWORD)
            else:
                p.close()
                break

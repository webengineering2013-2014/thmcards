#!/usr/bin/env python2

import pexpect, subprocess, platform, re


child = pexpect.spawn('vncserver')


child.expect('Password:')

child.sendline('vncserver')

child.expect('Verify:')

child.sendline('vncserver')

child.expect(pexpect.EOF)


child.close()


subprocess.check_call(['vncserver', '-kill', \
    re.search(platform.node()+'(:\d+)', child.before, re.MULTILINE).group(1)])
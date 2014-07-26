#!/usr/bin/env python2

import os, subprocess, re, sys, shutil

from installUtilFuncs import edgeString

fDEVNULL = open(os.devnull, 'wb')

os.chdir(os.path.expanduser('~'))

sys.stdout.write('\n' + edgeString('ALL ACTIONS WILL HAPPEN IN ' + os.getcwd() + ' .') + '\n\n')

JMETER_URL = 'https://www.apache.org/dist/jmeter/'

jmeterBinaryName = re.search('apache-jmeter-(.+?)\.tgz', \
                   subprocess.check_output(['curl', \
                   JMETER_URL+'binaries/'], stderr=fDEVNULL)).group()

exts = ('', '.asc', '.md5', '.sha')

for ext in exts:
    f = open(jmeterBinaryName+ext, 'wb')

    sys.stdout.write('\n' + edgeString('DOWNLOADING ' + jmeterBinaryName + ext + ' ...') + '\n\n')
    subprocess.check_call(['curl', JMETER_URL + 'binaries/' + jmeterBinaryName + ext], stdout=f)

    f.close()

f = open('KEYS', 'wb')

sys.stdout.write('\n' + edgeString('DOWNLOADING KEYS ...') + '\n\n')
subprocess.check_call(['curl', JMETER_URL + 'KEYS'], stdout=f)

f.close()

sys.stdout.write('\n' + edgeString('IMPORTING KEYS ...') + '\n\n')
subprocess.check_call(['gpg', '--import', 'KEYS'])

sys.stdout.write('\n' + edgeString('VERIFYING SIGNATURE OF ' + jmeterBinaryName + ' ...') + '\n\n')
subprocess.check_call(['gpg', '--verify', jmeterBinaryName + exts[1]])

sys.stdout.write('\n' + edgeString('VERIFYING MD5- & SHA1-CHECKSUMS OF ' + jmeterBinaryName + ' ...') + '\n')
subprocess.check_call(['md5sum', '-c', jmeterBinaryName + exts[2]], stdout=fDEVNULL)
subprocess.check_call(['sha1sum', '-c', jmeterBinaryName + exts[3]], stdout=fDEVNULL)

fDEVNULL.close()

sys.stdout.write('\n' + edgeString('UNPACKING ' + jmeterBinaryName + ' ...') + '\n')
subprocess.check_call(['tar', 'xzf', jmeterBinaryName])

jmeterDirectoryName = jmeterBinaryName.split('.tgz')[0]

sys.stdout.write('\n' + edgeString('RENAMING ' + jmeterDirectoryName + '/ TO apache-jmeter/') + '\n')
os.rename(jmeterDirectoryName, 'apache-jmeter')

sys.stdout.write('\n' + edgeString('JMETER INSTALLED. CLEANING UP ...') + '\n\n')

for ext in exts:
    os.remove(jmeterBinaryName + ext)

os.remove('KEYS')
shutil.rmtree('.gnupg')
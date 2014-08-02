#!/usr/bin/env python2

# Author: Roman Domnich ( workaddr [ at ] yahoo.de )

import subprocess, os, sys, zipfile, StringIO

import xml.etree.ElementTree as ET, re

from installUtilFuncs import edgeString, immediateSysStdoutWrite

def getNodesByXPath(xpath, prefix):
    fDEVNULL = open(os.devnull, 'wb')
    root = ET.fromstring(subprocess.check_output(['curl', 'https://selenium-release.storage.googleapis.com/?delimiter=/&prefix='+prefix], stderr=fDEVNULL))
    fDEVNULL.close()

    namespace = '}'.join(root.tag.split('}')[:-1])+'}'

    for k in root.findall(xpath%((namespace,)*xpath.count('%s'))):
        yield k.text


os.chdir(os.path.expanduser('~'))


maxVersion = -1

for k in getNodesByXPath('.//%sCommonPrefixes//%sPrefix', ''):
    if re.match('\d+\.', k):
        version = int(re.sub('\D+', '', k))
        if version > maxVersion:
            maxVersion = version
            maxVersionString = k

maxVersion = -1

for k in getNodesByXPath('.//%sContents//%sKey', maxVersionString):
    m = re.match(maxVersionString + 'selenium-java-(.+)\.', k)
    
    if m:
        version = int(re.split('\D+', m.group(1).replace('.', ''))[0])
        if version > maxVersion:
            maxVersion = version
            maxVersionString2 = k


seleniumZipFileURL = 'https://selenium-release.storage.googleapis.com/' + maxVersionString2

immediateSysStdoutWrite('\n' + edgeString('DOWNLOADING '+maxVersionString2.replace(maxVersionString, '', 1) + ' TO A FILE IN VOLATILE MEMORY ...') + '\n\n')

stringStream = StringIO.StringIO(subprocess.check_output(['curl', seleniumZipFileURL]))
seleniumZipFile = zipfile.ZipFile(stringStream)

rootObjectCount = 0
for k in seleniumZipFile.infolist():
    if k.filename.endswith('/') and (k.filename.count('/') == 1):
        rootObjectCount += 1
        rootDir = k.filename
    if k.filename.count('/') == 0:
        rootObjectCount += 1

if rootObjectCount == 1:
    immediateSysStdoutWrite('\n' + edgeString('EXTRACTING TO ' + os.getcwd() + '/selenium') + '\n\n')
    seleniumZipFile.extractall()
else:
    sys.stderr.write('!! ERROR: '+seleniumZipFileURL+' has an unexpected internal structure. It should contain exactly one root directory and no root files. !!\n\n')
    sys.stderr.flush()

seleniumZipFile.close()
stringStream.close()

if rootObjectCount == 1:
    os.rename(rootDir, 'selenium')


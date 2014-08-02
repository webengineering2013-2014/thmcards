#!/usr/bin/env python2

# Author: Roman Domnich ( workaddr [ at ] yahoo.de )

import pexpect, subprocess, platform, re, time, os, shutil


JENKINS_HOME = os.path.expanduser('~')

JAVA_CLASSPATH = '.'


def ensureJenkinsIsReady():
    while True:
        journalctl = pexpect.spawn("su -c 'journalctl -b -o cat -n 1 --no-pager -u jenkins'")
        
        journalctl.expect(r'Passwor\w:')
        journalctl.sendline('vagrant')
        journalctl.expect(pexpect.EOF)

        journalctl.close()

        if (journalctl.before.rfind('Jenkins is fully up and running') != -1) and \
        (subprocess.check_output(['ss', '--tcp', '-an']).find(':8090') != -1):
            break
        else:
            time.sleep(1)


def buildJavaClasspath(rootdir):
    global JAVA_CLASSPATH
    
    for dirpath, dirnames, filenames in os.walk(rootdir):
        for filename in filenames:
            if os.path.splitext(filename)[1].lower() == '.jar':
                JAVA_CLASSPATH += ':' + os.path.abspath(dirpath) + '/' + filename


def getVNCDisplayNumber(vncserverOutput):
    return re.search(platform.node() + '(:\d+)', vncserverOutput, re.MULTILINE).group(1)


ensureJenkinsIsReady()


buildJavaClasspath(JENKINS_HOME + '/selenium')
buildJavaClasspath('/usr/share/java')


os.chdir('configureJenkins')


subprocess.check_call(['javac', '-cp', JAVA_CLASSPATH, 'jenkins/config/ConfigJenkins.java', '-d', JENKINS_HOME])

subprocess.check_call(['javac', '-cp', JAVA_CLASSPATH, 'jenkins/pipeline/InstallPipeline.java', '-d', JENKINS_HOME])


os.chdir(JENKINS_HOME)


vncserver = pexpect.spawn('vncserver')


vncserver.expect('Password:')

vncserver.sendline('vagrant')

vncserver.expect('Verify:')

vncserver.sendline('vagrant')

vncserver.expect(pexpect.EOF)


vncserver.close()


newEnviron = os.environ.copy()
newEnviron['DISPLAY'] = getVNCDisplayNumber(vncserver.before)

configureJenkins = pexpect.spawn('java -cp ' + JAVA_CLASSPATH + ' jenkins.config.ConfigJenkins', env=newEnviron, timeout=420)

configureJenkins.expect('JENKINSCONFIGURED')


ensureJenkinsIsReady()


subprocess.check_call(['vncserver', '-kill', newEnviron['DISPLAY']])
configureJenkins.close()

newEnviron['DISPLAY'] = getVNCDisplayNumber(subprocess.check_output(['vncserver'], stderr=subprocess.STDOUT))


configureJenkins = pexpect.spawn('java -cp ' + JAVA_CLASSPATH + ' jenkins.pipeline.InstallPipeline', env=newEnviron, timeout=420)

configureJenkins.expect('PIPELINEINSTALLED')


subprocess.check_call(['vncserver', '-kill', newEnviron['DISPLAY']])
configureJenkins.close()

shutil.rmtree('jenkins')

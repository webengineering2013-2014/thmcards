
# Author: Roman Domnich ( workaddr [ at ] yahoo.de )

Exec {
    cwd => "/vagrant/puppet/manifests",
    path => "/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/core_perl",
    timeout => "0"
}


class thmcards {

    exec { "update-pacman-mirrorlist" :
        command => 'bash update_pacman_mirrorlist.sh'
    }

    # this step is necessary in order to prevent package conflicts
    # even though it costs a lot of time
    exec { "update-system" :
        command => "pacman --noconfirm -Syyu",
        
        require => Exec["update-pacman-mirrorlist"]
    }

    # couchdb and nodejs are needed by the app
    # jenkins is used for the app's maintenance pipeline
    # firefox is used inside the pipeline in order to test the app but is also used by selenium in order to configure jenkins
    # tigervnc provides a virtual display for firefox; it is needed for Jenkins Xvnc plugin as well as for selenium.
    # imagemagick is used by Jenkins in order to create screenshots of the virtual display using import
    # python2-pexpect provides an easier control over interactive programs than subprocess.
    $installtools = [ "couchdb", "firefox", "jenkins", "junit", "nodejs", "python2-pip", "git", "python2-pexpect", "tigervnc", "imagemagick" ]

    package { [ $installtools ] :
        require => Exec['update-system']
    }

    # install the cloudcontrol.com - client programs
    exec { "install-cctrl" :
        command => "pip2 install cctrl",

        require => Package[ $installtools ]
    }

    # fix a problem with Jenkins Python Plugin, which tries to call python instead of python2
    file { 'create-python2-link' :
        path    => '/usr/bin/python',
        ensure  => 'link',
        target  => '/usr/bin/python2',

        require => Exec['install-cctrl']
    }

    # makes couchdb listen on all network interfaces
    exec { "configure-couchdb" :
        command => "python2 configure_couchdb.py",

        require => File['create-python2-link']
    }

    service { "init-couchdb":
        name       => "couchdb",
        ensure     => "running",
        enable     => true,
        hasrestart => true,
        hasstatus  => true,

        require => Exec['configure-couchdb']
    }

    # ensure that couchdb is running in order to create the couchdb view in the next step
    exec { "check-couchdb-access" :
        command => "python2 check_couchdb_access.py",

        require => Service['init-couchdb']
    }

    exec { "create-views-in-couchdb" :
        cwd     => "/vagrant",
        command => "python2 createviews.py",

        require => Exec['check-couchdb-access']
    }

    file { 'create-motd':
        path   => '/etc/motd',
        ensure => present,
        backup => false,
        group  => 'root',
        mode   => 'u=rw,go=r',
        owner  => 'root',
        source => 'puppet:///modules/motddir/motd',

        require => Exec['create-views-in-couchdb']
    }

    exec { "npm-install" :
        cwd     => "/vagrant",
        command => "npm install",

        require => File['create-motd']
    }

    exec { "npm-install-forever" :
        command => "npm -g install forever",

        require => Exec['npm-install']
    }

    # download and install the newest version of jmeter to jenkins home directory
    exec { "install-jmeter" :
        command => 'su -c installTools/install-jmeter.py jenkins',
        logoutput => true,

        require => Exec['npm-install-forever']
    }

    # download and install the newest version of selenium to jenkins home directory
    exec { "install-selenium" :
        command => 'su -c installTools/install-selenium.py jenkins',
        logoutput => true,

        require => Exec['install-jmeter']
    }
    
    # look at the file WARNING.2 in the root directory of this repository
    exec { 'configure-cctrl' :
        command => 'su -c cctrl/configure_cctrl.py jenkins',
        logoutput => true,
        
        require => Exec['install-selenium']
    }

    service { "init-jenkins":
        name       => "jenkins",
        ensure     => "running",
        enable     => true,
        hasrestart => true,
        hasstatus  => true,

        require => Exec['configure-cctrl']
    }

    # use selenium, firefox and tigervnc in order to configure jenkins
    # ( adjust Jenkins settings for the master-node, install the necessary plugins,
    #   install the pipeline stages and create the pipeline view. )
    exec { "configure-jenkins" :
        command => "su -c configureJenkins/configure.py jenkins",

        require => Service['init-jenkins']
    }

}

include thmcards
Exec {
    cwd => "/vagrant/puppet/manifests",
    path => "/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/core_perl",
    timeout => "0"
}


class thmcards {

    exec { "update-pacman-mirrorlist" :
        command => 'bash update_pacman_mirrorlist.sh'
    }

    $installtools = [ "couchdb", "firefox", "jenkins", "junit", "nodejs", "python2-pip", "git", "python2-pexpect", "tigervnc" ]

    package { [ $installtools ] :
        require => Exec['update-pacman-mirrorlist']
    }

    exec { "install-cctrl" :
        command => "pip2 install cctrl",

        require => Package[ $installtools ]
    }

    # fix a problem with Jenkins Python Plugin, which tries to call python
    # instead of python2
    file { 'create-python2-link' :
        path    => '/usr/bin/python',
        ensure  => 'link',
        target  => '/usr/bin/python2',

        require => Exec['install-cctrl']
    }

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

    exec { "install-jmeter" :
        command => 'su -c installTools/install-jmeter.py jenkins',
        logoutput => true,

        require => Exec['npm-install-forever']
    }

    exec { "install-selenium" :
        command => 'su -c installTools/install-selenium.py jenkins',
        logoutput => true,

        require => Exec['install-jmeter']
    }

    exec { "configure-vncserver" :
        command => 'su -c ./configure_vncserver.py jenkins',

        require => Exec['install-selenium']
    }
    
    exec { 'configure-cctrl' :
        command => 'su -c cctrl/configure_cctrl.py jenkins',
        logoutput => true,
        
        require => Exec['configure-vncserver']
    }

    service { "init-jenkins":
        name       => "jenkins",
        ensure     => "running",
        enable     => true,
        hasrestart => true,
        hasstatus  => true,

        require => Exec['configure-cctrl']
    }

    exec { "check-jenkins-access" :
        command => "python2 check_jenkins_access.py",

        require => Service['init-jenkins']
    }

}

include thmcards
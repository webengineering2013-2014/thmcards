Exec {
    cwd => "/vagrant/puppet/manifests",
    path => "/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/core_perl",
    timeout => "0"
}


class thmcards {
    
    exec { "update-pacman-mirrorlist" :
        command => 'bash update_pacman_mirrorlist.sh'
    }

    $installtools = [ "nodejs", "couchdb", "python2", "jenkins" ]
    
    package { [ $installtools ] :
        require => Exec['update-pacman-mirrorlist']
    }
    
    exec { "configure-couchdb" :
        command => "python2 configure_couchdb.py",

        require => Package[ $installtools ]
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
    
    service { "init-jenkins":
        name       => "jenkins",
        ensure     => "running",
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
        
        require => Exec['create-views-in-couchdb']
    }

    exec { "check-jenkins-access" :
        command => "python2 check_jenkins_access.py",

        require => Service['init-jenkins']
    }
    
    exec { "npm-install" :
        cwd     => "/vagrant",
        command => "npm install",

        require => Exec['check-jenkins-access']
    }
    
    exec { "npm-install-forever" :
        command => "npm -g install forever",

        require => Exec['npm-install']
    }
    
    file { 'create-motd':
        path   => '/etc/motd',
        ensure => present,
        backup => false,
        group  => 'root',
        mode   => 'u=rw,go=r',
        owner  => 'root',
        source => 'puppet:///modules/motddir/motd',
        
        require => Exec['npm-install-forever']
    }

}

include thmcards
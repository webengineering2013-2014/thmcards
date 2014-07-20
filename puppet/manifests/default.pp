Exec {
    cwd => "/vagrant/puppet/manifests",
    path => "/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/core_perl",
    timeout => "0"
}


class thmcards {
    
    exec { "update-pacman-mirrorlist" :
        command => 'bash update_pacman_mirrorlist.sh'
    }

    # libcups satisfies a dependency needed by jenkins
    $installtools = [ "nodejs", "couchdb", "python2", "jre7-openjdk", "libcups" ]
    
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
    
    exec { "npm-install" :
        cwd     => "/vagrant",
        command => "npm install",

        require => Exec['create-views-in-couchdb']
    }
    
    exec { "npm-install-forever" :
        command => "npm -g install forever",

        require => Exec['npm-install']
    }

    file { "create-jenkins-directory" :
        path   => "/home/vagrant/jenkins",
        ensure => "directory",
        owner  => "vagrant",
        group  => "users",
        
        require => Exec['npm-install-forever']
    }
    
    file { 'create-motd':
        path   => '/etc/motd',
        ensure => present,
        backup => false,
        group  => 'root',
        mode   => 'u=rw,go=r',
        owner  => 'root',
        source => 'puppet:///modules/motddir/motd',
        
        require => File['create-jenkins-directory']
    }

}

include thmcards
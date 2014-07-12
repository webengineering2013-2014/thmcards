Exec {
    cwd => "/vagrant/manifests",
    path => "/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/core_perl",
    timeout => "0"
}


class thmcards {
    
    $installtools = [ "nodejs", "couchdb", "python2", "python3" ]

    package { [ $installtools ]: }
    
    exec { "configure-couchdb" :
        command => "python3 configure_couchdb.py",

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
        command => "python3 check_couchdb_access.py",

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
    
    exec { "append-to-motd" :
        command => 'python2 append_to_motd.py',

        require => Exec['npm-install-forever']
    }

}

include thmcards
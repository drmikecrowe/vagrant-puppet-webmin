class webmin {
    $base = "webmin_1.700_all.deb"
    $url = "http://prdownloads.sourceforge.net/webadmin/"
    $archive = "/root/$base"
    $installed = "/etc/webmin/version"

    $dependencies = [
        "libapt-pkg-perl",
        "libnet-ssleay-perl",
        "libauthen-pam-perl",
        "libio-pty-perl",
        "apt-show-versions",
    ]

    package{$dependencies: ensure => installed}->
    exec { "DownloadWebmin":
        cwd     => "/root",
        command => "/usr/bin/wget $url$base",
        creates => $archive,
    }

    exec { "InstallWebmin":
        cwd     => "/root",
        command => "/usr/bin/dpkg -i $archive",
        creates => $installed,
        require => Exec["DownloadWebmin"],
        notify  => Service[webmin],
    }

    service { webmin:
        ensure   => running,
        require  => Exec["InstallWebmin"],
        provider => init;
    }
}

class virtualmin {

    exec { "DownloadVirtualmin":
        cwd     => "/root",
        command => "/usr/bin/wget http://software.virtualmin.com/gpl/scripts/install.sh",
        require => [
            Exec["InstallWebmin"],
            Package['mysql-server']
        ],
        creates => '/root/install.sh',
    }->
    exec { "InstallVirtualmin":
        cwd     => "/root",
        command => "/bin/sh /root/install.sh",
        creates => '/etc/virtualmin-license',
        require => Exec["DownloadVirtualmin"],
        timeout  => 7200,
    }

    service { Virtualmin:
        ensure   => running,
        require  => Exec["InstallVirtualmin"],
        provider => init,
    }
}
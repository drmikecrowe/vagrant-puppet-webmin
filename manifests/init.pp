class webmin {
    #monit::package { "webmin": }

    $base = "webmin_1.680_all.deb"
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

    service { webmin:
        ensure   => running,
        require  => Exec["InstallWebmin"],
        provider => init;
    }

    exec { "InstallWebmin":
        cwd     => "/root",
        command => "/usr/bin/dpkg -i $archive",
        creates => $installed,
        require => Exec["DownloadWebmin"],
        notify  => Service[webmin],
    }

}

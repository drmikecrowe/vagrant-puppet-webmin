class Virtualmin {
    $base = "Virtualmin_1.700_all.deb"
    $url = "http://prdownloads.sourceforge.net/webadmin/"
    $archive = "/root/$base"
    $installed = "/etc/Virtualmin/version"

    $dependencies = [
        "libapt-pkg-perl",
        "libnet-ssleay-perl",
        "libauthen-pam-perl",
        "libio-pty-perl",
        "apt-show-versions",
    ]

    package{$dependencies: ensure => installed}->
    exec { "DownloadVirtualmin":
        cwd     => "/root",
        command => "/usr/bin/wget $url$base",
        creates => $archive,
    }

    service { Virtualmin:
        ensure   => running,
        require  => Exec["InstallVirtualmin"],
        provider => init;
    }

    exec { "InstallVirtualmin":
        cwd     => "/root",
        command => "/usr/bin/dpkg -i $archive",
        creates => $installed,
        require => Exec["DownloadVirtualmin"],
        notify  => Service[Virtualmin],
    }
}

class virtualmin {

    exec { "DownloadVirtualmin":
        cwd     => "/root",
        command => "/usr/bin/wget $url$base",
        creates => $archive,
    }

    service { Virtualmin:
        ensure   => running,
        require  => Exec["InstallVirtualmin"],
        provider => init;
    }

    exec { "InstallVirtualmin":
        cwd     => "/root",
        command => "/bin/sh install.sh",
        creates => '/etc/virtualmin',
        require => Exec["DownloadVirtualmin"]
    }
}
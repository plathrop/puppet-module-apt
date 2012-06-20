# Introduction
Puppet module providing configuration for the apt package manager and
apt-related resources. Currently only tested on Ubuntu.

Install into `puppet module_path/apt`

The module will automatically update your apt index every Puppet run.

# Basic Usage
To add sources, use `apt::source`:

```puppet
apt::source { 'site-testing-lenny':
    enable => true,
    url    => 'http://example.com/debian';
}
```

PPAs can be added using `apt::ppa`:

```puppet
apt::ppa { 'ppa:txwikinger/php5.2':
    ensure => 'present',
}
```

To add trusted apt keys, use `apt::key`:

```puppet
apt::key { '1BB943DB':
    ensure    => present,
    keyserver => 'keyserver.ubuntu.com'
}
```

To add apt preferences to `/etc/apt/preferences.d`:

```puppet
apt::preference { 'backports-pin':
    ensure => present,
    source => 'puppet:///modules/site/backport-pin',
}
```

# Apt Archives
To set up the directory structure and config file for an apt package
archive, you can use the `apt::archive` defined type:

```puppet
class { 'apt::archive::setup': }

apt::archive { '/repository':
    ensure => present,
    dists  => ['lucid'],
    owner  => 'www-data',
}
```

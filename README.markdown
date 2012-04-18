Puppet module for configuring the apt package manager. Currently only
tested on Ubuntu.

Install into `puppet module_path/apt`

The module will automatically update your apt index every Puppet run.

To add sources, use `apt::source`:

```puppet
apt::source { 'site-testing-lenny':
  enable => true,
  url => 'http://example.com/debian';
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

Puppet module for configuring apt/aptitude package managers. Currently
only tested on Debian and Ubuntu.

Install into your <puppet module_path>/apt

Set `$apt_provider` to `apt` or `aptitude` depending on which you wish
to use. The module will automatically update your apt index
every Puppet run. To over-ride the default `sources.list`, add
`sources.list.${fqdn}` or `sources.list.site` to
`modules/site/files/apt`.

To add sources, use `apt::source` like so::

  apt::source {
    'site-testing-lenny':
      enable => true,
      url => 'http://example.com/debian';
  }

To add trusted apt keys, use `apt::key` like so::

  apt::key {
    '1BB943DB':
      ensure    => present,
      keyserver => 'keyserver.ubuntu.com'
  }

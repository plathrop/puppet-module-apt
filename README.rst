Puppet module for configuring apt/aptitude package managers. Currently
only tested on Debian.

Install into your <puppet module_path>/apt

Set $apt_provider to "apt" or "aptitude" respectively. The module will
automatically update your apt/aptitude index every Puppet run. To
over-ride the default sources.list, add "sources.list.$fqdn" or
"sources.list.site" to "modules/site/files/apt".

To add sources, use apt::source like so::

  apt::source {
    "site-testing-lenny":
      enable => true,
      url => "http://example.com/debian";
  }

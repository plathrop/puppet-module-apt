class apt {
  File {
    owner => root,
    group => root
  }

  $apt_provider = $apt_provider ? {
    "" => "apt-get",
    /^apt(-get)?$/ => "apt-get",
    /^aptitude$/ => "aptitude"
  }

  $codename = $lsbdistcodename ? {
    "" => $operatingsystem,
    default => $lsbdistcodename
  }

  exec {
    "apt::update-index":
      command => "/usr/bin/${apt_provider} update",
      logoutput => on_failure,
      user => root;
  }

  file {
    "/etc/apt":
      mode => 0755,
      ensure => directory;
    "/etc/apt/sources.list":
      mode => 0644,
      source => ["puppet:///modules/site/apt/sources.list.fqdn",
                 "puppet:///modules/site/apt/sources.list.site",
                 "puppet:///modules/apt/sources.list.${codename}"],
      notify => Exec["apt::update-index"];
  }

  @file {
    "/etc/apt/sources.list.d":
      mode => 0755,
      ensure => directory;
  }
}

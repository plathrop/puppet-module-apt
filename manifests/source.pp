define apt::source($enable=true, $deb_src=true, $url="", $dist="",
                   $sections="main contrib non-free", $key="") {
  include apt

  $distribution = $dist ? {
    "" => $name,
    default => $dist,
  }

  $keyexec = $key ? {
    '': "noop",
    default: "import-key"
  }

  $list=inline_template("deb $url $distribution $sections
<% if deb_src -%>
deb-src $url $distribution $sections
<% end %>")

  exec {
    "import-key":
      path => "/usr/bin",
      user => root,
      command => "echo ${key} | apt-key add -";

    "noop":
      path => "/bin",
      command => "true";
  }

  file {
    "/etc/apt/sources.list.d/${name}.list":
      require => Exec[$keyexec],
      mode => 0644,
      content => $enable ? {
        true => "${list}",
        default => undef,
      },
      ensure => $enable ? {
        false => absent,
        default => present,
      },
      notify => Exec["apt::update-index"];
  }
}

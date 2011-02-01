define apt::source($enable=true, $deb_src=true, $url="", $dist="",
                   $sections="main contrib non-free", $key="") {
  include apt

  $distribution = $dist ? {
    "" => $name,
    default => $dist,
  }

  $list=inline_template("deb $url $distribution $sections
<% if deb_src -%>
deb-src $url $distribution $sections
<% end %>")

  if $key != "" {
    exec {
      "import-${url}-key":
        path => ["/bin", "/usr/bin"],
        user => root,
        command => "echo ${key} | apt-key add -";
    }
  }

  file {
    "/etc/apt/sources.list.d/${name}.list":
      require => $key ? {
        '' => undef,
        default => Exec["import-${url}-key"]
      },
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

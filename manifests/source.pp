define apt::source($enable=true, $deb_src=true, $url="", $dist="",
                   $sections="main contrib non-free") {
  include apt

  $distribution = $dist ? {
    "" => $name,
    default => $dist,
  }

  $list=inline_template("deb $url $distribution $sections
<% if deb_src -%>
deb-src $url $distribution $sections
<% end %>")

  file {
    "/etc/apt/sources.list.d/${name}.list":
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

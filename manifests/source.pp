define apt::source($enable=true, $url="", $dist="", $sections="main contrib non-free")
{
  include apt

  $distribution = $dist ? {
    "" => $name,
    default => $dist,
  }

  file {
    "/etc/apt/sources.list.d/${name}.list":
      content => $enable ? {
        true => "deb $url $distribution $sections\ndeb-src $url $distribution $sections\n",
        default => undef,
      },
      ensure => $enable ? {
        false => absent,
        default => present,
      },
      notify => Exec["apt::update-index"];
  }
}

define apt::key($ensure=present, $keyserver='keyserver.ubuntu.com') {
  if $ensure in [ present, absent ] {
    $ensure_real = $ensure
  } else {
    fail('Valid values for ensure: present or absent')
  }

  if $ensure_real == present {
    exec {
      "apt::key::${name}":
        command => "/usr/bin/apt-key adv --recv-keys --keyserver ${keyserver} ${name}",
        unless  => "/usr/bin/apt-key list | /bin/grep ${name}"
    }
  }

  if $ensure_real == absent {
    exec {
      "apt::key::${name}":
        command => "/usr/bin/apt-key del ${name}",
        onlyif  => "/usr/bin/apt-key list | /bin/grep ${name}"
    }
  }
}

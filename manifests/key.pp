### -*- coding: utf-8 -*-
###
### © 2011,2012 Paul Lathrop
### © 2010 Digg, Inc.
### Author: Paul Lathrop <paul@tertiusfamily.net>
###
###
### = Defined type: apt::key
###
###   Defined type for apt repository/package signing keys. Adds the
###   specified key to the local apt keyring.
###
### == Parameters:
###
###  [$ensure] Whether to add or remove the key. One of 'present' or
###            'absent'. Defaults to 'present'. 'absent' only works if
###            $id is specified.
###
###  [$url] The URL to download the key from. Used when you want to
###         download the key via HTTP. If set, $id and $keyserver are
###         ignored. Defaults to $name.
###
###  [$id] The ID of the key. Defaults to $name.
###
###  [$keyserver] The keyserver to download the specified key ID
###               from. Defaults to 'keyserver.ubuntu.com'
### 
### == Actions:
###
###   - Download the key via HTTP/Keyserver.
###
###   - Add the key to the apt keyring via the apt-key command.
###
### == Requires:
###
###   - The 'curl' command must be installed on the local system.
###
### == Example Usage:
###
### apt::key { '1BB94FFF':
###     ensure    => present,
###     keyserver => 'keyserver.example.com'
### }
### 
define apt::key(
    $ensure    = present,
    $url       = false,
    $id        = false,
    $keyserver = 'keyserver.ubuntu.com'
) {
    #######################
    ### Sanity Checking ###
    #######################
    if ! ($ensure in [ present, absent ]) {
        fail('Valid values for ensure: present or absent')
    }

    ##########################
    ### Internal Variables ###
    ##########################
    $_url = $url ? {
        false   => $name,
        default => $url,
    }
    
    $_id = $id ? {
        false   => $name,
        default => $id,
    }

    $_apt_key   = '/usr/bin/apt-key'
    $_check_key = "/usr/bin/apt-key list | /bin/grep ${_id}"

    if $url {
        ### Replace spaces with underscores
        $_key_fname   = regsubst("/tmp/apt_key.${name}", '/\s/', '_', 'G', 'U')
        ### Download the key URL and stash it in $_key_fname
        $_fetch_cmd   = "/usr/bin/curl -s -f -o ${_key_fname} ${_url}"
        ### apt-key add <fname> addes the key from <fname> to the apt
        ### keyring.
        $_action      = "add ${_key_fname}"
        ### If adding the key fails, we'll want to delete the fetched
        ### key so that we trigger it again next puppet run. We're
        ### using the existence of the key file to indicate
        ### success. Cheap and hackish, but Good Enough.
        $_extra       = "|| /bin/rm ${_key_fname}"
        ### If we're fetching the key from a URL, we only want to
        ### import it if we haven't already. Using the existence of
        ### the file and a refreshonly parameter to accomplish this.
        $_refreshonly = true
        ### If we don't know the ID, we can't check if it was
        ### imported. /bin/false always fails, so the import will
        ### always run when triggered.
        $_unless      = $id ? {
            false   => "/bin/false",
            default => $_check_key,
        }
    } else {
        ### apt-key adv --recv-keys downloads the key from a keyserver
        ### and adds it to the apt keyring.
        $_action      = "adv --keyserver ${keyserver} --recv-keys ${_id}"
        ### We *have* to have the ID, so we can always check if it was
        ### imported.
        $_unless      = $_check_key
        ### Since we have the ID, no need to use the jank 'file
        ### exists' test - we can run this exec anytime the unless
        ### parameter indicates.
        $_refreshonly = false
    }

    $_cmd = "${_apt_key} ${_action} ${extra}"

    if $ensure == present {
        ### Fetch the key from the URL, save locally.
        if $url {
            exec {"apt fetch key ${name}":
                command => $_fetch_cmd,
                creates => $_key_fname,
                notify  => Exec["apt add key ${name}"],
            }
        }

        ### Import the key.
        exec { "apt add key ${name}":
            command     => $_cmd,
            unless      => $_unless,
            refreshonly => $_refreshonly,
        }
    }

    if $ensure == absent {
        if $id {
            exec { "apt::key::${name}":
                command => "${_apt_key} del ${_id}",
                onlyif  => "${_apt_key} list | /bin/grep ${_id}"
            }
        } else {
            fail("Cannot set absent on 'ensure': no 'id' specified. apt::key[${name}]")
        }
    }
}

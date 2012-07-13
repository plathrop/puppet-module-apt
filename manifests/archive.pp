### -*- coding: utf-8 -*-
###
### © 2012 Krux Digital, Inc. See manifests/archive/LICENSE.md for
### details.
###
### Author: Paul Lathrop <paul@krux.com>
###
###
### = Defined Type: apt::archive
###
###   Defined type for apt package repositories. Creates
###   apt-ftparchive configuration file(s) and the package repository
###   directory structure.
###
### == Parameters:
###
###  [$name] The base directory of the package repository, or a unique
###          name for the repository, if $base_dir is set.
###
###  [$dists] Array of distributions to provide packages for.
###
###  [$sections] Array of 'sections' to create in the
###              repository. Defaults to ["main"].
###
###  [$architectures] Array of architectures to provide packages
###                   for. Defaults to ["i386", "amd64", "all",
###                   "source"]
###
###  [$ensure] Whether to create or delete the package repository. One
###            of 'present' or 'absent'. Defaults to 'present'.
###
###  [$owner] Owner of the package repository directory and
###           contents. Defaults to 'root'.
###
###  [$group] Group of the package repository directory and
###           contents. Defaults to 'root'.
###
###  [$mode] Permissions for the package repository and
###          contents. Defaults to '0644' (remember that Puppet always
###          sets the execute bit on directories.)
###
###  [$base_dir] The base directory of the package
###              repository. Defaults to $name.
###
###  [$keyid] ID of a GPG key. This key will be used to sign the
###           release metadata. The key must be installed in the
###           GPG keychain of $owner. The key *must not* be protected
###           by a passphrase. See http://bit.ly/MnisxJ for
###           instructions on how to generate a signing subkey for
###           this purpose. You should strongly consider setting an
###           expiration for this subkey. The public key will be
###           exported to the root of the archive as
###           'repo.key.asc'. If this parameter is not provided, the
###           release metadata will not be signed.
###
###  [$gpghome] GnuPG home directory. Defaults to the default for the
###             gpg command (usually ~/.gnupg).
###
### == Actions:
###
###   - Create the directory structure of the package repository.
###
###   - Generate a configuration file for apt-ftparchive.
###
###   - Run apt-ftparchive to generate the repository metadata.
###
###   - Optionally, sign the repository metadata.
###
###   - Optionally, export the public part of the key used to sign the
###     repository metadata.
###
### == Requires:
###
###   - Class['apt::archive::setup']
###
define apt::archive (
    $dists,
    $sections      = ["main"],
    $architectures = ["i386", "amd64", "all", "source"],
    $ensure        = present,
    $owner         = 'root',
    $group         = 'root',
    $mode          = '0644',
    $base_dir      = false,
    $keyid         = false,
    $gpghome       = false
) {
    #######################
    ### Sanity checking ###
    #######################
    if ! ($ensure in ['present', 'absent']) {
        fail('Valid values for ensure: present, absent')
    }

    ##########################
    ### Internal Variables ###
    ##########################
    $_base_dir = $base_dir ? {
        false   => $name,
        default => $base_dir
    }

    $_dir_ensure = $ensure ? {
        present => 'directory',
        absent  => 'absent'
    }

    $_gpghome = $gpghome ? {
        false   => '',
        default => "--homedir ${gpghome}",
    }

    $_archive_conf = "${_base_dir}/archive.conf"

    ### Top-level directories
    $_cache_dir      = "${_base_dir}/cache"
    $_dists_base_dir = "${_base_dir}/dists"
    $_pool_base_dir  = "${_base_dir}/pool"
    $_top_dirs       = [$_base_dir, $_cache_dir, $_dists_base_dir, $_pool_base_dir]

    ### Per-{dist,section,architecture} directories
    $_dist_dirs = apt_archive_dist_dirs($_dists_base_dir, $dists, $sections, $architectures)
    $_pool_dirs = apt_archive_pool_dirs($_pool_base_dir, $sections)

    ######################################
    ### Create the directory structure ###
    ######################################
    file { $_top_dirs:
        ensure  => $_dir_ensure,
        owner   => $owner,
        group   => $group,
        mode    => $mode,
        recurse => true,
        purge   => false,
    }

    file { $_dist_dirs:
        ensure  => $_dir_ensure,
        owner   => $owner,
        group   => $group,
        mode    => $mode,
        recurse => true,
        purge   => false,
    }

    # Use checksum => mtime here to help performance by not
    # checksumming the entire contents of the directory (this may be
    # an out-dated habit)
    file { $_pool_dirs:
        ensure   => $_dir_ensure,
        checksum => mtime,
        owner    => $owner,
        group    => $group,
        mode     => $mode,
        recurse  => true,
        purge    => false,
    }

    ######################################
    ### Create the configuration files ###
    ######################################
    file { $_archive_conf:
        ensure  => $ensure,
        content => template('apt/archive.conf.erb'),
        owner   => $owner,
        group   => $group,
        mode    => $mode,
    }

    ### Prepend the archive name to each release to prevent duplicate
    ### definition problems.
    $_releases = split(inline_template("<%= dists.map { |dist| '${name}.' + dist }.join(',') %>"), ',')
    apt::archive::release { $_releases:
        ensure        => $ensure,
        repository    => $_base_dir,
        sections      => $sections,
        architectures => $architectures,
        owner         => $owner,
        group         => $group,
        mode          => $mode,
        gpghome       => $gpghome,
        require       => File[$_pool_dirs],
    }

    ######################################
    ### Create the repository metadata ###
    ######################################
    exec { "apt-ftparchive generate ${_base_dir}":
        command     => "/usr/bin/apt-ftparchive generate ${_archive_conf}",
        user        => $owner,
        refreshonly => true,
        require     => Class['apt::archive::setup'],
        subscribe   => File[$_archive_conf],
    }

    if $keyid {
        $_pubkey_fname = "${_base_dir}/repo.key.asc"
        exec { "gpg export public key for ${name}":
            command => "/usr/bin/gpg ${_gpghome} --output ${_pubkey_fname} --export --armor ${keyid}",
            user    => $owner,
            creates => $_pubkey_fname,
        }
    }
}

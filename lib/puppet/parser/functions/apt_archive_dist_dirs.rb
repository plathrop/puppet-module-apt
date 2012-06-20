### -*- coding: utf-8 -*-
###
### © 2012 Krux Digital, Inc. See LICENSE.md for details.
### Author: Paul Lathrop <paul@krux.com>
###
###

def arch_dirname(arch)
  ['all', 'source'].include?(arch) && arch || 'binary-' + arch
end

module Puppet::Parser::Functions
  newfunction(:apt_arch_dist_dirs, :type => :rvalue) do |args|
    base_dir = args[0] + 'dists/'
    dists = args[1]
    sections = args[2]
    architectures = args[3]
    dists.map {|dist|
      sections.map {|section|
        architectures.map {|arch|
          [base_dir, dist, section, arch_dirname(arch)].join(File::SEPARATOR)
        }
      }
    }.flatten
  end
end

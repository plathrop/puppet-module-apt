define 'apt::ppa', :ensure do
  include 'apt'

  command = "/usr/bin/add-apt-repository #{@name}"
  _, team, ppa = @name.split(/[:\/]/,3)

  dist = scope.lookupvar('::lsbdistcodename')
  creates = "/etc/apt/sources.list.d/#{team}-#{ppa}-#{dist}.list"

  package 'python-software-properties', :ensure => 'present'

  case @ensure
  when 'present'
    create_resource('exec', command, {
        :creates => creates,
        :require => ['Package[python-software-properties]'],
        :notify  => ['Exec[apt::update-index]']
      })
  when 'absent'
    create_resource('file', creates, {
        :ensure  => 'absent'
      })
  else
    fail('Valid values for ensure: present or absent')
  end
end

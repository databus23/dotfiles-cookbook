default['dotfiles']['bootstrap_archive'] = 'https://dl.dropboxusercontent.com/u/3603498/dotfiles.zip'
default['dotfiles']['repository']        = 'https://github.com/databus23/dotfiles.git'
default['dotfiles']['user']              = 'vagrant'
default['dotfiles']['user_home']         = ::File.join(platform?('windows') ? '/Users' : '/home'  , node['dotfiles']['user'])
default['dotfiles']['dir']               = ::File.join node['dotfiles']['user_home'], 'dotfiles'
default['dotfiles']['vim_path']          = 'C:\vim\vim74'


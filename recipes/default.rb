if platform? 'windows'
  include_recipe "vim-windows"
else
  include_recipe "vim"
  include_recipe "git"
end

remote_file "#{Chef::Config[:file_cache_path]}/dotfiles.zip" do
  source node['dotfiles']['bootstrap_archive']
  not_if { File.exists? node['dotfiles']['dir'] } 
end

if platform? 'windows'
  windows_zipfile 'dotfiles' do
    path node['dotfiles']['user_home'] 
    source "#{Chef::Config[:file_cache_path]}/dotfiles.zip"
    not_if { File.exists? node['dotfiles']['dir'] } 
  end
else
  package 'unzip'
  execute "unzip dotfiles" do
    user node['dotfiles']['user']
    cwd node['dotfiles']['user_home']
    command "unzip #{Chef::Config[:file_cache_path]}/dotfiles.zip"
    not_if { File.exists? node['dotfiles']['dir'] }
  end
end

git 'dotfiles' do 
  user node['dotfiles']['user'] unless platform? 'windows'
  revision 'master'
  repository node['dotfiles']['repository'] 
  #checkout_branch 'master' #need chef >11.10 for that
  destination node['dotfiles']['dir']
  #enable_submodules true #already done in install.bat
  action :sync
end

if platform? 'windows'
  windows_batch "install dotfiles" do
    cwd node['dotfiles']['dir']
    code "set VIM_EXE_DIR=#{node['dotfiles']['vim_path']} & install.bat"
    subscribes :run, "git[dotfiles]"
    subscribes :run, "windows_zipfile[dotfiles]"
    action :nothing
  end
  env "BUNDLER_EDITOR" do
    action :create
    value "#{node['dotfiles']['vim_path'].gsub('\\','/')}/gvim.exe"
  end
else

  execute "install dotfiles" do
    cwd node['dotfiles']['dir']
    environment({
      'HOME' => node['dotfiles']['user_home'],
      'USER' => node['dotfiles']['user']
    })
    user node['dotfiles']['user']
    command "./install.sh -f"
    action :nothing
    subscribes :run, "execute[unzip dotfiles]"
    subscribes :run, "git[dotfiles]"
  end
  
end

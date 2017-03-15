#
# Cookbook:: scholarsphere_web
# Recipe:: deploy
#
# Copyright:: 2017, The Ketosis, All Rights Reserved.

#
# deploy user and directories

include_recipe 'common_library::deploy'

%w(/opt/heracles /dlt).each do |dir_name|
    directory dir_name do
        owner 'root'
        group 'root'
        mode 0o755
        action :create
    end
end

template "#{node[:deploy][:home]}/.bashrc" do
    source 'bashrc.erb'
    owner 'deploy'
    group 'deploy'
    mode '0644'
end

template "#{node[:deploy][:home]}/.bash_profile" do
    source 'bash_profile.erb'
    owner 'deploy'
    group 'deploy'
    mode '0644'
end

directory "#{node[:deploy][:home]}/.ssh" do
    owner 'deploy'
    group 'deploy'
    mode '2755'
    action :create
end

template "#{node[:deploy][:home]}/.ssh/config" do
    source 'ssh_config.erb'
    owner 'deploy'
    group 'deploy'
    mode '0644'
end

template "#{node[:deploy][:home]}/.ssh/authorized_keys" do
    source 'authorized_keys.erb'
    owner 'deploy'
    group 'deploy'
    mode '0600'
end

template "#{node[:deploy][:home]}/.ssh/id_github_rsa.pub" do
    source 'id_github_rsa.pub.erb'
    owner 'deploy'
    group 'deploy'
    mode '0644'
end

#
# application directories
directory "#{node[:deploy][:home]}/#{node[:application]}" do
    owner 'deploy'
    group 'deploy'
    mode '0775'
    action :create
end

directory "#{node[:deploy][:home]}/#{node[:application]}/shared" do
    owner 'deploy'
    group 'deploy'
    mode '0775'
    action :create
end

directory "#{node[:deploy][:home]}/#{node[:application]}/shared/log" do
    owner 'deploy'
    group 'deploy'
    mode '0775'
    action :create
end

link "#{node[:deploy][:home]}/#{node[:application]}/shared/config" do
    to "/#{node[:application]}/config_#{node[:environment]}/#{node[:application]}"
end


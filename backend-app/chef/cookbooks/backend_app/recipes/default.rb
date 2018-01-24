#
# Cookbook:: backend_app
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
apt_update 'update'

apt_package 'git'

git "/home/ubuntu/web-app-deploy-example" do
  repository "https://github.com/fedekau/web-app-deploy-example.git"
  revision "master"
  action :sync
end

#
# Cookbook:: backend_app
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
apt_update 'update'

apt_package 'git'

git "/home/ubuntu/web-app-deploy-example" do
  repository "ext::ssh -i /home/ubuntu/.ssh/id_rsa_deploy -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no git@github.com %S /fedekau/web-app-deploy-example.git"
  revision "master"
  action :sync
end

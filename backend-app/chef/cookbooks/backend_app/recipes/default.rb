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

include_recipe "sc-mongodb::default"

node.default['nodejs']['install_method'] = 'binary'
node.default['nodejs']['version'] = '8.9.4'
node.default['nodejs']['binary']['checksum'] = '21fb4690e349f82d708ae766def01d7fec1b085ce1f5ab30d9bda8ee126ca8fc'

include_recipe "nodejs"
include_recipe 'yarn::default'

yarn_install '/home/ubuntu/web-app-deploy-example/backend-app' do
  user 'root'
  action :run
end

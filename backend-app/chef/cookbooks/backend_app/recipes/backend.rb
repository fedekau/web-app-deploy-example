#
# Cookbook:: backend_app
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
apt_update 'update'

apt_package 'git'

git '/home/ubuntu/web-app-deploy-example' do
  repository 'ext::ssh -i /home/ubuntu/.ssh/id_rsa_deploy -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no git@github.com %S /fedekau/web-app-deploy-example.git'
  revision 'master'
  action :sync
end

node.default['nodejs']['install_method'] = 'binary'
node.default['nodejs']['version'] = '8.9.4'
node.default['nodejs']['binary']['checksum'] = '21fb4690e349f82d708ae766def01d7fec1b085ce1f5ab30d9bda8ee126ca8fc'

include_recipe 'nodejs'
include_recipe 'yarn::default'

yarn_install '/home/ubuntu/web-app-deploy-example/backend-app' do
  user 'root'
  action :run
end

file '/home/ubuntu/web-app-deploy-example/backend-app/app.js' do
  mode '755'
end

database_host = nil

search(:node, 'role:database') do |n|
  database_host = n['cloud']['public_ipv4']
  break
end

systemd_unit 'backend-app.service' do
  content <<-CONTENT
    [Unit]
    Description=Run backend app

    [Service]
    Environment=PORT=80
    Environment=NODE_ENV=production
    Environment=MONGODB_URI=mongodb://#{database_host}:27017/conduit
    Environment=SECRET=123456789
    PIDFile=/tmp/backend-app-99.pid
    User=root
    Group=root
    Restart=always
    KillSignal=SIGQUIT
    WorkingDirectory=/home/ubuntu/web-app-deploy-example/backend-app/
    ExecStart=/home/ubuntu/web-app-deploy-example/backend-app/app.js

    [Install]
    WantedBy=multi-user.target
  CONTENT

  action %i[create enable start restart]
end

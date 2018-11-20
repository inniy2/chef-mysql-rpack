#
# Cookbook:: chef-mysql-rpack
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.


#groupadd -g55000 mysql
group 'mysql' do
  gid 55000
  action :create
end

# useradd -u 55000 -g 55000 -c 'mysql-user' -m -d '/usr/local/mysql' -s '/bin/bash' -p '*' mysql
# chmod 755 /usr/local/mysql
user 'mysql' do
  comment 'mysql-user'
  uid 55000
  gid 'mysql'
  home '/usr/local/mysql'
  shell '/bin/bash'
  password '*'
end

## download mysql repository
remote_file '/usr/local/src/mysql57-community-release-el7-11.noarch.rpm' do
    source 'https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm'
    action :create
end

# sudo yum localinstall mysql57-community-release-el7-11.noarch.rpm
yum_package 'mysql57-community-release-el7-11.noarch.rpm' do
    source '/usr/local/src/mysql57-community-release-el7-11.noarch.rpm'
    action :install
end

# yum install mysql-community-server
# yum install http://repo.mysql.com/yum/mysql-5.7-community/el/7/x86_64/mysql-community-server-5.7.17-1.el7.x86_64.rpm
# yum install mysql-community-server-5.7.17-1.el7.x86_64 (OK)
yum_package 'mysql-community-server' do
    version '5.7.17-1.el7'
    action :install
end

# Create MySQL Directory
# cd / ; mkdir -pvm 755 /MYSQL ; cd /MYSQL
# mkdir -pvm 755 XXXXX ; cd XXXXX;
# mkdir -pvm 755 binlog data env innodb innodb-log log var work certs;
# mkdir -pvm 777 /MYSQL/XXXXX/work/tmp
# cd ../ ; chown -R mysql:mysql XXXXX ;

#directory '/MYSQL' do
#  owner 'mysql'
#  group 'mysql'
#  mode '0755'
#  action :create
#end

directory '/MYSQL/XXXXX' do
  recursive true
  owner 'mysql'
  group 'mysql'
  mode '0755'
  action :create
end

%w[ binlog data env innodb innodb-log log var work certs ].each do | path | 
    directory "/MYSQL/XXXXX/#{path}" do
      owner 'mysql'
      group 'mysql'
      mode '0755'
      action :create
    end
end

directory '/MYSQL/XXXXX/work/tmp' do
  owner 'mysql'
  group 'mysql'
  mode '0777'
  action :create
end

directory '/usr/local/mysql/sock' do
  recursive true
  owner 'mysql'
  group 'mysql'
  mode '0755'
  action :create
end

## copying MySQL data
# cd /var/lib/mysql
# mv ibdata1 /MYSQL/XXXXX/innodb/d1
# mv ib_buffer_pool /MYSQL/XXXXX/innodb/innodb_buffer_pool.info
# mv ib_logfile* /MYSQL/XXXXX/innodb-log
# mv mysql performance_schema sys /MYSQL/XXXXX/data/.
# mv *.pem /MYSQL/XXXXX/certs/.
# 
# \rm auto.cnf?
# # ??? Where did /MYSQL/XXXXX/data/mysql directory come from?


#src_filepath = '/var/lib/mysql'
#tar_filepath = '/MYSQL/XXXXX'
#bash 'Copying MySQL data' do
  #cwd ::File.dirname('/var/lib/mysql')
  #code <<-EOH
    #mv ibdata1 #{tar_filepath}/innodb/d1
    #mv ib_buffer_pool #{tar_filepath}/innodb/innodb_buffer_pool/info
    #mv ib_logfile* #{tar_filepath}/innodb-log/
    #mv mysql peformance_schema sys #{tar_filepath}/data/
    #EOH
  #not_if { ::File.exist?('/MYSQL/XXXXX/data/innodb/d1') }
#end

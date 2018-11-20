# # encoding: utf-8

# Inspec test for recipe chef-mysql-rpack::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

unless os.windows?
  # This is an example test, replace with your own test.
  describe user('root'), :skip do
    it { should exist }
  end
end

# This is an example test, replace it with your own test.
describe port(80), :skip do
  it { should_not be_listening }
end

# End goal
sql = mysql_session('root','XXXXX','localhost','3301')
describe sql.query('select version() as version') do
    its('stdout') { should match(/5.7.17/) }
end

#groupadd -g55000 mysql
describe group('mysql') do
  it { should exist }
  its('gid') { should eq 55000 }
end

# useradd -u 55000 -g 55000 -c 'mysql-user' -m -d '/usr/local/mysql' -s '/bin/bash' -p '*' mysql
# chmod 755 /usr/local/mysql
describe user('mysql') do
  it { should exist }
  its('uid') { should eq 55000 }
  its('gid') { should eq 55000 }
  its('group') { should eq 'mysql' }
  its('home') { should eq '/usr/local/mysql' }
  its('shell') { should eq '/bin/bash' }
end

## download mysql repository
describe file('/usr/local/src/mysql57-community-release-el7-11.noarch.rpm') do
    it { should exist }
end

# sudo yum localinstall mysql57-community-release-el7-11.noarch.rpm
describe yum do
    its('mysql57-community/x86_64') { should exist }
end

describe yum.repo('mysql57-community/x86_64') do
    it { should exist }
    it { should be_enabled }
    its('baseurl') { should include '5.7' }
end


# yum install mysql-community-server
# yum install http://repo.mysql.com/yum/mysql-5.7-community/el/7/x86_64/mysql-community-server-5.7.17-1.el7.x86_64.rpm
# yum install mysql-community-server-5.7.17-1.el7.x86_64 (OK)
describe package('mysql-community-server') do
    it { should be_installed }
    its('version') { should eq '5.7.17-1.el7' }
end

# Create MySQL Directory
# cd / ; mkdir -pvm 755 /MYSQL ; cd /MYSQL
# mkdir -pvm 755 XXXXX ; cd XXXXX;
# mkdir -pvm 755 binlog data env innodb innodb-log log var work certs;
# mkdir -pvm 777 /MYSQL/XXXXX/work/tmp
# cd ../ ; chown -R mysql:mysql XXXXX ;
describe file("/MYSQL/XXXXX") do
   it { should exist }
   it { should be_directory }
   it { should be_owned_by 'mysql' }
   its('mode') { should cmp '0755' }
end

%w[ binlog data env innodb innodb-log log var work certs ].each do | path | 
  describe file("/MYSQL/XXXXX/#{path}") do
    it { should exist }
    it { should be_directory }
    it { should be_owned_by 'mysql' }
    its('mode') { should cmp '0755' }
  end
end

describe file("/MYSQL/XXXXX/work/tmp") do
   it { should exist }
   it { should be_directory }
   it { should be_owned_by 'mysql' }
   its('mode') { should cmp '0777' }
end

describe file("/usr/local/mysql/sock") do
   it { should exist }
   it { should be_directory }
   it { should be_owned_by 'mysql' }
   its('mode') { should cmp '0755' }
end

## copying MySQL data
# cd /var/lib/mysql ? Where is the directories and files?
# mv ibdata1 /MYSQL/XXXXX/innodb/d1
# mv ib_buffer_pool /MYSQL/XXXXX/innodb/innodb_buffer_pool.info
# mv ib_logfile* /MYSQL/XXXXX/innodb-log
# mv mysql performance_schema sys /MYSQL/XXXXX/data/.
# mv *.pem /MYSQL/XXXXX/certs/.
#
# \rm auto.cnf ? Why do I need to delete the file

describe file("/var/lib/mysql") do
   it { should exist }
   it { should be_directory }
end

describe file("/var/lib/mysql/ibdata1") do
   it { should exist }
   it { should be_file }
end

describe file("/MYSQL/XXXXX/innodb/d1") do
   it { should exist }
   it { should be_file }
   it { should be_owned_by 'mysql' }
end

describe file("/MYSQL/XXXXX/innodb/innodb_buffer_pool.info") do
   it { should exist }
   it { should be_file }
   it { should be_owned_by 'mysql' }
end

describe file("/MYSQL/XXXXX/innodb-log/ib_logfile*") do
   it { should exist }
   it { should be_file }
   it { should be_owned_by 'mysql' }
end

%w[ mysql performance_schema sys ].each do | path | 
  describe file("/MYSQL/XXXXX/data/#{path}") do
    it { should exist }
    it { should be_directory }
    it { should be_owned_by 'mysql' }
    its('mode') { should cmp '0755' }
  end
end

describe file("/MYSQL/XXXXX/certs/*.pem") do
   it { should exist }
   it { should be_file }
   it { should be_owned_by 'mysql' }
end

# Make directories
if [[ ! -d /var/log/chef ]]; then
  mkdir /var/log/chef
fi
# this is bullshit

if [ ! -d /etc/chef ]; then
  mkdir /etc/chef
fi
cd /etc/chef
# this is also bullshit
if
{
}
fi
# Remove client.pem if it exists
if [ -f /etc/chef/client.pem ]; then
  rm /etc/chef/client.pem
fi

which wget
if [ $? != 0 ]; then
  yum install wget -y
fi

cd /etc/chef

# Download chef installer
wget -q -t 5 $ChefInstallerUrl
rc=$?
if [[ $rc != 0 ]] ; then
    echo "PROV-002: Error downloading Chef" >&2
    exit $rc
fi

#Download validation.pem
wget -q -t 5 $ValidationURL
rc=$?
if [[ $rc != 0 ]] ; then
    echo "PROV-003: Error downloading validation.pem" >&2
    exit $rc
fi

# Creating the client.rb file
cat > /etc/chef/client.rb <<EOF
log_level        :info
log_location     STDOUT
verbose_logging true

chef_server_url "$ChefServerUrl"
validation_client_name "-validator"
validation_key "/etc/chef/validation.pem"
node_name ::File.read("/etc/chef/node_name").strip if ::File.exists?("/etc/chef/node_name")
client_key "/etc/chef/client.pem"

file_backup_path   "/var/lib/chef"
file_cache_path    "/var/cache/chef"
cache_options({ :path => "/var/cache/chef/checksums", :skip_expires => true })

pid_file           "/var/run/chef/client.pid"

Ohai::Config[:disabled_plugins] =  ["windows::kernel_devices"]

EOF


#Create node_name file
echo $VMNodename > /etc/chef/node_name

#Install Chef
rpm -ivh --force chef-client-11.12.4-1.x86_64.rpm
rc=$?
if [[ $rc != 0 ]] ; then
    echo "PROV-005: Error installing Chef" >&2
    exit $rc
fi

#Create first-run.json with the initial runlist of 'role[provisioning-client]' and the target_runlist attribute set to what was provided in the databag.

cat > /etc/chef/first-run.json <<EOF
$Runlist
EOF

#Run Chef
chef-client -c /etc/chef/client.rb -j /etc/chef/first-run.json
rc=$?
if [[ $rc != 0 ]] ; then
    echo "PROV-006: Error executing Chef" >&2
    if [ -f /var/cache/chef/chef-stacktrace.out ] ; then
      echo "########## Chef Stacktrace ##########"
      cat /var/cache/chef/chef-stacktrace.out
    fi
    exit $rc
fi

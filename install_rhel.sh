#It is a wrapper script for the install_rheling script

#Export path to chef-client-11.12.4-1.x86_64.rpm
export  ChefInstallerUrl="https://software.s3.amazonaws.com/chef-client-11.12.4-1.x86_64.rpm"

#Export the path to validation.pem
export ValidationURL="https://chef-repo.s3.amazonaws.com/validation.pem"

#Export the runlists
export Runlist='{"run_list":[]}'

#Export the ChefserverUrl
export ChefServerUrl="https://manage.opscode.com/organizations/xxx "

#Export nodename
export VMNodename=$1

# download and run the install_rheling script
echo 'downloading and running script'
curl https://chef.s3.amazonaws.com/install_rhel_rhel.sh > /tmp/install_rhel_rhel.sh
rc=$?
if [[ $rc != 0 ]] ; then
    echo "Failed to download the install_rheling script" >&2
    exit $rc
fi
chmod 777 /tmp/install_rhel.sh
CR='\015'
tr -d $CR </tmp/install_rhel.sh> /tmp/install_rhel.sh
chmod 777 /tmp/install_rhel.sh
/tmp/install_rhel.sh > /tmp/install_rheling.log
rc=$?
if [[ $rc != 0 ]] ; then
  echo "Error Code -$rc : Your VM has failed to register with the xxx company"
else
  echo "Your VM has been successfully registered with the xxx company "
fi

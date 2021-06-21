#!/bin/bash
# install required packages for lxc container launched from `images:centos/8`
# setup-lnxcfg-user
# create lnxcfg user for Ansible automation
# and configuration management
# create lnxcfg user

#install pre-requisite packages and vim
dnf install -y openssh-server sudo firewalld vim

getentUser=$(/usr/bin/getent passwd lnxcfg)
if [ -z "$getentUser" ]
then
  echo "User lnxcfg does not exist.  Will Add..."
  /usr/sbin/groupadd -g 2002 lnxcfg
  /usr/sbin/useradd -u 2002 -g 2002 -c "Ansible Automation Account" -s /bin/bash -m -d /home/lnxcfg lnxcfg
# echo "lnxcfg:<PUT IN YOUR OWN lnxcfg PASSWORD>" | /usr/sbin/chpasswd
mkdir -p /home/lnxcfg/.ssh
fi
# setup ssh authorization keys for Ansible access 
echo "setting up ssh authorization keys..."
cat << 'EOF' >> /home/lnxcfg/.ssh/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACBSmFgMek1WjJif8W2Iz4W9YoVMu9wCfiTja+GJq3h ansible
EOF
chown -R lnxcfg:lnxcfg /home/lnxcfg/.ssh
chmod 700 /home/lnxcfg/.ssh
# setup sudo access for Ansible
if [ ! -s /etc/sudoers.d/lnxcfg ]
then
echo "User lnxcfg sudoers does not exist.  Will Add..."
cat << 'EOF' > /etc/sudoers.d/lnxcfg
User_Alias ANSIBLE_AUTOMATION = lnxcfg
ANSIBLE_AUTOMATION ALL=(ALL)      NOPASSWD: ALL
EOF
chmod 400 /etc/sudoers.d/lnxcfg
fi

## httpd firewall configuration
systemctl enable firewalld
systemctl start firewalld

sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp

## OpenSSH server configuration file changes
export sshconfig_file=/etc/ssh/sshd_config
sudo firewall-cmd --reload


### Set options to allow sftp to  work correctly
# https://unix.stackexchange.com/a/209793/309699
sed -i 's/^#PubkeyAuthentication.*$/PubkeyAuthentication yes/' ${sshconfig_file}
sed -i 's/Subsystem.*sftp.*$/Subsystem sftp internal-sftp/' ${sshconfig_file}

# disable login for lnxcfg except through 
# ssh keys
cat << 'EOF' >> ${sshconfig_file}
Match User lnxcfg
        PasswordAuthentication no
        AuthenticationMethods publickey
        

EOF
systemctl enable sshd
systemctl start sshd
dnf clean all 
systemctl restart sshd
rm -rf /var/cache/dnf
rm -rf /tmp/*
# end of script
# ansible_tutorial

Following a [tutorial playlist](https://youtube.com/playlist?list=PLT98CRl2KxKG7LKdWeXYUe6_UTeUybE2Z)
 on the LearnLinuxTV YouTube Channel

## Process

( in-progess)

### Create required lxc profile

You will need to substitute in your public key you made for ansible by editing 

```
lxc profile create ansible
cat lxc-profiles/ansible-base-profile.yml | lxc profile edit ansible by editing `ansible-base-profile.yml`
```

### create your host container

```
lxc launch ubuntu:20.04 --profile default --profile ansible ansible-host

```


Within the Ubuntu 20.04 LTS lxc container:

1. Install miniconda using install-miniconda.sh
2. `apt purge ansible` - to make sure there is no ansible installation based on a python which conflicts with 
the miniconda environment
3. `conda install -c conda-forge mamba` -  a much quicker build tool for conda environments
4. `mamba env create -f ./environment.yml` - to create a conda environment with ansible installed.
5. Add the incantation to activate the environment to your user's shell startup script `echo 'conda activate ansible_env >>~/.bashrc'` change if you are using zsh to ~/.zshrc

## Lesson Notes

### Getting started with Ansible 07 - The 'when' Conditional

The CentOS image `images:centos/8` is missing a lot of things needed to follow the tutorial

- packages: `openssh-server sudo firewalld`
- configuration: an ansible sudoer user, firewall configuration for httpd

[How To Install the Apache Web Server on CentOS 8](https://www.digitalocean.com/community/tutorials/how-to-install-the-apache-web-server-on-centos-8) - I followed the isntructions, but had to add http service becuase lynx would not make connection without https certificate.

### Getting started with Ansible 10 - Tags

Running a playbook with a list of tags causes only plays or tasks which have all the tags to be executed. The list is AND. See [Selecting or skipping tags when you run a playbook](https://docs.ansible.com/ansible/latest/user_guide/playbooks_tags.html#selecting-or-skipping-tags-when-you-run-a-playbook)

```
ansible-playbook site.yml --tags "apache,db"
```

## General Notes

```
# capture your containers' ip addresses in a handy shell variable for iterating over

export servers_ip=$(lxc ls -c 4 --format csv| cut -d" " -f1  | xargs) 


#Using it here to copy public keys to ubuntu servers - probably will not work for CentOS

for i in ${servers_ip}; do ssh-copy-id -i ~/.ssh/ansible ubuntu@$i ; done

```

### Iterate over containers in parallel

```
# Use those cores!
 % for i in $servers; do lxc restore ${i} base &; done && wait
```

```
% cat ~/.ssh/config
Host one
        HostName 10.69.189.56
Host three
        HostName 10.69.189.216
Host two
        HostName 10.69.189.215

Host one-ansible
        HostName 10.69.189.56
Host three-ansible
        HostName 10.69.189.216
Host two-ansible
        HostName 10.69.189.215

Host *ansible
        IdentityFile ~/.ssh/ansible


Host *
        User ubuntu
        IdentityFile ~/.ssh/peter_tutorial
        StrictHostKeyChecking=no
```

### Create the initial inventory file

```
lxc ls -c 4 --format csv| cut -d" " -f1 > inventory
```

or

```
% cat ~/.ssh/config| grep '\-ansible'| cut -d" " -f2 > inventory
```
 ### ansible `-- become option`

no password on the lxc servers, so password is empty when asked, but not really required.

### CentOS 8 container configuration

Had to do some extra work to get sftp to work - see comments in [setup-lnxcfg-user.sh](./setup-lnxcfg-user.sh)

Out of the box, the centos/8 container is not very cooperative:
- No `su`  so ansible `become:` fails
- No ssh-serrver
- Only a root user

[Learning Ansible with CentOS 7 Linux](https://brad-simonin.medium.com/learning-ansible-with-centos-7-linux-12461043fd02) by Bradley Simonin provides guidance. I modified his script here [setup-lnxcfg-user.sh](./setup-lnxcfg-user.sh), to install the missing software as well as implement Bradley's process. I've left my example public key in-place. 

To set up a centos container for ansible:

```
# Create the container
lxc launch images:centos/8 --profile default centos

# Push the initialization script to the container
lxc file push ./setup-lnxcfg-user.sh centos/root/

# Execute the set-up script
lxc exec centos -- /bin/bash ./setup-lnxcfg-user.sh
```

The you need to update the relevant sections of your ansible server's `~/.ssh/config`. Should look a bit like this:

```
Host centos-ansible
    HostName 10.69.189.138
    User lnxcfg

Host *ansible
	IdentityFile ~/.ssh/ansible

```





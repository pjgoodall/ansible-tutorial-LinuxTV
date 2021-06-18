# ansible_tutorial

Following a [tutorial playlist](https://youtube.com/playlist?list=PLT98CRl2KxKG7LKdWeXYUe6_UTeUybE2Z)
 on the LearnLinuxTV YouTube Channel

## Process

1. Install miniconda using install-miniconda.sh
2. `apt purge ansible` to make sure there is no ansible installation based on a p[ython which conflicts with 
the miniconda environment
3. `conda install -c conda-forge mamba` much quicker build tool for conda environments
4. `mamba env create -f ./environment.yml` to create a conda environment with ansible installed.
5. Add the incantation to activate the environment to your user's shell startup script `echo 'conda activate ansible_env >>~/.bashrc'` change if you are using zsh to ~/.zshrc


## Notes

```
# capture your containers' ip addresses in a handy shell variable for iterating over

export servers_ip=$(lxc ls -c 4 --format csv| cut -d" " -f1  | xargs) 


#Using it here to copy public keys to ubuntu servers - probably will not work for CentOS

for i in ${servers_ip}; do ssh-copy-id -i ~/.ssh/ansible ubuntu@$i ; done

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





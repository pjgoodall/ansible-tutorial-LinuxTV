# ansible_tutorial

Following a [tutorial playlist](https://youtube.com/playlist?list=PLT98CRl2KxKG7LKdWeXYUe6_UTeUybE2Z)
 on the LearnLinuxTV YouTube Channel

## Process

1. Install miniconda using install-miniconda.sh
2. `apt purge ansible` to make sure there is no ansible installation based on a p[ython which conflicts with 
the miniconda environment
3. `conda install -c conda-forge mamba` much quicker build tool for conda environments
4. `mamba env create -f ./environment.yml` to create a conda environment with ansible installed.
5. activate the environment `echo 'conda activate ansible_env >>~/.bashrc'` change if you are using zsh **not working**


## Notes

```
export servers_ip=$(lxc ls -c 4 --format csv| cut -d" " -f1  | xargs) 
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

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


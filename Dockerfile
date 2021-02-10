FROM ubuntu:18.04

# Updating Ubuntu packages
RUN apt-get update && yes|apt-get upgrade

# Upgrade installed packages
RUN apt-get update && apt-get upgrade -y && apt-get clean

# Python package management and basic dependencies
RUN apt-get install -y curl python3.7 python3.7-dev python3.7-distutils

# Register the version in alternatives
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.7 1

# Set python 3 as the default python
RUN update-alternatives --set python /usr/bin/python3.7

# Upgrade pip to latest version
RUN curl -s https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python get-pip.py --force-reinstall && \
    rm get-pip.py

RUN apt-get install -y emacs

# Adding wget and bzip2
RUN apt-get install -y wget bzip2

# Add sudo
RUN apt-get -y install sudo

#### Anaconda installing
RUN wget https://repo.continuum.io/archive/Anaconda3-2020.11-Linux-x86_64.sh

RUN bash ./Anaconda3-2020.11-Linux-x86_64.sh -fbp $INSTALL_PATH \
    && echo 'export PATH="/root/anaconda3/bin:$PATH"' >> ~/.bashrc \
    && /bin/bash -c "source ~/.bashrc"

ENV PATH=/root/anaconda3/bin:$PATH
ENV PATH=~/anaconda3/bin:$PATH

RUN rm ./Anaconda3-2020.11-Linux-x86_64.sh

RUN conda update --all
RUN conda init bash \
    && . ~/.bashrc \
    && conda create --name cibersort python=3.7 \
    && conda activate cibersort \
    && conda install -c conda-forge scikit-learn==0.22.1 lifelines==0.24.2 tensorflow==1.14.0

SHELL ["conda","run","-n","cibersort","/bin/bash","-c"]
RUN conda install -c conda-forge jupyterlab vim
RUN conda install -c r r-essentials
RUN conda install -c r rstudio
RUN conda install -c lightsource2-tag collection
RUN conda install -c numpy matplotlib==3.2.1 seaborn==0.10.1
RUN pip install statannot==0.2.2
RUN conda install -c anaconda pillow

RUN sudo apt-get install -y libxml2-dev
RUN sudo apt-get install -y libcurl4-openssl-dev
RUN conda install -c anaconda git 


# to run, type :
# docker run -p 8888:8888 -itd cibersort /bin/bash
# docker exec -it [image] /bin/bash

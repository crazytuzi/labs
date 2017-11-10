# jupyter+bash kernel for linux exp 2016"
# docker build -t libo/exp_server:v6.0 .
# docker commit ....

#FROM ipython/notebook
#FROM jupyter/nbviewer
FROM jupyter/minimal-notebook
#FROM fpsom/jupyter-kernels:latest

MAINTAINER libo libo@swust.edu.cn

#ENV REFRESHED_AT 2014-08-18

USER root

# install bash kernel for jupyter
RUN wget https://github.com/takluyver/bash_kernel/archive/master.zip
RUN unzip master.zip
RUN cd bash_kernel-master && \
    pip install bash_kernel && \
    python -m bash_kernel.install
RUN rm master.zip
RUN rm -rf bash_kernel-master

RUN mkdir /notebooks
#RUN pwd
RUN cd /notebooks  

# RUN git clone https://github.com/fzinfz/notes.git
RUN git clone http://vlab.cs.swust.edu.cn:8081/linuxCourse/linux2017/labs "/notebooks"
# RUN ipython notebook --no-mathjax --ip=*

COPY start.sh /usr/local/bin/
COPY jupyter_notebook_config.py /home/$NB_USER/.jupyter/
EXPOSE 8888

# lab5
COPY sources.list /etc/apt/
RUN apt update
RUN apt install -y --force-yes gdb

# lab8
RUN apt install -y --force-yes man
RUN apt install -y --force-yes net-tools
RUN apt install -y --force-yes ftp


#ENTRYPOINT ["executable", "param1","param2"]

#VOLUME [ "./" ]

#WORKDIR /notebooks/
CMD ["start-notebook.sh"]

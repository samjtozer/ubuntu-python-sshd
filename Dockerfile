FROM ubuntu

ARG PROJECT_PATH=/usr/src/python-app/
ENV SSH_SERVER_KEYS /etc/ssh/host_keys/

#
# Install virtualenv for developing
#
RUN apt-get update && \
    apt-get install -y python3.7 python3-pip && \
    python3.7 -m pip install --no-cache-dir virtualenv 

#
# Copy rootfs files
#

COPY /rootfs /

#
# Install ssh-server for connect remote python interpreter
#

EXPOSE 22

RUN apt-get update
RUN apt-get install -y bash openssh-server sudo 
RUN mkdir -p ${SSH_SERVER_KEYS}
RUN mkdir ${PROJECT_PATH} 
RUN echo -e "HostKey ${SSH_SERVER_KEYS}ssh_host_rsa_key" >> /etc/ssh/sshd_config 
RUN echo -e "HostKey ${SSH_SERVER_KEYS}ssh_host_dsa_key" >> /etc/ssh/sshd_config 
RUN echo -e "HostKey ${SSH_SERVER_KEYS}ssh_host_ecdsa_key" >> /etc/ssh/sshd_config 
RUN echo -e "HostKey ${SSH_SERVER_KEYS}ssh_host_ed25519_key" >> /etc/ssh/sshd_config 
RUN sed -i "s/#PermitRootLogin.*/PermitRootLogin\ yes/" /etc/ssh/sshd_config 
RUN echo "root:root" | chpasswd 
RUN chmod a+x /usr/local/bin/* 

WORKDIR ${PROJECT_PATH}

#
# Saving dev virtualenv and ssh host keys
#

VOLUME ["${SSH_SERVER_KEYS}", "/root/"]

ENTRYPOINT ["entrypoint.sh"]

CMD ["/usr/sbin/sshd", "-D", "-e"]
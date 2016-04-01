FROM docker.local/base

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openssh-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
RUN mkdir /var/run/sshd
RUN touch /root/.ssh/authorized_keys
RUN cat /root/.ssh/insecure_key.pub >> /root/.ssh/authorized_keys

RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
RUN echo "You're in a container. Enjoy..." > /etc/motd

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D", "-d"]

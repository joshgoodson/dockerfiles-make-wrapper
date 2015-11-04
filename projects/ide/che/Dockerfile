FROM codenvy/che

RUN mkdir -p /home/user/che-projects
VOLUME ["/home/user/che-projects/"]
RUN rm -rf /home/user/.che/vfs

ADD che.properties /home/user/.che/che.properties
ADD che.vfs /home/user/.che/vfs

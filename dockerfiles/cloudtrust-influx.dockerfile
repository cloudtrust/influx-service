FROM cloudtrust-baseimage:f27
ARG influx_service_git_tag
ARG influx_tools_git_tag
ARG config_git_tag
ARG config_repo

RUN echo -e "[influxdb]\nname = InfluxDB Repository - RHEL \$releasever\nbaseurl = https://repos.influxdata.com/rhel/7/\$basearch/stable\nenabled = 1\ngpgcheck = 1\ngpgkey = https://repos.influxdata.com/influxdb.key" >> /etc/yum.repos.d/influxdb.repo

RUN dnf update -y && \
    dnf -y install which influxdb monit nginx python3 python3-pip && \
    dnf clean all

WORKDIR /cloudtrust
RUN git clone git@github.com:cloudtrust/influx-service.git && \
    git clone git@github.com:cloudtrust/influx-tools.git && \
    git clone ${config_repo} ./config

WORKDIR /cloudtrust/influx-service
RUN git checkout ${influx_service_git_tag} && \
    mkdir -p /var/lib/influxdb/data/influxdb_log && \
    chown influxdb:influxdb -R /var/lib/influxdb && \
    install -v -m0644 deploy/etc/security/limits.d/* /etc/security/limits.d/ && \
# Install monit
    install -v -m0644 deploy/etc/monit.d/* /etc/monit.d/ && \    
# nginx setup
    install -v -m0644 -D deploy/etc/nginx/conf.d/* /etc/nginx/conf.d/ && \
    install -v -m0644 deploy/etc/nginx/nginx.conf /etc/nginx/nginx.conf && \
    install -v -m0644 deploy/etc/nginx/mime.types /etc/nginx/mime.types && \
    install -v -o root -g root -m 644 -d /etc/systemd/system/nginx.service.d && \
    install -v -o root -g root -m 644 deploy/etc/systemd/system/nginx.service.d/limit.conf /etc/systemd/system/nginx.service.d/limit.conf && \
# influxdb setup
    install -v -m0755 -d /etc/influxdb && \
    install -v -m0744 -d /run/influxdb && \
    install -v -m0755 deploy/etc/influxdb/* /etc/influxdb && \
    install -v -o root -g root -m 644 -d /etc/systemd/system/influxdb.service.d && \
    install -v -o root -g root -m 644 deploy/etc/systemd/system/influxdb.service.d/limit.conf /etc/systemd/system/influxdb.service.d/limit.conf

WORKDIR /cloudtrust/influx-tools
RUN git checkout ${influx_tools_git_tag} && \
    pyvenv . && \
    . bin/activate && \
    pip install -r ./requirements.txt

    
WORKDIR /cloudtrust/config
RUN git checkout ${config_git_tag} && \  
    install -v -o root -g root -m 644 deploy/etc/systemd/system/influxdb_init.service /etc/systemd/system/influxdb_init.service && \
    install -d -v -m0755 /cloudtrust/influxdb-config/ && \	  
    install -v -m0750 -o root -g root deploy/cloudtrust/influxdb-config/* /cloudtrust/influxdb-config/ 



# enable services
RUN systemctl enable influxdb_init && \
    systemctl enable nginx.service && \
    systemctl enable influxdb.service && \
    systemctl enable monit.service

VOLUME ["/var/lib/influxdb"]

EXPOSE 80

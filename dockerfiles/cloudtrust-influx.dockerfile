FROM cloudtrust-baseimage:f27

ARG influx_service_git_tag

WORKDIR /cloudtrust

# Add InfluxDB repository
RUN echo -e "[influxdb]\nname = InfluxDB Repository - RHEL \$releasever\nbaseurl = https://repos.influxdata.com/rhel/7/\$basearch/stable\nenabled = 1\ngpgcheck = 1\ngpgkey = https://repos.influxdata.com/influxdb.key" >> /etc/yum.repos.d/influxdb.repo && \
# Install which, InfluxDB, monit
    dnf -y install which influxdb monit nginx && 
    dnf clean all && \
    git clone git@github.com:cloudtrust/influx-service.git && \
    groupadd influxdb && \
    useradd -m -s /sbin/nologin -g influxdb influxdb && \
    cd /cloudtrust/influx-service && \
    git checkout ${influx_service_git_tag} 

# Configure Influx, install
RUN cd /cloudtrust/influx-service && \
    mkdir -p /var/lib/influxdb/data/influxdb_log && \
    chown influxdb:influxdb -R /var/lib/influxdb && \
    install -v -m0644 deploy/common/etc/security/limits.d/* /etc/security/limits.d/ && \
# Install monit
    install -v -m0644 deploy/common/etc/monit.d/* /etc/monit.d/ && \    
# nginx setup
    install -v -m0644 -D deploy/common/etc/nginx/conf.d/* /etc/nginx/conf.d/ && \
    install -v -m0644 deploy/common/etc/nginx/nginx.conf /etc/nginx/nginx.conf && \
    install -v -m0644 deploy/common/etc/nginx/mime.types /etc/nginx/mime.types && \
    install -v -o root -g root -m 644 -d /etc/systemd/system/nginx.service.d && \
    install -v -o root -g root -m 644 deploy/common/etc/systemd/system/nginx.service.d/limit.conf /etc/systemd/system/nginx.service.d/limit.conf && \
# influxdb setup
    install -v -m0755 -d /etc/influxdb && \
    install -v -m0744 -d /run/influxdb && \
    install -v -m0755 deploy/common/etc/influxdb/* /etc/influxdb && \
    install -v -o root -g root -m 644 -d /etc/systemd/system/influxdb.service.d && \
    install -v -o root -g root -m 644 deploy/common/etc/systemd/system/influxdb.service.d/limit.conf /etc/systemd/system/influxdb.service.d/limit.conf && \
# enable services
    systemctl enable nginx.service && \
    systemctl enable influxdb.service && \
    systemctl enable monit.service

#Add influx tools
WORKDIR /cloudtrust
RUN dnf install python3 pip && \
    git clone ssh://git@git.elcanet.local:7999/cloudtrust/influx-tools.git && \
    cd influx-tools && \
    pyvenv . && \
    . bin/activate && \
    pip install -r ./requirements.txt && \
    install -v -o root -g root -m 644 deploy/etc/systemd/system/influxdb_init.service /etc/systemd/system/influxdb_init.service

VOLUME ["/var/lib/influxdb"]

EXPOSE 80

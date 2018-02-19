ARG influx_service_git_tag
FROM cloudtrust-influx:${influx_service_git_tag}

ARG environment
ARG branch
ARG config_repository

WORKDIR /cloudtrust

# Get config config
RUN git clone ${config_repository} ./config && \
	cd ./config && \
    git checkout ${branch}

# Setup Customer http-router related config
############################################

WORKDIR /cloudtrust/config
RUN install -v -m0775 -o root -g root deploy/${environment}/etc/sysconfig/cloudtrust_influxdb_init /etc/sysconfig/cloudtrust_influxdb_init && \
    systemctl enable influxdb_init

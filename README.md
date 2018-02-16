# influx-service

## Installing influx-service
```Bash
cd /cloudtrust
#Get the repo
git clone ssh://git@git.elcanet.local:7999/cloudtrust/influx-service.git

cd influx-service

#install systemd unit file
install -v -o root -g root -m 644  deploy/common/etc/systemd/system/cloudtrust-influx@.service /etc/systemd/system/cloudtrust-influx@.service

mkdir build_context
cp dockerfiles/cloudtrust-influx.dockerfile build_context/
cd build_context

#Build the dockerfile for DEV environment
docker build --build-arg branch=master -t cloudtrust-influx:f27 -t cloudtrust-influx:latest -f cloudtrust-influx.dockerfile .

#create container 1
docker create --tmpfs /tmp --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 8086:80 --name influx-1 cloudtrust-influx

systemctl daemon-reload
#start container DEV1
systemctl start cloudtrust-influx@1

# Test
# The python script testInfluxdb creates a db, writes data, read the same data and delete the db.
# From influx-service directory, run 
#TODO : Move to a dedicated virtual env
dnf install python3-influxdb
python3.6 test/testInfluxdb.py --host=172.17.0.2 --port=80

```
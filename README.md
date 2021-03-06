# rcip-docker-openshift-monitoring
Docker build using rcip-openshift-ansible repo in order to build a monitoring/graph/log docker image

## What
The repository provide a Dockerfile in order to build a monitoring-client docker image. For example on Atomic host we can't setup packages and tools needed to run inside a docker container.
This image includes sensu-client, collectd, logstash (setuped by the rcip-openshift-ansible playbook)

  [1] : https://github.com/redhat-cip/rcip-openshift-ansible

## Step 1 : Ansible inventory
Copy your ansible inventory file (used during the openshift setup) or use the ansible_hosts.example

```bash
ansible_hosts
 ```

## Step 2 : Build your image

Edit the dockerfile_start.sh and change the HOSTNAME to match a node in every groups (masters, nodes, etcd ...)
```bash
cat dockerfile_start.sh

docker build \
--no-cache \
--build-arg SUBSCRIPTION_USER=user \
--build-arg SUBSCRIPTION_PASSWORD=password \
--build-arg SUBSCRIPTION_POOL=poolid \
--build-arg HOSTNAME=master1.ose-example.com \
-t rcip/openshift-monitoring-client:v1 \
.
 ```

And run your build
```bash
bash dockerfile_start.sh
 ```

## Step 3 : Export your image

Save in a tar file
```bash
docker ps
docker save rcip/openshift-monitoring-client > /tmp/openshift-monitoring-client.tar
 ```

Or on Docker hub

```bash
docker tag <imageID> docker.io/rcip/openshift-monitoring-client
docker login --username user --email user@email.com docker.io
docker push docker.io/rcip/openshift-monitoring-client
 ```

## Step 4 : Deploy your image

Copy the image on your nodes
```bash
scp /tmp/openshift-monitoring-client.tar master1.ose-example.com:/tmp/
 ```
From you node, import and tag your image
```bash
docker load < openshift-monitoring-client.tar
docker images
docker tag <imageID> rcip/openshift-monitoring-client
 ```

Or from Docker hub

```bash
docker pull docker.io/rcip/openshift-monitoring-client
 ```


## Step 5 : Run your image

```bash
service openshift-monitoring-client start
 ```

The service declaration is push by the rcip-openshift-ansible [2] during the post.yml playbook

  [2] : https://github.com/redhat-cip/rcip-openshift-ansible/blob/master/roles/common/templates/etc/systemd/system/openshift-monitoring-client.service.j2

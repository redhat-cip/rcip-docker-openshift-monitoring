#FROM registry.access.redhat.com/rhel7
FROM centos

ARG SUBSCRIPTION_USER
ARG SUBSCRIPTION_PASSWORD
ARG SUBSCRIPTION_POOL
ARG HOSTNAME

#RUN subscription-manager register --username=$SUBSCRIPTION_USER --password=$SUBSCRIPTION_PASSWORD
#RUN subscription-manager attach --pool=$SUBSCRIPTION_POOL
#RUN subscription-manager repos --disable='*'
#RUN subscription-manager repos --enable='rhel-7-server-rpms' --enable='rhel-7-server-extras-rpms' --enable='rhel-7-server-optional-rpms'
RUN yum install git -y
RUN yum -y install http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-6.noarch.rpm
RUN yum --enablerepo=epel install ansible -y

#Setup supervisord
RUN easy_install supervisor
ADD ./configs/supervisord.conf /etc/supervisord.conf
RUN mkdir /var/log/supervisor/

#Ansible run

RUN git clone https://github.com/redhat-cip/rcip-openshift-ansible

RUN echo "127.0.0.1 $HOSTNAME" > /etc/hosts
RUN mkdir /etc/ansible/facts.d

RUN echo '{"is_atomic": false}' > /etc/ansible/facts.d/system.fact
#COPY ansible_hosts /etc/ansible/hosts
ADD ansible_hosts /etc/ansible/hosts
RUN ansible-playbook rcip-openshift-ansible/post.yml --extra-vars dockerbuild=true --tags monitoring-client,graph-client,log-client -l $HOSTNAME --connection=local

#Clean image
RUN yum clean all
RUN rm -rf /etc/ansible/hosts
RUN echo "127.0.0.1 monitoring-client" > /etc/hosts

#VOLUME [ "/etc/origin/node", "/var/lib/origin" ]


#EXPOSE 8000
#RUN sleep 10000
ADD scripts/run.sh /
ENTRYPOINT ["/run.sh"]

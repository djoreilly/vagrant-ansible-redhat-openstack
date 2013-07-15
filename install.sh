#!/usr/bin/bash

set -x

cd vagrant-ansible-redhat-openstack
vagrant up
cd ..


git clone https://github.com/ansible/ansible-redhat-openstack.git
# git clone https://github.com/djoreilly/ansible-redhat-openstack.git
#TODO sed -i 's/eth0/eth1/g' ansible-redhat-openstack/group_vars/all
#TODO sed  cinder disk       ansible-redhat-openstack/group_vars/all

export ANSIBLE_CONFIG=vagrant-ansible-redhat-openstack/ansible.cfg
#TODO ansible-playbook -v ansible-redhat-openstack/site.yml

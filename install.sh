#!/usr/bin/bash

set -ex

if [ "$#" -eq 1 ]; then
   VARO=$1
else
   VARO=vagrant-ansible-redhat-openstack
fi

cd $VARO
vagrant up
cd ..


#git clone https://github.com/ansible/ansible-redhat-openstack.git
git clone https://github.com/djoreilly/ansible-redhat-openstack.git
cd ansible-redhat-openstack
git checkout allow-any-ethX
cd ..

sed -i 's/iface: eth0/iface: eth1/' ansible-redhat-openstack/group_vars/all
sed -i 's/cinder_volume_dev: \/dev\/vda3/cinder_volume_dev: \/dev\/sdb/' ansible-redhat-openstack/group_vars/all


ansible-playbook -v --sudo --user vagrant --inventory-file ${VARO}/hosts \
--private-key ${VARO}/vagrant_private_key ansible-redhat-openstack/site.yml

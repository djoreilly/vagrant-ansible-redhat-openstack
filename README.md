vagrant-ansible-redhat-openstack
================================


A Vagrant script to create two CentOS 6.4 VirtualBox VMs as targets for the Ansible OpenStack installer from [here](https://github.com/ansible/ansible-redhat-openstack.git).


##Requirements
* [Ansible](http://www.ansibleworks.com/docs/gettingstarted.html) >= 1.2
* [Vagrant](http://www.vagrantup.com) >= 1.2.2
* [VirtualBox](https://www.virtualbox.org) >= 4.2
* git
* 2.5 GB RAM (or tweak Vagrantfile)

##Steps


    * mkdir topdir; cd topdir
    * git clone git@github.com:djoreilly/vagrant-ansible-redhat-openstack.git
    * bash vagrant-ansible-redhat-openstack/install.sh


#Notes

The vagrant box at http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.4-x86_64-v20130427.box is very slow to download - it took >1.5 hours - but it only needs to be done the first time.
 
##External access for controller node and instances

The installer also creates a Quantum router which adds another default route to the controller's route table (IP namespaces are not being used):


    root@controller# ip route
    192.168.2.0/24 dev eth1  proto kernel  scope link  src 192.168.2.41 
    10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15 
    1.1.1.0/24 dev qg-39366aa0-f8  proto kernel  scope link  src 1.1.1.2 
    169.254.0.0/16 dev eth0  scope link  metric 1002 
    169.254.0.0/16 dev eth1  scope link  metric 1003 
    default via 1.1.1.1 dev qg-39366aa0-f8 
    default via 10.0.2.2 dev eth0 


This causes comms problems, so delete the Vagrant/VirtualBox default route:

    root@controller# ip route delete default via 10.0.2.2 dev eth0

(this will need to be repeated if the controller is rebooted)

and do any additional work outside to ensure 1.1.1.1 gets further natting for Internet access.


##Running the playbooks


    export VARO=vagrant-ansible-redhat-openstack

    $ ansible-playbook -v --user vagrant --inventory-file ${VARO}/hosts --private-key ${VARO}/vagrant_private_key \
    ansible-redhat-openstack/playbooks/image.yml \
    -e "image_name=cirros image_url=https://launchpad.net/cirros/trunk/0.3.0/+download/cirros-0.3.0-x86_64-disk.img"

    $ ansible-playbook -v --user vagrant --inventory-file ${VARO}/hosts --private-key ${VARO}/vagrant_private_key \
    ansible-redhat-openstack/playbooks/tenant.yml \
    -e "tenant_name=tenant1 tenant_username=t1admin tenant_password=abc network_name=t1net subnet_name=t1subnet subnet_cidr=2.2.2.0/24 tunnel_id=3"

    $ ansible controller --user vagrant --inventory-file ${VARO}/hosts \
      --private-key ${VARO}/vagrant_private_key -m command -a \
      "nova --os-username {{ admin_tenant_user }} --os-tenant-name {{ admin_tenant }} \
      --os-password {{ admin_pass }} --os-auth-url http://127.0.0.1:5000/v2.0 \
      flavor-create m1.nano 42 64 0 1"

    $ ansible-playbook -v --user vagrant --inventory-file ${VARO}/hosts --private-key ${VARO}/vagrant_private_key \
    ansible-redhat-openstack/playbooks/vm.yml \
    -e "tenant_name=tenant1 tenant_username=t1admin tenant_password=abc network_name=t1net vm_name=t1vm flavor_id=42 keypair_name=t1keypair image_name=cirros"


Note: if the VM appears to be stuck in state spawning, it is because there is keypair and metadata injection happening. The instance eventually came up after 10 minutes, but ansible reported "msg: Timeout waiting for the server to come up.. Please check manually"


Note: the playbooks are actually using the ${VARO}/group_vars/all because of the inventory file setting, whereas site.yml uses the one in ansible-redhat-openstack/.

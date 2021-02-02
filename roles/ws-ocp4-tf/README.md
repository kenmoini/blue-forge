OpenShift Workshop Deployer
=========

This role will deploy an environment to the IBM Cloud as follows:

- 1 Bastion Host that serves Red Hat IdM/FreeIPA and serves as the bootstrap node otherwise
- 1 or 3 OpenShift Control Plane Nodes
- N OpenShift Application Nodes, 0 or at least 2

Other additional assets it can deploy:

- 3 OpenShift Infrastructure Nodes
- GitLab Instance
- Minio for S3
- NFS Server and CSI

The order of operations is as such:

- Create VPC, Security Groups, other needed basics
- Create boostrap node, copy over assets and configure
- Create OpenShift Nodes, configure cluster
- Set bootstrap node to serve RH IDM, configure cluster IdP
- Deploy other additional assets

Requirements
------------

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

Role Variables
--------------

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).

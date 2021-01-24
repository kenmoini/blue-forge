DNSNB - DNS Net Bind
=========

Workshop environments often rely on internal DNS servers, however they need to be forwarded to from a root DNS zone available on the public Internet.  DNSNB helps create that bridge.

Supports AWS Route53 and DigitalOcean DNS.

Requirements
------------

Either:

- An AWS Account with a Route53 Zone, Programatic IAM User with IAM policies required to create/edit/delete R53 assets.
- A DigitalOcean account with an associated Domain, Personal Access Token with Write access.

Role Variables
--------------

```yaml
# dns_provider: aws | digitalocean
dnsnb_provider: aws

# AWS Variables
dnsnb_aws_access_key: AKIAYLOLWTFHAXBBQYF7
dnsnb_aws_secret_key: someReallyReallyReallyReallyLongString

# DigitalOcean Variables
dnsnb_do_pat: someReallyReallyReallyReallyLongString

# Glue Variables
## Assumptions:
##   - Persistent Zone in Provider is ibm.kemo.network
##   - Two internal DNS Servers are serving lol42.ibm.kemo.network to resolve FQDNs such as bastion.lol42.ibm.kemo.network

# dnsnb_persistent_zone: The domain zone being delegated from
dnsnb_persistent_zone: ibm.kemo.network

# dnsnb_delegated_zone: The subdomain zone being served from the internal DNS servers
dnsnb_delegated_zone: lol42

# dnsnb_custom_nameservers: list of mapped entries for internal DNS servers
dnsnb_custom_nameservers:
  - name: ns1-k8s101-lol42
    ip: 150.1.2.31
  - name: ns2-k8s101-lol42
    ip: 150.1.2.32

```

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

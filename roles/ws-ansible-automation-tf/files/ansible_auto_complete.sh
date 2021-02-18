#!/bin/bash

register-python-argcomplete ansible > /etc/bash_completion.d/python-ansible
register-python-argcomplete ansible-config > /etc/bash_completion.d/python-ansible-config
register-python-argcomplete ansible-console > /etc/bash_completion.d/python-ansible-console
register-python-argcomplete ansible-doc > /etc/bash_completion.d/python-ansible-doc
register-python-argcomplete ansible-galaxy > /etc/bash_completion.d/python-ansible-galaxy
register-python-argcomplete ansible-inventory > /etc/bash_completion.d/python-ansible-inventory
register-python-argcomplete ansible-playbook > /etc/bash_completion.d/python-ansible-playbook
register-python-argcomplete ansible-pull > /etc/bash_completion.d/python-ansible-pull
register-python-argcomplete ansible-vault > /etc/bash_completion.d/python-ansible-vault

chmod +x /etc/bash_completion.d/python-ansible*
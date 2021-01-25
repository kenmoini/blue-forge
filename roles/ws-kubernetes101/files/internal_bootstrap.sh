#!/bin/bash

## Update system
dnf update -y

## Enable Ansible
dnf install -y python3 python3-pip

## Install Ansible
pip3 install ansible

## Run Bootstraping Playbook
nohup ansible-playbook -i /opt/workshop_assets/ansible_inventory /opt/workshop_assets/internal_bootstrap.yml &>/dev/null &
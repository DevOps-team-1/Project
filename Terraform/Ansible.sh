#!/bin/bash
apt update
apt install apache2
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
ansible-galaxy collection install community.mysql
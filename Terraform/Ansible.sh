#!/bin/bash
apt update
apt install apache2 -y
sudo apt install software-properties-common -y
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y
ansible-galaxy collection install community.mysql

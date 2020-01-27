nginx-cerbot-multi
=========

Configure nginx sites using Ansible.

I use this ansible-playbook to configure multi-sites servers serving different projects on different subdomains. The projects should be listed in vars.yml.

Requirements
------------

CentOS 7.x
ansible >= 2.2

Role Variables
--------------

You'll need to define hostnames, type of connections and admin email for certs.

---
# vars file for nginx_role
nginx_host:
  - name: "web1.example.com" ## vhost listen only 80 port
    type: "http"
  - name: "web2.example.com" ## vhost listen only 443 port
    type: "https"
    email: "admin@exemple.com"
  - name: "web3.example.com" ## redirect from 80 to 443 port
    type: "redirect"
    email: "admin@exemple.com"


Dependencies
------------

Example Playbook
----------------

---
- name: ec2
  hosts: centos
  become: yes
  gather_facts: yes

  roles:
    - nginx_role

License
-------

BSD

Author Information
------------------

Anton Pakhomov
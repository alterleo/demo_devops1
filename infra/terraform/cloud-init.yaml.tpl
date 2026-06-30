#cloud-config
users:
  - name: ubuntu
    ssh-authorized-keys:
      - ${ssh_public_key}
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    passwd: "${user_passwd}"
    lock_passwd: false
hostname: ${vm_name}
manage_etc_hosts: true
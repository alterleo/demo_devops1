#cloud-config
users:
  - name: ubuntu
    ssh-authorized-keys:
      - ${ssh_public_key}
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    passwd: "$6$9sIHT6UEhq8uoYt9$amMMN7o45123d9l/IqX0noWeupd8EYkx7wDATfq.VyHwPTg.aEkymR2ogoaLkxX2Aq4kqMc5jho6wAJac1WhI."
    lock_passwd: false
hostname: ${vm_name}
manage_etc_hosts: true
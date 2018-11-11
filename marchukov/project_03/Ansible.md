# Windows

alias cyg-get="/cygdrive/e/cygwin64/setup-x86_64.exe -q -P"

cyg-get cygwin32-gcc-g++ gcc-core gcc-g++ git libffi-devel nano openssl openssl-devel python-crypto python2 python2-devel python2-openssl python2-pip python2-setuptools tree

pip install ansible


https://cloud.google.com/solutions/ansible-with-spinnaker-tutorial

# Ubuntu

https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-ansible-on-ubuntu-16-04#prerequisites

sudo nano /etc/ansible/hosts

instance-2.europe-west1-b.c.agile-splicer-218512.internal
instance-3.europe-west2-c.c.agile-splicer-218512.internal
instance-4.europe-west2-c.c.agile-splicer-218512.internal


sudo mkdir /etc/ansible/group_vars
sudo nano /etc/ansible/group_vars/all

---
ansible_ssh_user: ansible



sudo adduser ansible
sudo usermod -aG sudo ansible

sudo visudo

ansible ALL=(ALL) NOPASSWD: ALL

sudo su - ansible
mkdir ~/.ssh
chmod 700 ~/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8wQyR2YOd8ylC2sl71toCtmXMXZd38hof5BFQwKNJlPzhKZZvPE2jrLNg7zqvmIAG6gjVd+YY145V+GM/9yVkPl9sysgxn3JfXQ+vK7tDpe3O4Y5GdrxbGaL/ATtZEssi866/cVJIIGoUpBt7MJUBV9D034d5JcfVfLNUFeeJYwm/3GWsCUjrbKvUS0mwCwaD3+WWeiuvX7bTCJblbiOvNE3NVMMXKIsCkc9ldr8ijIoxOuwgmzJRleQzzkilA/oY6rD2mu8TVXaT4xbQH4fJH33bg9T+GvWpKtGV40WixRkZwIhHWb+66ZBdrLfyIeb1BpVe6ZoWvyDqMh108p7H deadman2000@instance-1" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
exit

Подключаемся ко всем и добавляем сертификат

ssh ansible@instance-2.europe-west1-b.c.agile-splicer-218512.internal
ssh ansible@instance-3.europe-west2-c.c.agile-splicer-218512.internal
ssh ansible@instance-4.europe-west2-c.c.agile-splicer-218512.internal

ansible -m ping all

ansible -m shell -a 'free -m' all

Проверяем, что работает sudo:

$ ansible all -m command -a "whoami" -b

instance-2.europe-west1-b.c.agile-splicer-218512.internal | CHANGED | rc=0 >>
root

instance-3.europe-west2-c.c.agile-splicer-218512.internal | CHANGED | rc=0 >>
root

instance-4.europe-west2-c.c.agile-splicer-218512.internal | CHANGED | rc=0 >>
root


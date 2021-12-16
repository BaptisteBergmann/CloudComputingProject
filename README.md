# CloudComputingProject
This is a cloud project for the log8415 class

## Main instance
Commands to install:

# Terraform

$ curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
$ sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
$ sudo apt install terraform
$ terraform version

# Ansible
I install them by the ubuntu packet manager instead of pip to be able to easy update it

$ sudo apt update
$ sudo apt install software-properties-common
$ sudo add-apt-repository --yes --update ppa:ansible/ansible
$ sudo apt install ansible
## Ressources
https://ankush-chavan.medium.com/integrating-ansible-with-terraform-to-make-a-powerful-infrastructure-50795c36f78b
https://www.scottyfullstack.com/blog/devops-01-aws-terraform-ansible-jenkins-and-docker/


TF_DIR=terraform
ANSIBLE_DIR=ansible
TFVARS?=environments/data_science_lab.tfvars
PLAYBOOK?=site.yml
ANSIBLE_ENV=ANSIBLE_CONFIG=$(ANSIBLE_DIR)/ansible.cfg ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote

.PHONY: init plan apply destroy inventory ping configure

init:
	terraform -chdir=$(TF_DIR) init
	ansible-galaxy collection install -r $(ANSIBLE_DIR)/requirements.yml

plan:
	terraform -chdir=$(TF_DIR) plan -var-file=$(TFVARS)

apply:
	terraform -chdir=$(TF_DIR) apply -var-file=$(TFVARS)

destroy:
	terraform -chdir=$(TF_DIR) destroy -var-file=$(TFVARS)

inventory:
	$(ANSIBLE_ENV) ansible-inventory -i $(ANSIBLE_DIR)/inventory/openstack.yml --graph

ping:
	$(ANSIBLE_ENV) ansible all -i $(ANSIBLE_DIR)/inventory/openstack.yml -m ping

configure:
	$(ANSIBLE_ENV) ansible-playbook -i $(ANSIBLE_DIR)/inventory/openstack.yml $(ANSIBLE_DIR)/$(PLAYBOOK)

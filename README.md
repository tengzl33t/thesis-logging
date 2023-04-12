# Log Aggregation Solution Repository

## Provisioning (run from "terraform" dir):
1. `terraform init`
2. `terraform apply -var-file=do_main.tfvars`
3. `ansible-galaxy collection install cloud.terraform`
4. `ansible-playbook -i ansible/inventory.yaml ansible/infra.yaml`

## Dev:
All the instances are created with Terraform (+ Ansible) run only. 
Each instance (Loki and Vector) are running Docker with appropriate containers.
### Names:
- loki.company.internal
- vector.company.internal

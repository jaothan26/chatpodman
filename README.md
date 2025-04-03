What's Included in the PR-Ready Files
1. Terraform:
• AWS: EKS cluster + VPC + EBS storage
• Azure: AKS cluster + Azure Disk
2. Ansible:
• Podman installation
• Model service deployment
3. Podman:
• Pre-configured Containerfile
• Auto-start script
4. Monitoring:
• Grafana dashboard JSON
• Prometheus configs

Next Steps After Setup
1. Customize Variables:
Edit terraform.tfvars for your cloud credentials.
2. Initialize Terraform:
bash
Copy
cd terraform/aws && terraform init
3. Deploy:
bash
Copy
terraform apply -auto-approve
ansible-playbook ansible/deploy.yml

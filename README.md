# Secure AWS VPC Architecture with Public & Private Subnets

**Day 7: Secure VPC Setup with EC2 Instances** — complete, production-style lab implementing a secure two-tier VPC with public/private subnets, routing, NACLs, security groups, IAM roles, EC2 instances, SSH key-based access, and validation scripts.

Repository: [VU21CSEN0100380/Secure-AWS-VPC-Architecture-with-Public-Private-Subnets](https://github.com/VU21CSEN0100380/Secure-AWS-VPC-Architecture-with-Public-Private-Subnets)

## What this project delivers

| Day 7 objective | Status | Location |
|-----------------|--------|----------|
| VPC with custom CIDR, subnets, route tables | Done | `terraform/vpc.tf`, `route_tables.tf` |
| Network ACLs (inbound/outbound control) | Done | `terraform/nacls.tf` |
| Security groups for EC2 | Done | `terraform/security_groups.tf` |
| EC2 in public and private subnets | Done | `terraform/ec2.tf` |
| IAM roles for instances | Done | `terraform/iam.tf` |
| Internet Gateway + NAT Gateway | Done | `terraform/vpc.tf` |
| SSH key pair (generated, stored locally) | Done | `terraform/key_pair.tf` |
| Test and validate connectivity | Done | `scripts/validate-connectivity.*` |

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for diagrams and security rationale.

## Architecture (summary)

```
Internet → IGW → Public subnets (EC2 bastion) → NAT → Private subnets (EC2 app)
```

- **VPC CIDR:** `10.0.0.0/16`
- **Public subnets:** `10.0.1.0/24`, `10.0.2.0/24`
- **Private subnets:** `10.0.10.0/24`, `10.0.11.0/24`
- **SSH:** Only to public instance from `allowed_ssh_cidr`; private instance accepts SSH only from the public security group.

## Prerequisites

- [AWS CLI](https://aws.amazon.com/cli/) configured (`aws configure` or SSO)
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- OpenSSH client (Windows 10+ includes OpenSSH)
- AWS account with permissions for VPC, EC2, IAM, EIP, NAT Gateway

**Estimated cost:** NAT Gateway ~$0.045/hr + data transfer; two `t3.micro` instances. Run `terraform destroy` when finished.

## Quick start (Terraform)

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars — set allowed_ssh_cidr to YOUR public IP/32

terraform init
terraform plan
terraform apply
```

After apply:

```bash
# View connection commands
terraform output ssh_public_instance
terraform output ssh_private_via_bastion

# Run automated validation (PowerShell)
..\scripts\validate-connectivity.ps1

# Or Bash
bash ../scripts/validate-connectivity.sh
```

### Manual SSH examples

```bash
# Public instance
ssh -i terraform/keys/secure-vpc-day7-key.pem ec2-user@<PUBLIC_IP>

# Private via bastion (ProxyJump)
ssh -i terraform/keys/secure-vpc-day7-key.pem -J ec2-user@<PUBLIC_IP> ec2-user@<PRIVATE_IP>
```

## Validation checklist (Day 7)

- [ ] SSH into **public** EC2 with the generated `.pem` key only
- [ ] From public instance, `ping` private instance private IP
- [ ] From public instance, `curl` private instance (HTTP)
- [ ] SSH into **private** instance via bastion (ProxyJump)
- [ ] On private instance, `curl https://aws.amazon.com` (proves NAT outbound)
- [ ] Confirm public instance has no route to private except via VPC CIDR
- [ ] Review security group: private allows SSH only from public SG
- [ ] Review NACL rules in AWS Console vs `terraform/nacls.tf`

## Console-only deployment

If you prefer the AWS Console, follow [docs/MANUAL-CONSOLE-GUIDE.md](docs/MANUAL-CONSOLE-GUIDE.md).

## Project structure

```
.
├── terraform/
│   ├── vpc.tf              # VPC, subnets, IGW, NAT, EIP
│   ├── route_tables.tf     # Public/private routing
│   ├── nacls.tf            # Network ACLs
│   ├── security_groups.tf  # Instance security groups
│   ├── iam.tf              # EC2 IAM role & instance profile
│   ├── key_pair.tf         # SSH key generation
│   ├── ec2.tf              # Public & private instances
│   ├── variables.tf
│   ├── outputs.tf
│   └── keys/               # Private key written here (gitignored)
├── scripts/
│   ├── validate-connectivity.ps1
│   └── validate-connectivity.sh
└── docs/
    ├── ARCHITECTURE.md
    └── MANUAL-CONSOLE-GUIDE.md
```

## Teardown

```bash
cd terraform
terraform destroy
```

## Security notes

- Never commit `*.pem` or `terraform.tfvars` with secrets.
- Restrict `allowed_ssh_cidr` to your IP in production.
- Rotate or delete the key pair after the lab if the private key was exposed.

## Author

Day 7 AWS networking lab — secure VPC with EC2, IAM, and layered network controls.

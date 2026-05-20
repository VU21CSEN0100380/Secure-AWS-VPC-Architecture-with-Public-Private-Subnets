# Architecture — Day 7 Secure VPC with EC2

## Overview

This project implements a **two-tier VPC** with public and private subnets, layered security (NACLs + security groups), IAM instance roles, and EC2 instances for hands-on validation.

## Network diagram

```
                         Internet
                             |
                    +--------+--------+
                    | Internet Gateway |
                    +--------+--------+
                             |
              +--------------+--------------+
              |     Public Subnets          |
              |  10.0.1.0/24  10.0.2.0/24   |
              |  (AZ-a)       (AZ-b)        |
              |       + NAT Gateway         |
              |       + Public EC2 (SSH)    |
              +--------------+--------------+
                             |
              +--------------+--------------+
              |     Private Subnets         |
              |  10.0.10.0/24 10.0.11.0/24  |
              |  (AZ-a)        (AZ-b)       |
              |       + Private EC2         |
              +--------------+--------------+
                             |
                    Outbound 0.0.0.0/0
                         via NAT only
```

## Day 7 requirements mapping

| Requirement | Implementation |
|-------------|----------------|
| VPC with custom CIDR | `10.0.0.0/16` in `terraform/vpc.tf` |
| Public & private subnets | Two subnets per tier across AZs |
| Route tables | Public → IGW; Private → NAT |
| NACLs | Separate public/private NACLs in `nacls.tf` |
| Security groups | Instance-level rules in `security_groups.tf` |
| EC2 in both subnets | `aws_instance.public` and `aws_instance.private` |
| IAM roles | `AmazonSSMManagedInstanceCore` + read-only EC2 describe |
| Internet Gateway | `aws_internet_gateway.main` |
| NAT Gateway | `aws_nat_gateway.main` in first public subnet |
| SSH key pair | TLS key + `aws_key_pair`, PEM saved under `terraform/keys/` |
| Testing | `scripts/validate-connectivity.ps1` and `.sh` |

## Security model

**Defense in depth**

1. **NACLs** — Subnet-level allow/deny (stateless).
2. **Security groups** — Instance-level stateful rules.
3. **Private subnet** — No public IP; SSH only from public SG.
4. **IAM** — No long-lived keys on instances; role for SSM and describe APIs.
5. **IMDSv2** — Required on both instances.

**SSH access path**

- Internet → public EC2 (port 22, restricted by `allowed_ssh_cidr`).
- Public EC2 → private EC2 (port 22, security group reference only).

## Cost note

NAT Gateway incurs hourly and data processing charges. Set `enable_nat_gateway = false` in `terraform.tfvars` for lab teardown drills (private outbound tests will fail).

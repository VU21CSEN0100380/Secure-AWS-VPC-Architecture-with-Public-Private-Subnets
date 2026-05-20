# Manual AWS Console Guide (Day 7)

Use this checklist if you deploy via the AWS Console instead of Terraform. Values match the Terraform defaults.

## 1. VPC and subnets

1. **VPC** → Create VPC → `10.0.0.0/16`, name `secure-vpc-day7-dev-vpc`.
2. **Subnets** (enable DNS hostnames on VPC):
   - Public: `10.0.1.0/24` (AZ-a), `10.0.2.0/24` (AZ-b), auto-assign public IPv4.
   - Private: `10.0.10.0/24`, `10.0.11.0/24`.

## 2. Internet and NAT

1. **Internet Gateway** → attach to VPC.
2. **Elastic IP** → allocate for NAT.
3. **NAT Gateway** → place in **public subnet AZ-a**, attach EIP.

## 3. Route tables

| Route table | Association | Routes |
|-------------|-------------|--------|
| Public RT | Both public subnets | `0.0.0.0/0` → IGW |
| Private RT | Both private subnets | `0.0.0.0/0` → NAT GW |

## 4. Network ACLs

Create custom NACLs (see `terraform/nacls.tf` for rule numbers):

- **Public NACL**: inbound 22/80/443 + ephemeral; outbound all.
- **Private NACL**: inbound VPC CIDR + SSH from `10.0.1.0/24`; outbound 80/443 + ephemeral.

## 5. Security groups

- **public-ec2-sg**: SSH from your IP, HTTP/HTTPS from internet, egress all.
- **private-ec2-sg**: SSH **only** from public-ec2-sg, ICMP from VPC, egress all.

## 6. IAM

1. Role trusted entity: **EC2**.
2. Attach: `AmazonSSMManagedInstanceCore`.
3. Add inline policy for `ec2:Describe*` (see `terraform/iam.tf`).
4. Create **instance profile** and attach to both instances.

## 7. SSH key pair

1. EC2 → Key Pairs → Create → download `.pem`, `chmod 400`.
2. Store securely; never commit to Git.

## 8. EC2 instances

| Instance | Subnet | Public IP | SG | IAM profile | Key |
|----------|--------|-----------|-----|-------------|-----|
| public-ec2 | Public AZ-a | Yes | public-ec2-sg | ec2 profile | your key |
| private-ec2 | Private AZ-a | No | private-ec2-sg | ec2 profile | your key |

AMI: **Amazon Linux 2023**. Enable **IMDSv2 required**. Encrypt root volume.

## 9. Validation

1. `ssh -i key.pem ec2-user@<public-ip>`
2. From public: `ping <private-ip>`, `curl http://<private-ip>/`
3. SSH private: `ssh -J ec2-user@<public-ip> ec2-user@<private-ip>`
4. On private: `curl https://aws.amazon.com` (NAT outbound)

## 10. Cleanup

Terminate instances → delete NAT → release EIP → detach/delete IGW → delete subnets → delete VPC → delete key pair (optional).

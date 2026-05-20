#!/usr/bin/env bash
# Day 7 validation script (run after terraform apply)
set -euo pipefail

TERRAFORM_DIR="${1:-$(cd "$(dirname "$0")/../terraform" && pwd)}"
cd "$TERRAFORM_DIR"

PUBLIC_IP=$(terraform output -raw public_ec2_public_ip)
PRIVATE_IP=$(terraform output -raw private_ec2_private_ip)
KEY_PATH=$(terraform output -raw private_key_path)
chmod 600 "$KEY_PATH"

SSH_OPTS=(-i "$KEY_PATH" -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15)

echo "=== Day 7 Connectivity Validation ==="
echo "Public instance:  $PUBLIC_IP"
echo "Private instance: $PRIVATE_IP"
echo ""

echo "[1/4] SSH to public instance..."
ssh "${SSH_OPTS[@]}" "ec2-user@${PUBLIC_IP}" "hostname && curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1/"

echo "[2/4] Ping private from public..."
ssh "${SSH_OPTS[@]}" "ec2-user@${PUBLIC_IP}" "ping -c 3 ${PRIVATE_IP}"

echo "[3/4] Curl private from public..."
ssh "${SSH_OPTS[@]}" "ec2-user@${PUBLIC_IP}" "curl -s --connect-timeout 5 http://${PRIVATE_IP}:8080/ || curl -s http://${PRIVATE_IP}/"

echo "[4/4] Private outbound via NAT..."
ssh "${SSH_OPTS[@]}" -J "ec2-user@${PUBLIC_IP}" "ec2-user@${PRIVATE_IP}" "curl -s -o /dev/null -w '%{http_code}\n' https://aws.amazon.com"

echo ""
echo "All validation steps completed."

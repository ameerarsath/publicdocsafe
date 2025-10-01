#!/bin/bash

# Simple DocSafe EC2 Deployment Script
# Fixed version for requirements folder structure

set -e

echo "🚀 Starting DocSafe EC2 Deployment..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Update system
print_status "Updating system..."
sudo yum update -y

# Install Docker
print_status "Installing Docker..."
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Install Docker Compose
print_status "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Apply docker group
newgrp docker

# Go to docsafe directory
cd /opt/docsafe-review/docsafe

# Navigate to docker config
cd config/docker

# Stop existing containers
print_status "Stopping existing containers..."
sudo docker-compose -f docker-compose.review.yml down 2>/dev/null || true

# Get EC2 IP
EC2_IP=$(curl -s ifconfig.me 2>/dev/null || echo "your-ec2-ip")
print_status "EC2 IP: $EC2_IP"

# Update IP in docker-compose
sed -i "s/your-ec2-ip/$EC2_IP/g" docker-compose.review.yml

# Build and start
print_status "Building and starting containers..."
sudo docker-compose -f docker-compose.review.yml up -d --build

# Wait
print_status "Waiting for services..."
sleep 60

# Check status
print_status "Container status:"
sudo docker-compose -f docker-compose.review.yml ps

# Setup admin user
cd ../..
print_status "Setting up admin user..."
chmod +x scripts/setup-review-admin-amazon-linux.sh
./scripts/setup-review-admin-amazon-linux.sh

echo ""
echo "✅ Deployment complete!"
echo "Frontend: http://$EC2_IP:3000"
echo "Backend: http://$EC2_IP:8000/docs"
echo ""
echo "Login: rahumana / TestPass123@"
#!/bin/bash

# DocSafe EC2 Review Deployment Script for Amazon Linux
# This script deploys DocSafe on EC2 (Amazon Linux) for customer review

set -e

echo "🚀 Starting DocSafe Review Deployment on Amazon Linux EC2..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root"
    exit 1
fi

# Update system (Amazon Linux uses yum)
print_status "Updating system packages..."
sudo yum update -y

# Install required packages
print_status "Installing required packages..."
sudo yum install -y git curl wget unzip

# Install Docker (Amazon Linux)
print_status "Installing Docker..."
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Install Docker Compose
print_status "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create application directory
print_status "Creating application directory..."
sudo mkdir -p /opt/docsafe-review
sudo chown ec2-user:ec2-user /opt/docsafe-review
cd /opt/docsafe-review

# Check if repository is already cloned
if [ ! -d "docsafe" ]; then
    print_status "Cloning DocSafe repository..."
    # Replace with your actual repository URL
    git clone https://github.com/your-username/docsafe.git
    cd docsafe
else
    print_status "Repository already exists, pulling latest changes..."
    cd docsafe
    git pull origin main
fi

# Navigate to docker config
cd config/docker

# Stop any existing containers
print_status "Stopping any existing containers..."
sudo docker-compose -f docker-compose.review.yml down 2>/dev/null || true

# Update EC2 IP in configuration
EC2_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s checkip.amazonaws.com 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null || echo "your-ec2-ip")
print_status "Detected EC2 IP: $EC2_IP"

# Update the docker-compose file with actual EC2 IP
sed -i "s/your-ec2-ip/$EC2_IP/g" docker-compose.review.yml

# Build and start containers
print_status "Building and starting DocSafe containers..."
sudo docker-compose -f docker-compose.review.yml up -d --build

# Wait for services to be ready
print_status "Waiting for services to start..."
sleep 60

# Check container status
print_status "Checking container status..."
sudo docker-compose -f docker-compose.review.yml ps

# Setup admin user
print_status "Setting up admin user..."
cd ../../
chmod +x scripts/setup-review-admin.sh
./scripts/setup-review-admin.sh

print_status "🎉 Deployment completed successfully!"
echo ""
echo "==================================="
echo "📋 Deployment Summary"
echo "==================================="
echo "🌐 Frontend URL: http://$EC2_IP:3000"
echo "🔧 Backend API: http://$EC2_IP:8000"
echo "📚 API Docs: http://$EC2_IP:8000/docs"
echo ""
echo "📝 Default Test Credentials:"
echo "   Username: rahumana"
echo "   Password: TestPass123@"
echo "   Encryption Password: JHNpAZ39g!&Y"
echo ""
echo "🔍 Useful Commands:"
echo "   View logs: sudo docker-compose -f config/docker/docker-compose.review.yml logs -f"
echo "   Stop app: sudo docker-compose -f config/docker/docker-compose.review.yml down"
echo "   Restart app: sudo docker-compose -f config/docker/docker-compose.review.yml restart"
echo ""
echo "📱 Next Steps:"
echo "1. Open http://$EC2_IP:3000 in your browser"
echo "2. Login with the test credentials above"
echo "3. Test the application features"
echo ""
print_warning "Important Security Notes:"
print_warning "1. This is a REVIEW deployment - NOT for production"
print_warning "2. Change default passwords before deployment"
print_warning "3. Configure proper firewall rules in AWS EC2 Security Group"
print_warning "4. Set up HTTPS for real deployment"

# Instructions for updating security group
echo ""
print_status "To update your EC2 Security Group:"
echo "1. Go to AWS EC2 Console > Security Groups"
echo "2. Select your instance's security group"
echo "3. Add inbound rules:"
echo "   - Port 3000 (HTTP) from 0.0.0.0/0"
echo "   - Port 8000 (HTTP) from 0.0.0.0/0"
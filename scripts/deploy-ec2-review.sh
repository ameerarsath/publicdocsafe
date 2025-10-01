#!/bin/bash

# DocSafe EC2 Review Deployment Script
# This script deploys DocSafe on EC2 for customer review

set -e

echo "🚀 Starting DocSafe Review Deployment on EC2..."

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

# Update system
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker
print_status "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
print_status "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create application directory
print_status "Creating application directory..."
sudo mkdir -p /opt/docsafe-review
sudo chown $USER:$USER /opt/docsafe-review
cd /opt/docsafe-review

# Clone the repository (replace with your repo URL)
print_warning "Please ensure you have cloned your DocSafe repository to /opt/docsafe-review"
print_status "Current directory: $(pwd)"

# Navigate to docker config
cd config/docker

# Stop any existing containers
print_status "Stopping any existing containers..."
docker-compose -f docker-compose.review.yml down 2>/dev/null || true

# Build and start containers
print_status "Building and starting DocSafe containers..."
docker-compose -f docker-compose.review.yml up -d --build

# Wait for services to be ready
print_status "Waiting for services to start..."
sleep 30

# Check container status
print_status "Checking container status..."
docker-compose -f docker-compose.review.yml ps

# Get EC2 public IP
EC2_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null || echo "your-ec2-ip")

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
echo "   View logs: docker-compose -f docker-compose.review.yml logs -f"
echo "   Stop app: docker-compose -f docker-compose.review.yml down"
echo "   Restart app: docker-compose -f docker-compose.review.yml restart"
echo ""
print_warning "Important Security Notes:"
print_warning "1. This is a REVIEW deployment - NOT for production"
print_warning "2. Change default passwords before deployment"
print_warning "3. Configure proper firewall rules"
print_warning "4. Set up HTTPS for real deployment"
print_warning "5. Review and update CORS settings with your EC2 IP"

# Instructions for manual IP update
echo ""
print_status "To update your EC2 IP in the configuration:"
echo "1. Edit config/docker/docker-compose.review.yml"
echo "2. Replace 'your-ec2-ip' with: $EC2_IP"
echo "3. Restart containers: docker-compose -f docker-compose.review.yml down && docker-compose -f docker-compose.review.yml up -d"
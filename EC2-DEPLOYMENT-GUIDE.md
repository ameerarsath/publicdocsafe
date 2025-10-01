# DocSafe EC2 Customer Review Deployment Guide

This guide provides step-by-step instructions for deploying DocSafe on an AWS EC2 instance for customer review.

## Quick Start

### 1. Launch EC2 Instance

1. **Go to AWS EC2 Console**
   - Region: Choose nearest to your customers
   - AMI: Ubuntu 22.04 LTS
   - Instance Type: t3.medium (recommended) or t2.large
   - Security Group: Allow ports 22 (SSH), 3000 (Frontend), 8000 (Backend)

2. **Configure Security Group**
   ```
   Port 22: SSH (Your IP only)
   Port 3000: HTTP (Frontend - 0.0.0.0/0 for customer access)
   Port 8000: HTTP (Backend API - 0.0.0.0/0 for customer access)
   ```

3. **Launch and Connect**
   - Download the .pem key file
   - Connect to your instance:
     ```bash
     chmod 400 your-key.pem
     ssh -i your-key.pem ubuntu@your-ec2-public-ip
     ```

### 2. Deploy the Application

#### Option A: Automated Deployment (Recommended)

```bash
# Clone your repository
git clone https://github.com/your-username/docsafe.git
cd docsafe

# Make deployment script executable
chmod +x scripts/deploy-ec2-review.sh

# Run deployment
./scripts/deploy-ec2-review.sh
```

#### Option B: Manual Deployment

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Clone repository
git clone https://github.com/your-username/docsafe.git
cd docsafe/config/docker

# Update EC2 IP in docker-compose.review.yml
# Replace 'your-ec2-ip' with your actual EC2 public IP

# Start the application
docker-compose -f docker-compose.review.yml up -d --build
```

### 3. Setup Admin User

```bash
# Navigate to your docsafe directory
cd /path/to/docsafe

# Make setup script executable
chmod +x scripts/setup-review-admin.sh

# Run admin setup
./scripts/setup-review-admin.sh
```

### 4. Access the Application

- **Frontend**: http://your-ec2-ip:3000
- **Backend API**: http://your-ec2-ip:8000
- **API Documentation**: http://your-ec2-ip:8000/docs

### Test Credentials
- **Username**: rahumana
- **Password**: TestPass123@
- **Encryption Password**: JHNpAZ39g!&Y

## Common Commands

```bash
# View application logs
docker-compose -f docker-compose.review.yml logs -f

# Stop the application
docker-compose -f docker-compose.review.yml down

# Restart the application
docker-compose -f docker-compose.review.yml restart

# Check container status
docker-compose -f docker-compose.review.yml ps

# Access database
docker exec -it docsafe_review_db psql -U docsafe_user -d docsafe_review
```

## Troubleshooting

### Container Not Starting
```bash
# Check logs for specific service
docker-compose -f docker-compose.review.yml logs backend
docker-compose -f docker-compose-review.yml logs frontend
```

### Database Connection Issues
```bash
# Check if database is ready
docker exec docsafe_review_db pg_isready -U docsafe_user -d docsafe_review

# Reset database (WARNING: This will delete all data)
docker-compose -f docker-compose.review.yml down -v
docker-compose -f docker-compose.review.yml up -d db
```

### Permission Issues
```bash
# Ensure user is in docker group
sudo usermod -aG docker $USER
newgrp docker

# Fix file permissions
sudo chown -R $USER:$USER /opt/docsafe-review
```

## Security Considerations for Review

This deployment is configured for customer review, **NOT** for production:

1. **Weak Passwords**: Default passwords are used - change them!
2. **HTTP Only**: No HTTPS configured
3. **Open Ports**: All ports accessible from anywhere
4. **No Backup**: Data loss on instance termination
5. **No Monitoring**: Basic logging only

## Production Readiness

To make this production-ready:
1. Add HTTPS with valid SSL certificate
2. Implement proper firewall rules
3. Use secrets management (AWS Secrets Manager)
4. Add database backups
5. Implement monitoring and logging
6. Use AWS RDS instead of containerized PostgreSQL
7. Add auto-scaling and load balancing

## Support

If you encounter any issues:
1. Check the logs using the commands above
2. Ensure all ports are open in security group
3. Verify EC2 has sufficient resources (min 2GB RAM)
4. Check Docker and Docker Compose versions
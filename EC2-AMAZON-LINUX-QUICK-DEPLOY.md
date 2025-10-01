# Quick Deployment on Amazon Linux EC2

You're using Amazon Linux 2. Use this guide for quick deployment.

## One-Command Deployment

### 1. Connect to EC2
```bash
ssh -i your-key.pem ec2-user@your-ec2-ip
```

### 2. Deploy DocSafe
```bash
# Clone repository
git clone <your-repo-url>
cd docsafe

# Make script executable
chmod +x scripts/deploy-ec2-review-amazon-linux.sh

# Run deployment
./scripts/deploy-ec2-review-amazon-linux.sh
```

### 3. Access Application
- **Frontend**: http://your-ec2-ip:3000
- **Backend**: http://your-ec2-ip:8000/docs

### Test Credentials
- **Username**: rahumana
- **Password**: TestPass123@
- **Encryption Password**: JHNpAZ39g!&Y

## Key Differences from Ubuntu

| Feature | Ubuntu | Amazon Linux 2 |
|---------|--------|----------------|
| User | ubuntu | ec2-user |
| Package Manager | apt | yum |
| Docker | script install | yum install docker |
| Service Commands | systemctl | systemctl |

## Security Group Setup

1. Go to EC2 Console → Security Groups
2. Select your instance's security group
3. Add inbound rules:
   - Port 22: SSH (Your IP)
   - Port 3000: HTTP (0.0.0.0/0)
   - Port 8000: HTTP (0.0.0.0/0)

## Common Issues

### Docker Permission Denied
```bash
# Add user to docker group
sudo usermod -aG docker ec2-user
# Logout and login again or run:
newgrp docker
```

### Container Build Fails
```bash
# Check available memory
free -h
# If < 2GB, upgrade instance type
```

### Can't Access Application
```bash
# Check security group rules
# Check if containers are running
sudo docker ps

# Check logs
sudo docker logs docsafe_review_frontend
sudo docker logs docsafe_review_backend
```

## Manual Steps (if script fails)

```bash
# Install Docker manually
sudo yum update -y
sudo yum install -y docker git
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Clone and run
git clone <your-repo-url>
cd docsafe/config/docker
sudo docker-compose -f docker-compose.review.yml up -d --build
```

## Support

The script automatically:
- ✅ Updates the EC2 IP in configuration
- ✅ Installs Docker and Docker Compose
- ✅ Builds and starts all containers
- ✅ Creates admin user with super admin privileges

If you encounter issues, check the logs with:
```bash
sudo docker-compose -f config/docker/docker-compose.review.yml logs -f
```
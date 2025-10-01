#!/bin/bash

# Setup admin user for DocSafe review deployment

set -e

echo "🔧 Setting up admin user for DocSafe Review..."

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 20

# Check if database container is running
if ! docker ps | grep -q docsafe_review_db; then
    echo "❌ Database container is not running!"
    echo "Please ensure the application is deployed first."
    exit 1
fi

# Copy SQL script to container
docker cp scripts/create-review-admin.sql docsafe_review_db:/tmp/create-review-admin.sql

# Execute the SQL script
echo "🔐 Creating admin user..."
docker exec docsafe_review_db psql -U docsafe_user -d docsafe_review -f /tmp/create-review-admin.sql

echo ""
echo "✅ Admin user setup completed!"
echo ""
echo "📋 Login Details:"
echo "   URL: http://$(curl -s ifconfig.me 2>/dev/null || echo "your-ec2-ip"):3000"
echo "   Username: rahumana"
echo "   Password: TestPass123@"
echo "   Role: Super Admin"
echo ""
echo "🔑 Encryption Password for testing: JHNpAZ39g!&Y"
echo ""
echo "⚠️  Please change these passwords in a real deployment!"
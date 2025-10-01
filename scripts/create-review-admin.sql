-- Create admin user for review deployment
-- Run this script in PostgreSQL after deployment

-- Connect to the database first:
-- docker exec -it docsafe_review_db psql -U docsafe_user -d docsafe_review

-- Create admin user with encrypted password
INSERT INTO users (
    username,
    email,
    hashed_password,
    full_name,
    is_active,
    is_superuser,
    is_verified,
    created_at,
    updated_at
) VALUES (
    'rahumana',
    'admin@docsafe-review.com',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj6hsxq9w5GS', -- TestPass123@
    'DocSafe Admin',
    true,
    true,
    true,
    NOW(),
    NOW()
) ON CONFLICT (username) DO NOTHING;

-- Assign Admin role
INSERT INTO user_roles (
    user_id,
    role_id,
    assigned_by,
    assigned_at
) VALUES (
    (SELECT id FROM users WHERE username = 'rahumana'),
    (SELECT id FROM roles WHERE name = 'Admin'),
    (SELECT id FROM users WHERE username = 'rahumana'),
    NOW()
) ON CONFLICT (user_id, role_id) DO NOTHING;

-- Grant all permissions to Admin role (if not already set)
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.name = 'Admin'
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- Verify admin user creation
SELECT
    u.username,
    u.email,
    u.is_superuser,
    r.name as role_name
FROM users u
JOIN user_roles ur ON u.id = ur.user_id
JOIN roles r ON ur.role_id = r.id
WHERE u.username = 'rahumana';

PRINT 'Admin user "rahumana" has been created successfully!';
PRINT 'Login credentials:';
PRINT 'Username: rahumana';
PRINT 'Password: TestPass123@';
-- Fetch the user by email to verify the password hash and determine their role
SELECT user_id, username, password_hash, role 
FROM Users 
WHERE email = '?';
-- Create users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    mail TEXT UNIQUE,
    avatar TEXT,  -- URL or path to avatar image
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster email lookups
CREATE INDEX idx_users_mail ON users(mail);

-- Add updated_at trigger
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policy (adjust based on your auth requirements)
CREATE POLICY "Enable all operations for authenticated users" 
    ON users
    FOR ALL 
    USING (true) 
    WITH CHECK (true);

-- Grant permissions
GRANT ALL ON users TO postgres, anon, authenticated, service_role;



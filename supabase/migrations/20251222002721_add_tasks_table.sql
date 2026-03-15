-- Create task status enum
CREATE TYPE task_status AS ENUM ('open', 'inprogress', 'done', 'waiting');

-- Create tasks table
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    assignee UUID REFERENCES users(id) ON DELETE SET NULL,
    deadline DATE,
    haushalt_id UUID REFERENCES haushalte(id) ON DELETE CASCADE,
    status task_status DEFAULT 'open',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX idx_tasks_assignee ON tasks(assignee);
CREATE INDEX idx_tasks_haushalt_id ON tasks(haushalt_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_deadline ON tasks(deadline);

-- Add updated_at trigger
CREATE TRIGGER update_tasks_updated_at 
    BEFORE UPDATE ON tasks
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Create policy (adjust based on your auth requirements)
CREATE POLICY "Enable all operations for authenticated users" 
    ON tasks
    FOR ALL 
    USING (true) 
    WITH CHECK (true);

-- Grant permissions
GRANT ALL ON tasks TO postgres, anon, authenticated, service_role;



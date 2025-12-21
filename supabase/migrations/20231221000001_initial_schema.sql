-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create Haushalte (Households) table
CREATE TABLE haushalte (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    haus TEXT NOT NULL UNIQUE,
    bemerkung TEXT,
    pipeline_status TEXT,
    tasks TEXT,
    vermietet BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Personen (People) table
CREATE TABLE personen (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    email TEXT,
    telefonnummer TEXT,
    haushalt_id UUID REFERENCES haushalte(id) ON DELETE SET NULL,
    haushalt_address TEXT, -- Store the address string from CSV for reference
    notizen TEXT,
    vermietet TEXT, -- Can be empty or contain address
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX idx_personen_haushalt_id ON personen(haushalt_id);
CREATE INDEX idx_personen_email ON personen(email);
CREATE INDEX idx_haushalte_haus ON haushalte(haus);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add triggers for updated_at
CREATE TRIGGER update_haushalte_updated_at BEFORE UPDATE ON haushalte
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_personen_updated_at BEFORE UPDATE ON personen
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE haushalte ENABLE ROW LEVEL SECURITY;
ALTER TABLE personen ENABLE ROW LEVEL SECURITY;

-- Create policies (adjust based on your auth requirements)
-- For now, allow all operations - you can restrict this later
CREATE POLICY "Enable all operations for authenticated users" ON haushalte
    FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Enable all operations for authenticated users" ON personen
    FOR ALL USING (true) WITH CHECK (true);

-- Grant permissions to postgres roles
GRANT ALL ON haushalte TO postgres, anon, authenticated, service_role;
GRANT ALL ON personen TO postgres, anon, authenticated, service_role;


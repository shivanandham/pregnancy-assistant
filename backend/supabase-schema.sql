-- Supabase PostgreSQL Schema for Pregnancy Assistant
-- Run this in your Supabase SQL editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- User profiles table
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  height REAL,
  weight REAL,
  pre_pregnancy_weight REAL,
  age INTEGER,
  gender TEXT DEFAULT 'female',
  locality TEXT,
  timezone TEXT,
  medical_history JSONB,
  allergies JSONB,
  medications JSONB,
  lifestyle JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Pregnancy data table
CREATE TABLE IF NOT EXISTS pregnancy_data (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  due_date DATE NOT NULL,
  last_menstrual_period DATE NOT NULL,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Symptoms table
CREATE TABLE IF NOT EXISTS symptoms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  type TEXT NOT NULL,
  severity TEXT NOT NULL,
  date_time TIMESTAMP WITH TIME ZONE NOT NULL,
  notes TEXT,
  custom_type TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Appointments table
CREATE TABLE IF NOT EXISTS appointments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  type TEXT NOT NULL,
  date_time TIMESTAMP WITH TIME ZONE NOT NULL,
  location TEXT,
  doctor TEXT,
  notes TEXT,
  is_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Weight entries table
CREATE TABLE IF NOT EXISTS weight_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  weight REAL NOT NULL,
  date_time TIMESTAMP WITH TIME ZONE NOT NULL,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Chat messages table
CREATE TABLE IF NOT EXISTS chat_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  content TEXT NOT NULL,
  type TEXT NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  context TEXT,
  is_error BOOLEAN DEFAULT FALSE,
  is_diagnostic BOOLEAN DEFAULT FALSE,
  diagnostic_questions JSONB,
  diagnostic_answers JSONB,
  parent_message_id UUID REFERENCES chat_messages(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Knowledge facts table
CREATE TABLE IF NOT EXISTS knowledge_facts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  category TEXT NOT NULL,
  fact_text TEXT NOT NULL,
  source_message_id UUID,
  week_number INTEGER,
  date_recorded DATE DEFAULT CURRENT_DATE,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Conversation chunks table
CREATE TABLE IF NOT EXISTS conversation_chunks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  content TEXT NOT NULL,
  week_number INTEGER,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  keywords TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_symptoms_date_time ON symptoms(date_time);
CREATE INDEX IF NOT EXISTS idx_appointments_date_time ON appointments(date_time);
CREATE INDEX IF NOT EXISTS idx_weight_entries_date_time ON weight_entries(date_time);
CREATE INDEX IF NOT EXISTS idx_chat_messages_timestamp ON chat_messages(timestamp);
CREATE INDEX IF NOT EXISTS idx_knowledge_facts_category ON knowledge_facts(category);
CREATE INDEX IF NOT EXISTS idx_knowledge_facts_week ON knowledge_facts(week_number);
CREATE INDEX IF NOT EXISTS idx_conversation_chunks_week ON conversation_chunks(week_number);

-- Create full-text search indexes
CREATE INDEX IF NOT EXISTS idx_knowledge_facts_search ON knowledge_facts USING gin(to_tsvector('english', fact_text));
CREATE INDEX IF NOT EXISTS idx_conversation_chunks_search ON conversation_chunks USING gin(to_tsvector('english', content));

-- Enable Row Level Security (RLS) - optional for single-user app
-- ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE pregnancy_data ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE symptoms ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE weight_entries ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE knowledge_facts ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE conversation_chunks ENABLE ROW LEVEL SECURITY;

-- Create policies for RLS (if enabled)
-- CREATE POLICY "Allow all operations" ON user_profiles FOR ALL USING (true);
-- CREATE POLICY "Allow all operations" ON pregnancy_data FOR ALL USING (true);
-- CREATE POLICY "Allow all operations" ON symptoms FOR ALL USING (true);
-- CREATE POLICY "Allow all operations" ON appointments FOR ALL USING (true);
-- CREATE POLICY "Allow all operations" ON weight_entries FOR ALL USING (true);
-- CREATE POLICY "Allow all operations" ON chat_messages FOR ALL USING (true);
-- CREATE POLICY "Allow all operations" ON knowledge_facts FOR ALL USING (true);
-- CREATE POLICY "Allow all operations" ON conversation_chunks FOR ALL USING (true);

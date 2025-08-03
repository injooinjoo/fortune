-- Create todos table
CREATE TABLE IF NOT EXISTS public.todos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL CHECK (char_length(title) >= 1 AND char_length(title) <= 200),
    description TEXT CHECK (char_length(description) <= 1000),
    priority TEXT NOT NULL DEFAULT 'medium' CHECK (priority IN ('high', 'medium', 'low')),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'inProgress', 'completed')),
    due_date TIMESTAMP WITH TIME ZONE,
    tags TEXT[] DEFAULT '{}',
    is_deleted BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_todos_user_id ON public.todos(user_id);
CREATE INDEX idx_todos_status ON public.todos(status);
CREATE INDEX idx_todos_priority ON public.todos(priority);
CREATE INDEX idx_todos_due_date ON public.todos(due_date);
CREATE INDEX idx_todos_is_deleted ON public.todos(is_deleted);
CREATE INDEX idx_todos_created_at ON public.todos(created_at);

-- Create GIN index for tags array search
CREATE INDEX idx_todos_tags ON public.todos USING GIN (tags);

-- Create text search index for title and description
CREATE INDEX idx_todos_search ON public.todos USING GIN (
    to_tsvector('english', coalesce(title, '') || ' ' || coalesce(description, ''))
);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_todos_updated_at 
    BEFORE UPDATE ON public.todos 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE public.todos ENABLE ROW LEVEL SECURITY;

-- Create policies for Row Level Security
-- Users can only view their own todos
CREATE POLICY "Users can view own todos" 
    ON public.todos 
    FOR SELECT 
    USING (auth.uid() = user_id AND is_deleted = false);

-- Users can only insert their own todos
CREATE POLICY "Users can insert own todos" 
    ON public.todos 
    FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Users can only update their own todos
CREATE POLICY "Users can update own todos" 
    ON public.todos 
    FOR UPDATE 
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Users can only delete their own todos (soft delete)
CREATE POLICY "Users can delete own todos" 
    ON public.todos 
    FOR UPDATE 
    USING (auth.uid() = user_id AND is_deleted = false)
    WITH CHECK (auth.uid() = user_id AND is_deleted = true);

-- Create function to validate tags array
CREATE OR REPLACE FUNCTION validate_tags_array()
RETURNS TRIGGER AS $$
BEGIN
    -- Ensure tags array has no more than 10 elements
    IF array_length(NEW.tags, 1) > 10 THEN
        RAISE EXCEPTION 'Tags array cannot have more than 10 elements';
    END IF;
    
    -- Ensure each tag is not longer than 50 characters
    FOR i IN 1..array_length(NEW.tags, 1) LOOP
        IF char_length(NEW.tags[i]) > 50 THEN
            RAISE EXCEPTION 'Each tag must be 50 characters or less';
        END IF;
    END LOOP;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER validate_tags_before_insert_or_update
    BEFORE INSERT OR UPDATE ON public.todos
    FOR EACH ROW
    EXECUTE FUNCTION validate_tags_array();

-- Create function to get todo statistics
CREATE OR REPLACE FUNCTION get_todo_stats(p_user_id UUID)
RETURNS TABLE (
    status TEXT,
    count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.status,
        COUNT(*)::BIGINT
    FROM public.todos t
    WHERE t.user_id = p_user_id 
        AND t.is_deleted = false
    GROUP BY t.status;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_todo_stats(UUID) TO authenticated;
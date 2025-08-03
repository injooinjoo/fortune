# TODO 테이블 마이그레이션 가이드

## Supabase 대시보드를 통한 마이그레이션

### 1. Supabase 대시보드 접속
- URL: https://supabase.com/dashboard
- 프로젝트: `hayjukwfcsdmppairazc` (Fortune Flutter)

### 2. SQL Editor 실행
1. 왼쪽 메뉴에서 "SQL Editor" 클릭
2. "New query" 버튼 클릭
3. 아래 SQL 코드 복사하여 붙여넣기

### 3. TODO 테이블 생성 SQL
```sql
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
```

### 4. SQL 실행
1. "Run" 버튼 클릭
2. 성공 메시지 확인

### 5. 테이블 확인
1. 왼쪽 메뉴에서 "Table Editor" 클릭
2. "todos" 테이블이 생성되었는지 확인
3. RLS 정책이 활성화되었는지 확인 (자물쇠 아이콘)

## 테이블 구조
- **id**: UUID (Primary Key)
- **user_id**: UUID (Foreign Key to auth.users)
- **title**: TEXT (1-200 characters)
- **description**: TEXT (max 1000 characters)
- **priority**: TEXT ('high', 'medium', 'low')
- **status**: TEXT ('pending', 'inProgress', 'completed')
- **due_date**: TIMESTAMP WITH TIME ZONE
- **tags**: TEXT[] (max 10 tags, each max 50 chars)
- **is_deleted**: BOOLEAN (soft delete)
- **created_at**: TIMESTAMP WITH TIME ZONE
- **updated_at**: TIMESTAMP WITH TIME ZONE

## 보안 기능
1. **Row Level Security (RLS)**: 사용자는 자신의 TODO만 접근 가능
2. **입력 검증**: 제목, 설명, 태그 길이 제한
3. **Soft Delete**: 실제 삭제 대신 is_deleted 플래그 사용
4. **자동 타임스탬프**: created_at, updated_at 자동 관리

## 테스트 방법
1. Flutter 앱 실행: `flutter run -d chrome`
2. 로그인 후 TODO 페이지 접속
3. TODO 생성, 수정, 삭제 테스트
4. 필터링 및 검색 기능 테스트
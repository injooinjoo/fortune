import psycopg2
import os
import sys
from urllib.parse import urlparse

# Connection details
DATABASE_URL = "postgresql://postgres.kfkdsoyrcgsgkjhwkcin:vf8gO4yb3hUYgNWh@aws-0-ap-northeast-2.pooler.supabase.co:6543/postgres"

# Alternative connections to try
ALTERNATIVE_URLS = [
    "postgresql://postgres.kfkdsoyrcgsgkjhwkcin:vf8gO4yb3hUYgNWh@db.kfkdsoyrcgsgkjhwkcin.supabase.co:5432/postgres",
    "postgresql://postgres.kfkdsoyrcgsgkjhwkcin:vf8gO4yb3hUYgNWh@aws-0-ap-northeast-2.pooler.supabase.co:5432/postgres"
]

def try_connection(connection_string):
    """Try to connect to the database with given connection string"""
    try:
        print(f"Trying connection: {connection_string}")
        conn = psycopg2.connect(connection_string)
        cursor = conn.cursor()
        cursor.execute("SELECT version();")
        version = cursor.fetchone()
        print(f"✅ Connection successful! PostgreSQL version: {version[0]}")
        return conn
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        return None

def execute_sql_file(conn, sql_file_path):
    """Execute SQL file in chunks for better error handling"""
    try:
        with open(sql_file_path, 'r', encoding='utf-8') as file:
            sql_content = file.read()
        
        cursor = conn.cursor()
        
        # Check current count before
        cursor.execute("SELECT COUNT(*) FROM public.celebrities;")
        initial_count = cursor.fetchone()[0]
        print(f"Initial celebrity count: {initial_count}")
        
        print("Executing SQL file...")
        print(f"SQL file size: {len(sql_content)} characters")
        
        # Split SQL into individual statements
        statements = [stmt.strip() for stmt in sql_content.split(';') if stmt.strip()]
        
        successful_statements = 0
        failed_statements = 0
        
        for i, statement in enumerate(statements):
            if not statement:
                continue
                
            try:
                cursor.execute(statement + ';')
                successful_statements += 1
                
                if i % 50 == 0:  # Progress update every 50 statements
                    print(f"Progress: {i}/{len(statements)} statements processed")
                    
            except Exception as e:
                failed_statements += 1
                print(f"⚠️  Statement {i} failed: {e}")
                print(f"Statement: {statement[:200]}...")
                
                # Continue with other statements
                conn.rollback()
        
        # Commit all successful transactions
        conn.commit()
        
        # Check final count
        cursor.execute("SELECT COUNT(*) FROM public.celebrities;")
        final_count = cursor.fetchone()[0]
        
        print(f"\n📊 Upload Summary:")
        print(f"Initial count: {initial_count}")
        print(f"Final count: {final_count}")
        print(f"Added: {final_count - initial_count}")
        print(f"Successful statements: {successful_statements}")
        print(f"Failed statements: {failed_statements}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error executing SQL file: {e}")
        conn.rollback()
        return False

def main():
    sql_file_path = "/Users/jacobmac/Desktop/Dev/fortune/celebrity_saju_mega_final.sql"
    
    if not os.path.exists(sql_file_path):
        print(f"❌ SQL file not found: {sql_file_path}")
        return
    
    # Try main connection first
    conn = try_connection(DATABASE_URL)
    
    # If main connection fails, try alternatives
    if not conn:
        print("\nTrying alternative connection strings...")
        for alt_url in ALTERNATIVE_URLS:
            conn = try_connection(alt_url)
            if conn:
                break
    
    if not conn:
        print("❌ All connection attempts failed.")
        print("\nPlease verify your Supabase connection details:")
        print("1. Check your project settings in Supabase dashboard")
        print("2. Ensure database is active and not paused")
        print("3. Verify the correct hostname format")
        print("4. Check if IP is whitelisted (if applicable)")
        return
    
    try:
        # Execute the SQL file
        success = execute_sql_file(conn, sql_file_path)
        
        if success:
            print("✅ Celebrity data upload completed successfully!")
        else:
            print("❌ Celebrity data upload failed.")
            
    finally:
        conn.close()
        print("Database connection closed.")

if __name__ == "__main__":
    main()
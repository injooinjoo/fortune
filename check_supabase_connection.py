import socket
import requests
import json
import os
import sys

def check_hostname(hostname):
    """Check if hostname resolves"""
    try:
        ip = socket.gethostbyname(hostname)
        print(f"✅ {hostname} resolves to: {ip}")
        return True
    except socket.gaierror as e:
        print(f"❌ {hostname} does not resolve: {e}")
        return False

def check_supabase_api(project_ref, anon_key=None):
    """Check if Supabase project is accessible via REST API"""
    try:
        url = f"https://{project_ref}.supabase.co/rest/v1/"
        headers = {}
        
        if anon_key:
            headers['apikey'] = anon_key
            headers['Authorization'] = f'Bearer {anon_key}'
        
        response = requests.get(url, headers=headers, timeout=10)
        print(f"✅ Supabase API accessible: {response.status_code}")
        return True
    except Exception as e:
        print(f"❌ Supabase API not accessible: {e}")
        return False

def test_common_hostname_formats(project_ref):
    """Test common Supabase hostname formats"""
    print("🔍 Testing common hostname formats...")
    
    hostnames_to_try = [
        f"db.{project_ref}.supabase.co",
        f"aws-0-ap-northeast-2.pooler.supabase.co",
        f"aws-0-us-east-1.pooler.supabase.co",
        f"aws-0-us-west-2.pooler.supabase.co", 
        f"aws-0-eu-west-1.pooler.supabase.co",
        f"{project_ref}.supabase.co",
        f"pg.{project_ref}.supabase.co"
    ]
    
    working_hosts = []
    
    for hostname in hostnames_to_try:
        if check_hostname(hostname):
            working_hosts.append(hostname)
    
    return working_hosts

def get_project_info():
    """Extract project info from connection details"""
    project_ref = "kfkdsoyrcgsgkjhwkcin"
    print(f"📋 Extracted project reference: {project_ref}")
    return project_ref

def main():
    print("🔍 Supabase Connection Diagnostics")
    print("=" * 50)
    
    # Get project info
    project_ref = get_project_info()
    
    # Test hostname resolution
    print("\n1. Testing hostname resolution...")
    working_hosts = test_common_hostname_formats(project_ref)
    
    if working_hosts:
        print(f"\n✅ Found working hostnames:")
        for host in working_hosts:
            print(f"   - {host}")
    else:
        print(f"\n❌ No hostnames resolved successfully")
    
    # Test Supabase API
    print(f"\n2. Testing Supabase API accessibility...")
    check_supabase_api(project_ref)
    
    # Provide recommendations
    print(f"\n📝 Recommendations:")
    print(f"1. Go to your Supabase dashboard: https://supabase.com/dashboard")
    print(f"2. Navigate to your project settings")
    print(f"3. Go to Settings → Database")
    print(f"4. Look for 'Connection string' or 'Connection pooling'")
    print(f"5. Copy the exact hostname from there")
    print(f"6. Make sure your project is not paused")
    
    if working_hosts:
        print(f"\n🔧 Try these connection strings:")
        for host in working_hosts:
            conn_str = f"postgresql://postgres.{project_ref}:vf8gO4yb3hUYgNWh@{host}:5432/postgres"
            print(f"   {conn_str}")

if __name__ == "__main__":
    main()
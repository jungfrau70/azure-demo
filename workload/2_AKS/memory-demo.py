
cat > memory-demo.py <<EOF
import time
import requests

# Define your target URL
url = "http://google.com"

def send_requests():
    for _ in range(100):  # Adjust to the desired number of requests
        try:
            response = requests.get(url)
            print(f"Request completed with status: {response.status_code}")
        except requests.RequestException as e:
            print(f"Request failed: {e}")
        time.sleep(1)  # Adjust the sleep interval as necessary

if __name__ == "__main__":
    send_requests()
EOF

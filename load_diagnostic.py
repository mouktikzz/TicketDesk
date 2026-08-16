import concurrent.futures
import time
import requests
from collections import Counter

URL = "http://ticketdesk-alb-779410850.ap-south-1.elb.amazonaws.com/api/health"
USERS = 20
DURATION = 60

results = Counter()
start = time.time()

def request():
    try:
        r = requests.get(URL, timeout=10)
        return str(r.status_code)
    except Exception as e:
        return type(e).__name__ + ": " + str(e)

with concurrent.futures.ThreadPoolExecutor(max_workers=USERS) as executor:
    while time.time() - start < DURATION:
        futures = [executor.submit(request) for _ in range(USERS)]
        for f in futures:
            results[f.result()] += 1

print("\n========== ERROR DIAGNOSTICS ==========")
print(f"Concurrent users : {USERS}")
print(f"Duration          : {DURATION // 60} minute")
print(f"Total requests    : {sum(results.values())}")
print()

for result, count in results.most_common():
    print(f"{result}: {count}")

print("=======================================")

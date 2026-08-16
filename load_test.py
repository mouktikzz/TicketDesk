import concurrent.futures
import time
import requests
from collections import Counter

URL = "http://ticketdesk-alb-779410850.ap-south-1.elb.amazonaws.com/api/health"

USERS = 20
DURATION = 300

def user_session():
    results = Counter()

    session = requests.Session()

    while time.time() < end_time:
        try:
            response = session.get(URL, timeout=10)
            results[response.status_code] += 1
        except Exception as e:
            results[type(e).__name__] += 1

    session.close()
    return results


end_time = time.time() + DURATION

with concurrent.futures.ThreadPoolExecutor(max_workers=USERS) as executor:
    futures = [
        executor.submit(user_session)
        for _ in range(USERS)
    ]

    combined = Counter()

    for future in futures:
        combined.update(future.result())


total = sum(combined.values())
errors = total - combined.get(200, 0)

print()
print("========== LOAD TEST RESULT ==========")
print(f"Concurrent users : {USERS}")
print(f"Duration          : 5 minutes")
print(f"Total requests    : {total}")
print(f"Successful 200s   : {combined.get(200, 0)}")
print(f"Total errors      : {errors}")
print()

for result, count in combined.most_common():
    print(f"{result}: {count}")

print("======================================")

if errors == 0:
    print("PASS - No errors detected")
else:
    print("FAIL - Errors detected")

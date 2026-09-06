"""Run after daily_advice_pool_test.sql in a disposable PostgreSQL container."""
import concurrent.futures
import json
import subprocess
import sys

container = sys.argv[1]
network = subprocess.check_output(
    ['docker', 'inspect', '--format', '{{.HostConfig.NetworkMode}}', container], text=True,
).strip()
if network != 'none':
    raise SystemExit('This test requires a disposable container with --network none')


def query(sql):
    return subprocess.check_output(
        ['docker', 'exec', container, 'psql', '-U', 'postgres', '-v', 'ON_ERROR_STOP=1', '-qAt', '-c', sql],
        text=True,
    ).strip()


key = 'c' * 64
query(f"DELETE FROM public.daily_advice_pool WHERE condition_hash='{key}' AND prompt_version='concurrency-test'")
for sample in range(3):
    with concurrent.futures.ThreadPoolExecutor(max_workers=16) as workers:
        claims = list(workers.map(
            lambda _: json.loads(query(f"SET ROLE service_role; SELECT public.claim_daily_advice('{key}','concurrency-test')")),
            range(16),
        ))
    leases = [claim for claim in claims if claim['action'] == 'generate']
    assert len(leases) == 1, claims
    expected = 'busy' if sample == 0 else 'hit'
    assert sum(claim['action'] == expected for claim in claims) == 15, claims
    token = leases[0]['leaseToken']
    assert query(f"SELECT public.complete_daily_advice('{key}','concurrency-test','{token}','\"sample {sample}\"')") == 't'

with concurrent.futures.ThreadPoolExecutor(max_workers=16) as workers:
    claims = list(workers.map(
        lambda _: json.loads(query(f"SELECT public.claim_daily_advice('{key}','concurrency-test')")), range(16),
    ))
assert all(claim['action'] == 'hit' for claim in claims), claims
assert query(f"SELECT jsonb_array_length(variants)||':'||generation_count FROM public.daily_advice_pool WHERE condition_hash='{key}' AND prompt_version='concurrency-test'") == '3:3'
query(f"DELETE FROM public.daily_advice_pool WHERE condition_hash='{key}' AND prompt_version='concurrency-test'")
print('64 concurrent requests: exactly 3 generation leases; warm pool uses DB only')

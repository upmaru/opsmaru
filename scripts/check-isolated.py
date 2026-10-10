"""Run scaffold checks in a disposable loopback PostgreSQL cluster, never host data."""
import os
from pathlib import Path
import socket
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
def run(*args, **kwargs):
    return subprocess.run(['mise', 'exec', '--', *args], cwd=root, check=True, **kwargs)

with tempfile.TemporaryDirectory(prefix='opsmaru-pg-') as directory:
    cluster = Path(directory)
    with socket.socket() as sock:
        sock.bind(('127.0.0.1', 0))
        port = sock.getsockname()[1]
    run('initdb', '-D', str(cluster/'data'), '-U', 'opsmaru_fixture', '-A', 'trust', '--no-locale', '--encoding=UTF8', stdout=subprocess.DEVNULL)
    run('pg_ctl', '-D', str(cluster/'data'), '-l', str(cluster/'postgres.log'), '-o', f'-h 127.0.0.1 -p {port} -k {cluster}', '-w', 'start')
    env = os.environ.copy()
    for key in ['DATABASE_URL','PHX_SERVER','PORT','OPSMARU_MODE','MIX_ENV','MIX_TEST_PARTITION']:
        env.pop(key, None)
    env.update(OPSMARU_DATABASE_HOST='127.0.0.1', OPSMARU_DATABASE_PORT=str(port), OPSMARU_DATABASE_USER='opsmaru_fixture', OPSMARU_DATABASE_PASSWORD='')
    try:
        subprocess.run(['mise','run','check'], cwd=root, env=env, check=True)
    finally:
        run('pg_ctl', '-D', str(cluster/'data'), '-m', 'fast', '-w', 'stop')

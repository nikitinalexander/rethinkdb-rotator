from rethinkdb import RethinkDB
import os
r = RethinkDB()

host = os.getenv('RETHINKDB_HOST').strip()
user = os.getenv('RETHINKDB_USER').strip()
password = os.getenv('RETHINKDB_PASSWORD').strip()

with open('password.txt') as f:
    client_password = f.read()
client_password = client_password.strip()

conn = r.connect(host=host,
                 user=user,
                 password=password)

r.db("rethinkdb").table("users").insert({"id":"client", "password": client_password}).run(conn)
r.grant("client", { "read": True, "write": True, "config": True, "connect":  True}).run(conn)
r.db('rethinkdb').grant("client", { "read": True, "write": True, "config": True}).run(conn)
r.db("rethinkdb").table("users").get("client").update({"password": client_password}).run(conn)
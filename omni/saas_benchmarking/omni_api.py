#!/usr/bin/env python3
"""
Omni REST API helper for the SaaS benchmarking demo.

Auth: set OMNI_API_TOKEN in the environment (do NOT hardcode/commit it).
  export OMNI_API_TOKEN=omni_osk_xxx   # rotate the one shared in chat

Verified facts baked in:
  BASE  = https://omni.demo.exploreomni.dev
  MODEL = bbfe630c-... ("Extension Models", default DB ANALYTICS_PROD)
  Tables live in ANALYTICS_PROD.SAAS; views are saas__<table>.
  Created workbook: identifier 7f4fa0cc, workbook-model id d0e62ea8-...

API gotchas (learned the hard way):
  - POST /api/v1/query/run : modelId goes INSIDE the `query` object.
    Add top-level resultType:"json"+formatResults:true for clean JSON rows
    (otherwise the response is NDJSON with a base64 Arrow `result`).
  - Raw-SQL tile in a document queryPresentation:
      query.userEditedSQL=<sql>, query.rewriteSql=false, topicName=null (NOT ""),
      query.fields = UPPERCASE SQL aliases. Plain table tiles omit visConfig/chartType.
  - POST /api/v1/documents body: {modelId,name,description,queryPresentations:[...],
      filterConfig:{},filterOrder:[],controls:[]}. Response has workbook.identifier.
  - Workbook-scoped views/measures/joins/topics are NOT writable via the API
    (UI/IDE only). Use a branch of the shared model, or field-browser dialogs.

Usage:
  python3 omni_api.py sql "select 1 as N"
  python3 omni_api.py models
  python3 omni_api.py getdoc 7f4fa0cc
"""
import json, os, sys, urllib.request, urllib.error

BASE = "https://omni.demo.exploreomni.dev"
MODEL = "bbfe630c-a216-44b0-a0f8-c3e99cb98084"  # "Extension Models" shared model
WORKBOOK_MODEL = "d0e62ea8-774b-4954-97de-eccb8ae49b6c"
TOKEN = os.environ.get("OMNI_API_TOKEN")

def _h():
    if not TOKEN:
        sys.exit("Set OMNI_API_TOKEN in the environment first.")
    return {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"}

def get(path):
    req = urllib.request.Request(BASE+path, headers=_h(), method="GET")
    try:
        r = urllib.request.urlopen(req, timeout=120); return r.status, r.read().decode()
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()

def post(path, body):
    req = urllib.request.Request(BASE+path, data=json.dumps(body).encode(), headers=_h(), method="POST")
    try:
        r = urllib.request.urlopen(req, timeout=120); return r.status, r.read().decode()
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()

def run_sql(sql, limit=1000):
    body = {"query": {"modelId": MODEL, "table": "", "fields": [], "userEditedSQL": sql,
                      "limit": limit, "sorts": [], "filters": {}, "calculations": [],
                      "column_totals": {}, "row_totals": {}, "fill_fields": [], "pivots": [],
                      "rewriteSql": False},
            "resultType": "json", "formatResults": True}
    return post("/api/v1/query/run", body)

if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "help"
    if cmd == "sql":
        st, txt = run_sql(sys.argv[2], int(sys.argv[3]) if len(sys.argv) > 3 else 1000)
        print(st); print(txt[:5000])
    elif cmd == "models":
        st, txt = get("/api/v1/models?modelKind=SHARED&pageSize=100")
        print(st); print(txt[:4000])
    elif cmd == "getdoc":
        st, txt = get(f"/api/v1/documents/{sys.argv[2]}")
        print(st); print(txt[:4000])
    elif cmd == "modelyaml":
        st, txt = get(f"/api/v1/models/{sys.argv[2]}/yaml")
        print(st); print(txt[:4000])
    else:
        print(__doc__)

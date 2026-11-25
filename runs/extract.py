import json, sys
# print final result text + tool-call trace summary from a stream-json transcript
tools=[]; result=None; meta={}
for line in open(sys.argv[1]):
    try: m=json.loads(line)
    except: continue
    if m.get('type')=='assistant':
        for c in m['message'].get('content',[]):
            if c.get('type')=='tool_use':
                i=c['input']; tools.append(f"{c['name']}: {i.get('command') or i.get('file_path') or i.get('pattern') or ''}"[:200])
    if m.get('type')=='result':
        result=m.get('result'); meta={k:m.get(k) for k in ('duration_ms','num_turns','total_cost_usd','is_error')}
mode = sys.argv[2] if len(sys.argv)>2 else 'all'
if mode in ('all','tools'):
    print('--- TOOLS'); [print(' ',t) for t in tools]
if mode in ('all','result'):
    print('--- META', meta); print('--- RESULT'); print(result)

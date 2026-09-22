import hashlib,json,time
N=100000; threshold=85
agents=[{"id":i,"tzeruf_hash":hashlib.sha256(f"TNRL-AGENT-{i:06d}".encode()).hexdigest(),"capacity":85+(i%16),"active":True} for i in range(N)]
eligible=sum(a["active"] and a["capacity"]>=threshold for a in agents)
summary={"agent_count":N,"active_agents":N,"eligible_agents":eligible,"topology":{"cube_side":21,"nodes_per_population":21**3,"mirrored_populations":2,"simple_mirrored_total":2*(21**3)},"mode":"deterministic local simulation","timestamp":int(time.time())}
open("sim_100k_result.json","w").write(json.dumps(summary,indent=2));print(json.dumps(summary,indent=2))
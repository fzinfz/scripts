import warnings
warnings.simplefilter("ignore", UserWarning)

from colorama import Fore
import pandas as pd

import re

def parse_conf_text(s):        
    ''' "#[" will not be commentted '''
    rs = {}
    for m in [m for m in re.finditer('\[([^]]+)\]([^\[]+)', re.sub('#[^\[].*','', s) )]:
        items = [re.sub('\s*#.*','', l).strip() for l in m.group(2).strip().splitlines()]
        rs[m.group(1)] = [i for i in items if i]
    return rs


from collections import namedtuple
Server = namedtuple('Server', 'host port user')

def get_Server_from_line(s):
    g = re.search("^(\w+@)?([^:]+)(:\d+)?", s).groups()
    return Server(
        g[1],
        int(g[2][1:]) if g[2] else 22,
        g[0][:-1] if g[0] else 'root'
    )


import fabric2
from fabric2 import Connection
# from fabric2 import SerialGroup 
from fabric2 import ThreadingGroup as Group
from fabric2.exceptions import GroupException

def _append_GroupResult(GroupResult_list, pool, cmd_list, **kwargs):
    if len(pool) == 0: return GroupResult_list
    
    if type(cmd_list) == str:
        cmd_list = cmd_list.strip().splitlines()
        
    for cmd in cmd_list:
        try:
            GroupResult_list.append(pool.run(cmd, **kwargs))
        except GroupException as e:
            GroupResult_list.append(e.result)
            
    return GroupResult_list


def group_run(pool, cmd_list, **kwargs):    
    GroupResult_list = _append_GroupResult([], pool, 'hostname', **kwargs)
    #pool_work = Group.from_connections([c for c in pool if type(GroupResult_list[0].get(c)) == fabric.runners.Result])
    pool_work = Group.from_connections([c for c in pool if c.is_connected])    
    return _append_GroupResult(GroupResult_list, pool_work, cmd_list, **kwargs)


def _run_rs_to_dict_list(run_rs, splitlines=True):
    run_rs_list = []
    for rs in run_rs:
        for k,v in rs.items():
            item = {'Host': k.host}
            if type(v) == fabric2.runners.Result:
                d = vars(v)
                for k in ['command','exited']: 
                    item[k] = d[k]
                for k in ['stdout','stderr']: 
                    if splitlines: item[k] = d[k].strip().splitlines()
                    else:          item[k] = d[k].strip()
            else:
                item['ConnError'] = str(v)

            run_rs_list.append(item)

    return run_rs_list


def get_df_from_run_rs(run_rs):
    df = pd.DataFrame(_run_rs_to_dict_list(run_rs, splitlines=False)).fillna('')
    df = df.set_index('Host', append=True).sort_index(level=1).reset_index(level=1).sort_values(by=['command', 'Host'])    
    return df


def print_df(df):
    for i, r in df.iterrows():
        print(Fore.GREEN + r.Host + " : " + r.command + '\n' + Fore.RESET)
        print(r.stdout, '\n')    
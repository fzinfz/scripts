from ping3 import ping
import dask
import datetime, time
import json


def main(servers, threshold, sleep_time, verbose, addional_kwargs):

    servers = json.loads(servers.replace("'",'"'))
    print('servers =', servers)

    print('threshold =', threshold)
    print('sleep_time =', sleep_time)

    addional_kwargs = json.loads(addional_kwargs.replace("'",'"'))
    print('addional_kwargs =', addional_kwargs)

    while True:      
        ping_result = [dask.delayed(ping)(s, unit='ms', **addional_kwargs) for s in servers]
        ping_result = dask.compute(*ping_result)
        
        if None in ping_result or any( [ r>threshold for r in ping_result]):
            print(datetime.datetime.now().isoformat(), ping_result)
        time.sleep(sleep_time)


def parse_args():
    import argparse
    parser = argparse.ArgumentParser(description="ping monitoring", 
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('-s','--servers', type=str, default='["1.1.1.1","8.8.8.8"]', help='server list')
    parser.add_argument('-t','--threshold', type=int, default=3, help="when above threshold, print")
    parser.add_argument('-p','--sleep_time', type=int, default=1, help="sleep between every ping task")
    parser.add_argument("-k", "--addional_kwargs", default="{'timeout': 5}", help="https://github.com/kyan001/ping3")
    parser.add_argument("-v", "--verbose", action="store_true")
    return parser.parse_args()


if __name__ == '__main__':
    kwargs = vars(parse_args())
    main(**kwargs)    

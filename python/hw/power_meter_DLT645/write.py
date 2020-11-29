import time, sys, re

passwd = [0x04,0x11,0x11,0x11]  # most default
passwd = [0x04,0x00,0x00,0x00]

opid = [0x00,0x00,0x00,0x00]

# algorithms taken from: https://github.com/glx-technologies/meter-dlt645

def write_meter(chn, addr, cmd, data):
    payload = cmd + passwd + opid + data    
    chn.encode(addr, 0x14, payload)
    chn.xchg_data(verbose=1, retry=0)   

    
def str_to_bcd(text):
    print(text)
    rs = [ int(s, 16) for s in re.findall('..', text) ]
    print(rs)
    return rs
    
    
def change_date(chn, addr):
    new_date = str_to_bcd(time.strftime('%y%m%d', time.localtime())) + [0x00]
    cmd     = [0x01, 0x01, 0x00, 0x04]
    write_meter( chn, addr, cmd, list(reversed(new_date)) )
    
    
def change_time(chn, addr):
    t0 = time.time() + 1 # add 1s for the delay time
    new_time = str_to_bcd(time.strftime('%H%M%S', time.localtime(t0)))
    cmd     = [0x02, 0x01, 0x00, 0x04]
    write_meter( chn, addr, cmd, list(reversed(new_time)) )    

    
     
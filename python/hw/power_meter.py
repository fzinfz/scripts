import sys, re
import pprint

#                        （DI3~0, 整数位数，小数位数， 单位）
D1 = {
    
    '电能-组合有功总-当前':       ('00 00 00 00', 6, 2, 'kWh'),
    '电能-组合有功总-上结算日':       ('00 00 00 01', 6, 2, 'kWh'),
    
    'A相电压':             ('02 01 01 00', 3, 1, 'V'),    
    'A相电流':             ('02 02 01 00', 3, 3, 'A'),    
    '功率-瞬时总有功':      ('02 03 00 00', 2, 4, 'kW'),  
    '功率-一分钟有功总平均': ('02 80 00 03', 2, 4, 'kW'),
    
    '功率因数-总':           ('02 06 00 00', 1, 3, ''),  
    
    '表内温度':             ('02 80 00 07', 3, 1, '°C'),    
    '内部电池电压':          ('02 80 00 08', 2, 2, 'V'),    
    '内部电池工作时间':       ('02 80 00 0A', 8, 0, '分'), 
    
    '日期':                 ('04 00 01 01', 6, 2, '年月日.星期'),  
    '时间':                 ('04 00 01 02', 4, 2, 'hhmm.ss'),  
    '表号':                 ('04 00 04 02', 12, 0, '#'),  
    '每月第1结算日':         ('04 00 0B 01', 2, 2, '日.时'),  
    
}

D2 = {
      
    'B相电压':             ('02 01 02 00', 3, 1, 'V'),    
    'C相电压':             ('02 01 03 00', 3, 1, 'V'),    
     
    'B相电流':             ('02 02 02 00', 3, 3, 'A'), 
    'C相电流':             ('02 02 03 00', 3, 3, 'A'), 
       
    '功率-瞬时A相有功':       ('02 03 01 00', 2, 4, 'kW'),    
    '功率-瞬时B相有功':       ('02 03 02 00', 2, 4, 'kW'),    
    '功率-瞬时C相有功':       ('02 03 03 00', 2, 4, 'kW'),      
    
    '功率-瞬时总视在':       ('02 05 00 00', 2, 4, 'kVA'),    
    
    '零线电流':             ('02 80 00 01', 3, 3, 'A'),  
    '频率':                 ('02 80 00 02', 2, 2, 'Hz'),  
    
    '通信地址':             ('04 00 04 01', 12, 0, '#'),    
    
    '型号':                 ('04 00 04 0B', 20, 0, ''),  
    
    '状态字1':              ('04 00 05 01', 4, 0, 'int'),    
    '状态字2':              ('04 00 05 02', 4, 0, 'int'),    
    '状态字3':              ('04 00 05 03', 4, 0, 'int'),    
    '状态字4':              ('04 00 05 04', 4, 0, 'int'),    
    '状态字5':              ('04 00 05 05', 4, 0, 'int'),    
    '状态字6':              ('04 00 05 06', 4, 0, 'int'),    
    '状态字7':              ('04 00 05 07', 4, 0, 'int'),    
   
}

D = {**D1, **D2}
# D = D1

def read_chn(chn, addr, cmd, verbose = 0):
    chn.encode(addr, 0x11, cmd)
    chn.xchg_data(verbose)
    return chn.rx_payload


def get_data(chn, addr, item):
    d = D[item]    
    payload = read_chn( chn, addr, [ int(x, 16) for x in d[0].split(' ')[::-1] ] )
    
    len_whole, len_decimal = d[1], d[2]
    len_payload = int( (len_whole + len_decimal) / 2 )
    
    hex_str = ''.join([ "%02x" % x  for x in payload[::-1][:len_payload] ])
    try:
        value = int(hex_str) / pow(10, len_decimal)
    except ValueError:
        value = hex_str
        
    unit = d[3]
    return value, unit


def read_meter(chn, addr):
    
    result = {}

    for item in D:
        result[item] = get_data(chn, addr, item)

    # convert all 'kW' to 'W'
    for k, v in D.items():
        if v[3] == 'kW':
            result[k] = "{:,.2f}".format( result[k][0] * 1000 ) , 'W'   
    
    result['功率-A相'] = "{:,.2f}".format( result['A相电压'][0] * result['A相电流'][0] ) , 'W'
    result['电能:本周期'] = "{:,.2f}".format( 
        result['电能-组合有功总-当前'][0] - result['电能-组合有功总-上结算日'][0] ) , 'kWh'
    
    result['内部电池工作时间'] = "{:,.2f}".format( result['内部电池工作时间'][0] / (60*24) / 365 ), '年'

    for k, v in D.items():
        if v[3] == '#':
            result[k] = "{0:0>12d}".format(int(result[k][0])), ''   

    try:
        result['日期时间'] = '20' + str(result['日期'][0]).split('.')[0] + ' ' + \
             ':'.join( re.findall('..', "{0:0>6d}".format(int(result['时间'][0]*100))) ), ''
        del result['日期']
        del result['时间']
    except:
        pass
    
    return result


def read_meters(chn, meters):
    
    chn.open()

    result = {}
    for meter in meters:    
        print('\n', '='* 5, meter, '='* 5)
        addr_human =  meter[0]    
        addr = [ int(s,16) for s in re.findall('..', addr_human) ]
        rs = read_meter(chn, addr)
        pprint.pprint(rs)
        result[addr_human] = rs

    chn.close()    
    return result

j = []
for a in addresses:     
    del_keys = ['id','category','type']
    
    for k in del_keys:
        if k in a.keys():
            del a[k]
            
    if 'ad_info' in a.keys(): 
        addr_pre = a['ad_info']['province'] + a['ad_info']['city'] +  a['ad_info']['district']
        a.update(a['ad_info'])
        del a['ad_info']
    else:
        addr_pre =  a['province'] + a['city'] + a['district'] 
    
    a['address']= a['address'].replace(addr_pre,'')
    
    j.append(a)
j
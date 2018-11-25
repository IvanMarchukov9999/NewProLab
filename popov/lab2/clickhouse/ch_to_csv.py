import pandas as pd

from clickhouse_driver import Client

if __name__ == "__main__":
    client = Client('172.18.0.11')
    evnts = client.execute('select * from site.event')
    lables = ['detectedDuplicate','detectedCorruption','firstInSession','timestamp','clientTimestamp','remoteHost','referer','location','partyId','sessionId','pageViewId','eventType','basket_price','item_id','item_price','item_url','date']
    df = pd.DataFrame.from_records(evnts,columns=lables)
    df.to_csv('/home/toshich/site_events.csv',sep='\t',encoding='utf-8', index=False)
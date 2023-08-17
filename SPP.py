import requests #to ask  URL
import time
from termcolor import colored




#request from https://www.coinlore.com/cryptocurrency-data-api
req_coin=requests.get('https://api.coinlore.net/api/tickers/?start=0&limit=10')


print(colored('*************cryptocurrency data*************', 'green'))



for i in range(0,10):

    print(colored (req_coin.json()['data'][i]['rank'],'green'),'-', colored (req_coin.json()['data'][i]['nameid'], 'cyan'),"\t",colored (req_coin.json()['data'][i]['price_usd'],'magenta'))

    print(colored ('------------------------------------------' ,'blue'))

#zaman

current_time = time.asctime( time.localtime(time.time()) )

print (colored ("Local  time :",'yellow'),colored( current_time,'yellow'))
print (colored('###############################################','green'))
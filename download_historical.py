import ystockquote
import time
import os



ticker = 'GOOG'
start = '20020730'
end = '20120730'

ticker_array = ['ATVI','GKNT','INTC','OCZ','VMW','AAPL','GOOG','MSFT']

#os.system('rm data_dump.txt') # destroy the old data_dump.txt(if any)
    
for ticker_name in ticker_array:
    #filename = ticker_name
    #fileObj = open(filename,"w")
    current_data = ystockquote.get_historical_prices(ticker_name,start,end);
    #with open(ticker_name, 'a') as f:  # opens the file as f for ('a' for append)
        #f.write('\n%s'%(ticker_name))      # "with-open-as" closes the file for you also
    for c in current_data: 
        with open('./yearly_historical/'+ticker_name, 'a') as f:
            f.write('\n%s'%(c))
    #fileObj.close
# this is formatted to be human readable, but we could make it a JSON or something when 
# we want to really use it.

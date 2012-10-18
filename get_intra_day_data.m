function [intradata] = get_intra_day_data(interval,numDays,ticker)

% couldn't find a better way to do this t.t

urlwrite(['http://www.google.com/finance/getprices?i=' num2str(interval) '&p=' num2str(numDays) 'd&f=d,o,h,l,c,v&df=cpct&q=' ticker],['./intraday/' ticker '.csv']);
intradata = csvread(['./intraday/' ticker '.csv']);

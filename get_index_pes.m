% Get P/E's of Market Indices
% LuminousLogic.com

% In valuing an individual stock, it can be instructive to compare its P/E to
% that of a market index, such as the S&P 500.

% As the data for the indices themselves can be difficult to find, this function
% retrieves the P/E's for a variety of ETFs that closely track the indices.

% Note that it appears the source (Yahoo Finance) only updates this data monthly.


function [sp400_pe, sp500_pe, sp600_pe, dj_pe, djw5k_pe] = get_index_pes

for symbol = 1:5
    switch symbol
        case 1, ticker = 'MDY'; % S&P 400 (mid-cap US stocks)
        case 2, ticker = 'SPY'; % S&P 500 (large-cap US stocks)
        case 3, ticker = 'IJR'; % S&P 600 (small-cap US stocks)
        case 4, ticker = 'DIA'; % Dow Jones Industrial Average
        case 5, ticker = 'VTI'; % DJ Wilshire 5000 (entire US stock market)
    end


    % Open connection to Yahoo! Finance 
    url_name = strcat('http://finance.yahoo.com/q?s=',ticker);
    url     = java.net.URL(url_name);       % Construct a URL object
    is      = openStream(url);              % Open a connection to the URL
    isr     = java.io.InputStreamReader(is);
    br      = java.io.BufferedReader(isr);

    % Cycle through the source code until we get to P/E part...
    while 1
        line_buff = char(readLine(br));
        ptr       = strfind(line_buff, 'P/E <span class="small">(ttm)</span>');
       

        % ...And break when we find it
        if length(ptr) > 0,break; end

    end

    
    % Cut off the extra bits we don't care about
    line_buff = line_buff(ptr:ptr+100);
    
    
    % And extract the number
    ptr_gt     = strfind(line_buff,'>');
    ptr_lt     = strfind(line_buff,'<');
    pe(symbol) = str2num(line_buff(ptr_gt(4)+1:ptr_lt(5)-1));
    
    
    fprintf(1,'P/E for %s is %2.2f.\n',ticker,pe(symbol));
end

sp400_pe = pe(1); 
sp500_pe = pe(2);
sp600_pe = pe(3);
dj_pe    = pe(4);
djw5k_pe = pe(5);
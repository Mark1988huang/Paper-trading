clear all;
% Load input data
load file.mat
method=3; % 1 for moving average, 2 for MACD, 3 for GARCH and wavelets where
% gives a ‘buy’ signal for positive predicted values and ‘sell’ signal for
% negative values, 4 for the same with 3 but use moving average of
% predicted values, 5,6,7 and 8 the same with 1,2,3 and 4 respectively but
%for real application and not for testing or backtesting.
lag=50; % Define the length of moving average. Usually 10,20,30,50, 70,100 and
% 200 are used.
factor='e'; % 0 for simple, 0.5 for square root weighted moving average,
% 1 for linear moving average, 2 for square weighted moving average
% end 'e' for exponential
risk_free=0.001;
length_test=100; % length of sample for testing. This script is used for testing. If you
% wish to apply for future purposes set up the value of length_test=0
decomposition_tree=1; % lenght of decomposition tree
M=length_test; % length of predicted data
if method==1
    train_data=data(1:end-length_test-1,:);
    [Short,Long]=movavg(train_data,1,lag,factor);
    test_sample=data(end-length_test:end,:);
    test_long=Long(end-length_test-1:end,:);
    stock=data(end-length_test-1:end,:);
    [nk1,ni]=size(test_sample);
    for kk=1:nk1
        if test_sample(kk,:)>test_long(kk,:)
            s(kk,:)=1; % buy
        elseif test_sample(kk,:)<test_long(kk,:)
            
            s(kk,:)=-1; %sell
        end
    end
    for jj=2:nk1
        total(jj,:)=s(jj)*(stock(jj)-stock(jj-1))-0.001*(abs(s(jj)-s(jj-1))*stock(jj));
    end
    profit=sum(total);
    average=mean(total);
    standard_deviation=std(total);
    sharpe_ratio=(average)/standard_deviation;
elseif method==2
    train_data=data(1:end-length_test-1,:);
    [macdvec, nineperma] = macd(train_data);
    test_sample=macdvec(end-length_test:end,:);
    test_macd=nineperma(end-length_test:end,:);
    stock=data(end-length_test-1:end,:);
    [nk1,ni]=size(test_sample);
    for kk=1:nk1
        if test_sample(kk,:)>test_macd(kk,:)
            s(kk,:)=1; % buy
        elseif test_sample(kk,:)<test_macd(kk,:)
            s(kk,:)=-1; % sell
        end
    end
    for jj=2:nk1
        total(jj,:)=s(jj)*(stock(jj)-stock(jj-1))-0.001*(abs(s(jj)-s(jj-1))*stock(jj));
    end
    profit=sum(total);
    average=mean(total);
    standard_deviation=std(total);
    sharpe_ratio=(average)/standard_deviation;
    
elseif method==3
    y=price2ret(data);
    N=length(y);
    % We decompose our data with function db3
    [XX,l] = wavedec(y,decomposition_tree,'db3');
    % We define GARCH (1,1) process
    [Kappa, Alpha, Beta] = ugarch(XX, 1, 1);
    % We set the random number generator seed for reproducability
    randn('state', 0)
    NumSamples = 20000;
    firstpoint=length_test;
    % We simulate the process with Monte Carlo
    [U , H] = ugarchsim(Kappa, Alpha, Beta, NumSamples);
    % Length of vector
    %V=1%length(data);
    % From current day we extract firstpoint data randomly selected
    currentprice = randperm(N-M);
    currentprice= currentprice+N;
    for j=1:firstpoint
        Y1 = currentprice(j);
        Y0 = Y1-N+1;
        p = U(Y0:Y1);
        p = p(:);
        Y1(1,:) = p(1,:);
        prediction = U(Y1+1:Y1+M);
    end
    [nk1,ni]=size(prediction);
    for kk=1:nk1
        if prediction(kk,:)>0
            s(kk,:)=1; % buy
        elseif prediction(kk,:)<0
            s(kk,:)=-1; % sell
        end
    end
    stock=data(end-length_test:end,:);
    for jj=2:nk1
        total(jj,:)=s(jj)*(stock(jj)-stock(jj-1))-0.001*(abs(s(jj)-s(jj-1))*stock(jj));
    end
    profit=sum(total);
    average=mean(total);
    standard_deviation=std(total);
    sharpe_ratio=(average)/standard_deviation;
    
elseif method==4
    N=length(data);
    % We decompose our data with function db3
    [XX,l] = wavedec(data,decomposition_tree,'db3');
    train_data=XX(1:end-length_test-1,:);
    [Short,Long]=movavg(train_data,1,lag,factor);
    test_sample=data(end-length_test:end,:);
    test_long=Long(end-length_test-1:end,:);
    stock=data(end-length_test-1:end,:);
    [nk1,ni]=size(test_sample);
    for kk=1:nk1
        if test_sample(kk,:)>test_long(kk,:)
            s(kk,:)=1; % buy
        elseif test_sample(kk,:)<test_long(kk,:)
            s(kk,:)=-1; % sell
        end
    end
    for jj=2:nk1
        total(jj,:)=s(jj)*(stock(jj)-stock(jj-1))-0.001*(abs(s(jj)-s(jj-1))*stock(jj));
    end
    profit=sum(total);
    average=mean(total);
    standard_deviation= std(total);
    sharpe_ratio = (average)/standard_deviation;
elseif method==5
    [Short,Long] = movavg(data,1,lag,factor);
    if data (end,:)> Long (end,:)
        s=1; % buy
        
    elseif data (end,:)< Long (end,:)
        s=-1; % sell
    end
elseif method==6
    [macdvec, nineperma] = macd(data);
    if macdvec (end,:)> nineperma (end,:)
        s=1; % buy
    elseif macdvec (end,:)< nineperma (end,:)
        s=-1; % sell
    end
elseif method==7
    y=price2ret(data);
    N=length(y);
    % We decompose our data with function db3
    [XX,l] = wavedec(y,decomposition_tree,'db3');
    % We define GARCH (1,1) process
    [Kappa, Alpha, Beta] = ugarch(XX, 1, 1);
    % We set the random number generator seed for reproducability
    randn('state', 0);
    NumSamples = 20000;
    firstpoint = length_test;
    % We simulate the process with Monte Carlo
    [U , H] = ugarchsim(Kappa, Alpha, Beta, NumSamples);
    % Length of vector
    %V=1%length(data);
    % From current day we extract firstpoint data randomly selected
    currentprice = randperm(N-M);
    currentprice= currentprice+N;
    for j=1:firstpoint
        Y1 = currentprice(j);
        Y0 = Y1-N+1;
        p = U(Y0:Y1);
        p = p(:);
        Y1(1,:) = p(1,:);
        prediction = U(Y1+1:Y1+M);
    end
    if prediction>0
        s=1; % buy
        
    elseif prediction<0
        s=-1; % sell
    end
elseif method==8
    N =length(data);
    % We decompose our data with function db3
    [XX,l] = wavedec(data,decomposition_tree,'db3');
    [Short,Long] = movavg(XX,1,lag,factor);
    if data(end,:)> Long (end,:)
        s=1; % buy
    elseif data (end,:)< Long (end,:)
        s=-1; % sell
    end
end
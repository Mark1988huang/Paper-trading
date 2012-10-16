%% An Introduction to Econometrics Toolbox
% In this demo we model NASDAQ data from 1/2/1990 to 12/31/2001 using an
% ARMA(1,1)/GJR(1,1) model to showcase some capabilities of the toolbox.

%%  Visualize the data
load garchdata
% Price Data
dates = busdays('1/2/1990','12/31/2001','d');
subplot(2,1,1)
plot(dates,NASDAQ)
ylabel('Value')
title('Nasdaq Value')
datetick

% Return Series
nasdaq = price2ret(NASDAQ);
subplot(2,1,2)
plot(dates(2:end),nasdaq)
ylabel('Return')
title('Nasdaq Daily Returns')
datetick

%% Pre-estimation

%% 
% Compute and plot ACF and PACF
figure
subplot(2,1,1)
autocorr(nasdaq)
title('ACF with Bounds for Raw Return Series')
subplot(2,1,2)
parcorr(nasdaq)
title('PACF with Bounds for Raw Return Series')

%% 
% Checking for correlation in squared returns indicating GARCH effects
figure
subplot(2,1,1)
autocorr(nasdaq.^2)
title('ACF of the Squared Returns')
subplot(2,1,2)
parcorr(nasdaq.^2)
title('PACF of the Squared Returns')
parcorr(nasdaq.^2)

%% 
% Quantifying the Correlation
[H,pValue,Stat,CriticalValue] = ...
      archtest(nasdaq-mean(nasdaq),[10 15 20]',0.05);
[H  pValue  Stat  CriticalValue]


%% Modeling

%% 
%Define the model
spec = garchset('VarianceModel','GJR','P',1,'Q',1,'R',1,'M',1);
spec = garchset(spec, 'Distribution','t')

%% 
% Estimate the parameters
[coeff,errors,LLF,eFit,sFit] = garchfit(spec,nasdaq);

%% 
% Display the results
garchdisp(coeff,errors)


%% Forecasting and Simulation

%%
% Forecasting
horizon = 30;  % Define the forecast horizon
[sigmaForecast,meanForecast,sigmaTotal,meanRMSE] = ...
    garchpred(coeff,nasdaq,horizon);

%%
% Monte Carlo Simulation
nPaths = 1000;  % Define the number of realizations.
[eSim,sSim,ySim] = garchsim(coeff,horizon,nPaths,[],[],[],eFit,sFit,nasdaq);


%% Compare Simulation to Forecast

% Compare Sigmas
figure
plot(sigmaForecast,'.-b')
hold('on')
grid('on')
plot(sqrt(mean(sSim.^2,2)),'.r')
title('Forecast of STD of Residuals')
legend('forecast results','simulation results')
xlabel('Forecast Period')
ylabel('Standard Deviation')

% Compare Returns
figure
plot(meanForecast,'.-b')
hold('on')
grid('on')
plot(mean(ySim,2),'.r')
title('Forecast of Returns')
legend('forecast results','simulation results',4)
xlabel('Forecast Period')
ylabel('Return')

% Compare Standard Errors
figure
plot(meanRMSE,'.-b')
hold('on')
grid('on')
plot(std(ySim'),'.r')
title('Standard Error of Forecast of Returns')
legend('forecast results','simulation results')
xlabel('Forecast Period')
ylabel('Standard Deviation')

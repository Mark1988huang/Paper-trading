% Simple Mean-Variance Optimizer
% LuminousLogic.com


% Initialize Workspace
clear all; 
close all; 
pause(1);


% Database of returns
years         = [ 2009   2008   2007   2006   2005   2004   2003   2002   2001   2000   1999   1998   1997   1996   1995   1994];
rors(1,:)     = [26.46 -37.00   5.49  15.79   4.91  10.88  28.68 -22.10 -11.89  -9.10  21.04  28.58  33.36  22.96  37.58   1.32]; % e.g. VFINX
rors(2,:)     = [ 5.93   5.24   6.97   4.33   2.43   4.34   4.10  10.26   8.44  11.63  -0.82   8.69   9.65   3.63  18.47  -2.92]; % e.g. VBMFX
rors(3,:)     = [24.18 -36.42   5.30  12.20  22.64  18.98  38.48  -9.29 -25.40 -25.78  56.65   2.72 -25.87  -8.30   2.95  12.76]; % e.g. VPACX
asset_classes = {'S&P 500 Index', 'Barclays US Aggregate Bond Index', 'Pacific Rim Index'}; 

% Simulation parameters
num_iter   = 1e3;
max_alloc  = 1;


% Find mean & variance of most optimal portfolio weightings found so far
comb_ror = zeros(size(rors,2),1);
if  exist('stats.mat')
    load stats.mat;
else
    stats = [-1E9 +1E9];
end


% The Big Loop
for rand_scale=2.^[0:-1:-10]
    fprintf(1,'rand_scale = 2^%d\n', round(log2(rand_scale)));

    i=1;
    while i<num_iter
        
        while 1
            switch mod(i-1,2)
                case 0 % Random asset class weightings
                    weights = rand(size(rors,1),1);
                case 1 % Adjust the weight of one asset class of one of the optimal portfolios
                    idx_row = randperm(size(stats,1));
                    idx_col = randperm(size(stats,2)-2);
                    weights = stats(idx_row(1),3:end).';
                    weights(idx_col(1)) = max(weights(idx_col(1)) + rand_scale*(rand*2-1),0);
            end
            weights = weights / sum(weights);
            if max(weights)<=max_alloc
                break;
            end
        end

        % Compute this random portfolio's mean and variance
        for j=1:size(rors,2), comb_ror(j) = sum(weights .* rors(:,j)); end
        port_ror = round(mean(comb_ror)*10)/10;
        port_std = round(std(comb_ror)*100)/100;
        port_wts = weights;
        

        % Is this portfolio on the efficient frontier?
        if ~sum( (stats(:,1)>=port_ror) .* (stats(:,2)<=port_std))
            
            fprintf(1,'New best of <ROR>=%2.1f%% STD=%2.2f%% on iter=%d at %s using randscale=2^%d and mod %d\n',port_ror, port_std,i,datestr(now),log2(rand_scale),mod(i-1,2));
            i=0;
            again = 1;
            while again
                idx_rem1 = (find((stats(:,1)<=port_ror) .* (stats(:,2)> port_std))).';
                idx_rem2 = (find((stats(:,1)< port_ror) .* (stats(:,2)==port_std))).';
                idx_remove = [idx_rem1; idx_rem2];
                if length(idx_remove)>0
                    for j=idx_remove(1)
                        fprintf(1,'Removing    <ROR>=%2.1f%% STD=%2.2f%%\n',stats(j,1),stats(j,2));
                        stats = [stats(1:j-1,:); stats(j+1:end,:)];
                    end
                else
                    again=0;
                end
            end
            stats = [stats; [port_ror port_std port_wts.']];
        else
            i=i+1;
        end
    end
end

% Sort based on ROR
[eff_port_ror, idx_sort] = sort(stats(:,1));
eff_port_std = stats(idx_sort,2);
clear eff_port_wts;
for i=1:length(idx_sort)
    eff_port_wts(i,:) = stats(idx_sort(i),3:end).';
end
figure;
subplot(2,1,1)
plot(eff_port_std, eff_port_ror,'rx');
hold on; grid on;
xlabel('ROR Standard Deviation [%]');
ylabel('ROR Mean [%]');
axis tight;


%figure;
subplot(2,1,2)
plot(eff_port_ror,eff_port_wts.'*100); hold on; grid on;
xlabel('ROR [%]');
ylabel('Asset Weight [%]');
legend(asset_classes,2);
axis tight

save stats stats;
beep;

[mx,mx_offst] = sort(stats(:,1),'ascend');
for i=mx_offst.'
    fprintf(1,'mu=%2.1f s=%2.1f     ',stats(i,1), stats(i,2));
    for j=3:size(stats,2)
        fprintf(1,'%s:%1.2f     ',asset_classes{j-2},stats(i,j))
    end
    fprintf(1,'\n')
end


[dummy, srt_idx] = sort(stats(:,1),'ascend');
stats_sort = [];
for i=srt_idx.'
    stats_sort = [stats_sort; stats(i,:)];
end
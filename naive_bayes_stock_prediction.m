% pull most recent stock information

indeces_list = {'AKAM','ARMH','ATVI','BIDU','IBM','INTC','NFLX','OCZ','S','STX','VMW','YOKU'};

% look at each stock
for ix = 1:numel(indeces_list)
    [full_dates,highs,lows,opening,closing,volume] = get_hist_stock_data(indeces_list(ix));
    date_vectors = datevec(full_dates);
    
    yearsList = date_vectors(:,1);
    monthsList = date_vectors(:,2);
    daysList = date_vectors(:,3);
    
    % show some stats...
   
    % per-year analysis
    %for iz = 1:numel(unique(years))
   % end
    
    % per-month analysis
    for month = 1:12
        month_inds = find(monthsList == month);
        
        averages = zeros(31,3);
        % somehow stack corresponding days? need to intersect days and months somehow
        for day = 1:31
            day_inds = find(daysList == day);
            day_month_inds = intersect(month_inds,day_inds);
            
            averages(day,:) = [nanmean(opening(day_month_inds)) nanmean(closing(day_month_inds)) nanmean(volume(day_month_inds))];
        end
        
        % how does it do?
        figure(7359); clf;
        title(indeces_list(ix));
        plot(averages(:,1)-averages(:,2));
        pause(eps);
        %month_avg = mean(hist_close(month_inds));
    end
    
    % do bayes with matlab
end
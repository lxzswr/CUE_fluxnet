% this function 

function CUE_output = estimate_site_CUE(fluxdata)

    warning off;
    %%% time variables to be used
    month_day = [31,28,31,30,31,30,31,31,30,31,30,31]; % numbers of days in each month
    cum_month_day = cumsum(month_day); 
    cum_month_day2 = cat(1,0,cum_month_day(1:11)');

    %%% initiate the variables to store output
    site_output = [];
    count = 1; % recorder
    site_output2 = [];
    count2 = 1; % recorder
    CUE_output = [];
  
    %get time stamps
    years_seq = fluxdata(:,3);
    years_unique = unique(years_seq); % the years contained in the dataset
    doy = fluxdata(:,4); % day of year


    %%% Conduct the first round of MCMC (Markov chain Monte Carlo)
    %%% the function to be optimized is deltaReco = gR*CUE*deltaGPP + mR*CUE*delta_cumGPP*(1-tau).
    
    % for each year
    for yy = 1: length(years_unique)
        
        ind = years_seq == years_unique(yy);

        doy_thisyear = doy(ind); % get the doy of this year

        %%% select the gpp and reco columes in the dataset        
        gpp_DT = fluxdata(ind,12); % GPP_DT
        reco_DT = fluxdata(ind,16); % Reco_DT
        gpp_NT = fluxdata(ind,11); % GPP_NT
        reco_NT = fluxdata(ind,15); % Reco_NT

        % get the GPP from the average of NT and DT
        gpp = (gpp_DT + gpp_NT).*0.5;
        reco = (reco_DT + reco_NT).*0.5;

        
        %%% briefly clean the dataset, obtain cummulative GPP
        gpp(gpp < 0.01) = NaN;
        cumgpp = cumsum(gpp,'omitnan'); % cumulative GPP, for MCMC process.
        threshold = (max(gpp,[],'omitnan') - min(gpp,[],'omitnan')).*0.2 + min(gpp,[],'omitnan'); % define a growing season threshold to extract only the growing season.
        

        %%% get the climate data
        cli_data = fluxdata(ind,7:10); % climate data, Tair, rad, VPD, rainfall
        tair = cli_data(:,1);
        
        % MCMC, for each time bin, this is just to get the rough range of all parameters, acquire those in a narrow range.    

        ind_gs = gpp > threshold & tair > 5; % further define growing season as Tair > 5C.
        gs_doy = doy_thisyear(ind_gs);
        
        % Analyse data at 5 day interval, using 10 days window (within this period assuming small change in SOM). 10 days window is used to ensure there are enough samlpes
        for t_c = min(gs_doy):5:max(gs_doy) 
            
            t_index = gs_doy > t_c & gs_doy < t_c+10; 
            
            if sum(t_index) > 5 % only if there are more than 5 data points (generate 10 samples), then we move to the next step.
                
                % generate samples
                tmp_y = reco(t_index); % daily GPP
                tmp_x1 = gpp(t_index); % daily Reco
                tmp_x2 = cumgpp(t_index); % daily cummulative GPP from doy 0       
                
                tmp = combntns(tmp_y,2); % create all the possible combinations between two days
                data.ydata = tmp(:,2) - tmp(:,1); % the changes in GPP (delta_GPP) between two days
                
                tmp = combntns(tmp_x1,2); % create all the possible combinations between two days
                data.xdata1 = tmp(:,2) - tmp(:,1); % the changes in Reco (delta_Reco) between two days
                
                tmp = combntns(tmp_x2,2); % create all the possible combinations between two days
                data.xdata2 = tmp(:,2) - tmp(:,1); % the changes in cumGPP (delta_cumGPP) between two days
                
                 
                % Start to run MCMC
                cd('/Users/xiangzhongluo/Dropbox/Code/carbon_cost/code');
                model.ssfun = @est_CUE_ss2;
                
                % initiate the range of parameters
                params = {
                    {'k1', 0.20, 0.15, 0.30}  %gR
                    {'k2', 0.1, 0.0, 0.20}  %mR
                    {'k3', 0.5, 0.1, 1}  %CUE
                    {'k4', 1, 0.1, 1}  %tau
                    };
                options.nsimu = 200;
                
                % excute MCMC
                cd('/Users/xiangzhongluo/Dropbox/Code/carbon_cost/code/mcmcstat-master/');
                [res,chain] = mcmcrun(model,data,params,options);
                
                % output of MCMC
                site_output(count,1) = years_unique(yy);
                site_output(count,2) = t_c;
                site_output(count,3:6) = res.mean; % gR, mR, CUE and tau
                site_output(count,7:10) = nanmean(cli_data(t_index,:),1); % climate data for the period.                     
                site_output(count,11:14) = nanstd(chain,1,1); % uncertainty of the four parameters

                count = count + 1;
            end 
        end
    end



    %%% Conduct the second round of MCMC (Markov chain Monte Carlo)
    %%% the function to be optimized is deltaReco = gR*CUE*deltaGPP + mR*CUE*delta_cumGPP*(1-tau).

    if size(site_output,2) > 0 % only proceed when there is valid estimate from the last round

        % get the means of first MCMC, and set those as the new iniatiation point in second MCMC
         gR_fixed = nanmean(site_output(:,3));
         mR_fixed = nanmean(site_output(:,4));
         CUE_fixed = nanmean(site_output(:,5));
         tau_fixed = nanmean(site_output(:,6));


         gR_un_fixed = nanmean(site_output(:,11));
         mR_un_fixed = nanmean(site_output(:,12));
         CUE_un_fixed = nanmean(site_output(:,13));
         tau_un_fixed = nanmean(site_output(:,14));

         mR0 = prctile(site_output(:,4),10); %baseline mR
    
         [~,Idx]=min(abs(mR0-site_output(:,4)));
         T0 = site_output(Idx,7);
        
        % for each year
        for yy = 1: length(years_unique)
            
            ind = years_seq == years_unique(yy);
    
            doy_thisyear = doy(ind); % get the doy of this year
    
            %%% select the gpp and reco columes in the dataset        
            gpp_DT = fluxdata(ind,12); % GPP_DT
            reco_DT = fluxdata(ind,16); % Reco_DT
            gpp_NT = fluxdata(ind,11); % GPP_NT
            reco_NT = fluxdata(ind,15); % Reco_NT
    
            % get the GPP from the average of NT and DT
            gpp = (gpp_DT + gpp_NT).*0.5;
            reco = (reco_DT + reco_NT).*0.5;
    
            
            %%% briefly clean the dataset, obtain cummulative GPP
            gpp(gpp < 0.01) = NaN;
            cumgpp = cumsum(gpp,'omitnan'); % cumulative GPP, for MCMC process.
            threshold = (max(gpp,[],'omitnan') - min(gpp,[],'omitnan')).*0.2 + min(gpp,[],'omitnan'); % define a growing season threshold to extract only the growing season.
            
    
            %%% get the climate data
            cli_data = fluxdata(ind,7:10); % climate data, Tair, rad, VPD, rainfall
            tair = cli_data(:,1);
            rainfall = cli_data(:,4);

            flux_data = fluxdata(ind,[11,12,15,16]); % GPP NT, GPP DT, Reco NT, Reco DT. 

    
            %%% MCMC for each tair bin
                   for t_c = 0:35 % loop by similar temperature, within 1 degree range. Also need to remove rainfall due to Birch effect.
                        
                        t_index = tair > t_c & tair < t_c+1 & rainfall < 2;
                        
                        if sum(t_index) > 5 % only if there are 5 data points, generate at least 10 samples
                            
                            % generate samples
                            tmp_y = reco(t_index);
                            tmp_x1 = gpp(t_index);
                            tmp_x2 = cumgpp(t_index);
                            
                            % get all possible combinations                           
                            tmp = combntns(tmp_y,2);
                            data.ydata = tmp(:,2) - tmp(:,1);
                            
                            tmp = combntns(tmp_x1,2);
                            data.xdata1 = tmp(:,2) - tmp(:,1);
                            
                            tmp = combntns(tmp_x2,2);
                            data.xdata2 = tmp(:,2) - tmp(:,1);
                            
                            data.xdata3 = gR_fixed; %gR, assume not change with temperature
                            data.xdata5 = tau_fixed; %tau
    
                            %%%% added variables for Q10 calculation
                            data.xdata4 = mR0; %mR0
                            data.xdata6 = T0;
                            data.xdata7 = t_c + 0.5;
                             
                            % MCMC
                            cd('/Users/xiangzhongluo/Dropbox/Code/carbon_cost/code');
                            model.ssfun = @est_CUE_fixed_ss2;
    
                            params = {
                                {'kb1', CUE_fixed, 0.1, 1}  %CUE, dynamic from last MCM
                                {'kb2', 0.65, 0, 1.2} % Ea;
                                };
    
                            options.nsimu = 200;
                            
                            cd('/Users/xiangzhongluo/Dropbox/Code/carbon_cost/code/mcmcstat-master/');
                            [res,chain] = mcmcrun(model,data,params,options);

                            if abs(res.mean(1) - CUE_fixed) > 0.001 & abs(res.mean(2) - 0.65) > 0.01 % check if the constrain function is really useful

                                site_output2(count2,1) = years_unique(yy);
                                site_output2(count2,2) = t_c;
                                site_output2(count2,3) = gR_fixed;
                                site_output2(count2,4:5) = res.mean; %CUE, Ea
                                site_output2(count2,6) = tau_fixed;
                                site_output2(count2,7:10) = nanmean(cli_data(t_index,:),1); % climate data for the period.
                                site_output2(count2,11) = gR_un_fixed;
                                site_output2(count2,12:13) = nanstd(chain,1,1); % uncertainty of CUE and Ea resulting from MCMC
                                site_output2(count2,14) = tau_un_fixed;
        
                                count2 = count2 + 1;
                            else
                                site_output2(count2,1) = years_unique(yy);
                                site_output2(count2,2) = t_c;
                                site_output2(count2,3) = gR_fixed;
                                    if count2-1>0
                                        site_output2(count2,4:5) = site_output2(count2-1,4:5); %CUE, Ea
                                    else
                                        site_output2(count2,4:5) = res.mean;
                                    end
                                site_output2(count2,6) = tau_fixed;
                                site_output2(count2,7:10) = nanmean(cli_data(t_index,:),1); % climate data for the period.

                                site_output2(count2,11) = gR_un_fixed;
                                    if count2-1>0
                                        site_output2(count2,12:13) = site_output2(count2-1,4:5); %uncertainty in CUE, Ea
                                    else
                                        site_output2(count2,12:13) = nanstd(chain,1,1); 
                                    end
                                site_output2(count2,14) = tau_un_fixed;

                                count2 = count2 + 1;
                            end
                        end
                   end


                   % the final output of annual CUE and associated metrics
                   y_ind = site_output2(:,1) == years_unique(yy);

                   %%%%%%%% Using bootstrapping to get site mean value and Uncertainty (MCMC and temporal variation)
                   CUE_output(yy,1) = years_unique(yy); %year
                   
                    if sum(y_ind) > 0 %only if there is a valid MCMC
                    
                        parameters_all = []; % bootstrapping 1000 times
                         for cc = 1:1000
                            tmp1 = normrnd(site_output2(y_ind,3:6),site_output2(y_ind,11:14)); %randomly generate one value using mean and MCMC uncertainty
                            parameters_all(cc,:,:) = tmp1;
                         end
                        
                         % get the mean and unc for the four parameters
                         for pp = 1:4
                              CUE_output(yy,pp+1) = nanmean(reshape(parameters_all(:,:,pp),[],1)); %gR, CUE, Ea, tau
                              CUE_output(yy,pp+5) = nanstd(reshape(parameters_all(:,:,pp),[],1),1,1); %unc of gR, CUE, Ea, tau
                         end
                    
                    
                     else
                            CUE_output(yy,:) = NaN;
                     end


              end
         end

end

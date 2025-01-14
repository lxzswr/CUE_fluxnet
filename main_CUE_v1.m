%%%%% Instruction %%%%%%

    %%% Estimate Carbon Use Efficiency (CUE) from eddy covariance observations
    %%% By Xiangzhong (Remi) Luo, Jan 14th, 2025 
    %%% At Department of Geography, NUS
    
    %%% Version 1.


%%%%% STEP 1: Read the eddy covariance dataset

    %%% Any flux dataset organized in FLUXNET2015/ONEFLUX format can be used
    file_loc = '/Users/xiangzhongluo/Library/CloudStorage/Dropbox/Data/Fluxnet_pipeline_data/FLX_US-Ha1_FLUXNET2015_FULLSET_DD_1991-2012_1-3.csv';
    site_name = 'US-Ha1';


    disp('loading eddy covariance data');
    flux_dataset = readfluxnet_data(file_loc);


%%%%% STEP 2: Estimate CUE from eddy covariance dataset

    %%% Estimate annual CUE of the site, based on first principle of gpp-reco coupling and MCMC optimization
    disp('estimating carbon use efficiency and its uncertainty');
    CUE_output = estimate_site_CUE(flux_dataset);


%%%%% STEP 3:  print the result, mean CUE value and uncertainty for each year

    disp(site_name);
    disp(['year','gR','CUE','Ea','tau','gR_sd','CUE_sd','Ea_sd','tau_sd']);
    format shortG;
    disp(CUE_output);

    CUE_site_year = array2table(CUE_output, 'VariableNames', {'year','gR','CUE','Ea','tau','gR_sd','CUE_sd','Ea_sd','tau_sd'});















%%%%% Instruction %%%%%%

    %%% Estimate Carbon Use Efficiency (CUE) from eddy covariance observations
    %%% By Xiangzhong (Remi) Luo, Oct 14th, 2024 
    %%% At Department of Geography, NUS
    
    %%% Version 1.
    %%% This is the main function.


%%%%% STEP 1: Read the eddy covariance dataset

    %%% Any flux dataset organized in FLUXNET2015/ONEFLUX format can be used
    file_loc = 'FLX_US-Ha1_FLUXNET2015_FULLSET_DD_1991-2012_1-3.csv';
    site_name = 'US-Ha1';


    disp('loading eddy covariance data');
    flux_dataset = readfluxnet_data(file_loc);


%%%%% STEP 2: Estimate CUE from eddy covariance dataset

    %%% Estimate annual CUE of the site, based on first principle of gpp-reco coupling and MCMC optimization
    disp('estimating carbon use efficiency and its uncertainty');
    CUE_output = estimate_site_CUE(flux_dataset);


%%%%% STEP 3:  print the result, mean CUE value and uncertainty for each year

    disp(site_name);
    disp(['year ','CUE ','CUE_sd']);

    format shortG;
    disp(CUE_output);







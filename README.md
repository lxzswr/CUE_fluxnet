% Version 1 of the code - Xiangzhong (Remi) Luo, Oct 22, 2024

% This is the code to estimate Carbon Use Efficiency (CUE) from eddy covariance measurements.
% main_CUE_v1.m is the main function
% readfluxnet_data. m is the function to read FLUXNET2015/Oneflux format datasheet and organize the daily flux in the way we needed
% estimate_site_CUE.m is the function that adopt MCMC method to derive CUE and associated metrics.
% mcmcstat-master.zip is the 3rd party package for MCMC. Need to UNZIP before running the code.
% FLX_US-Ha1_FLUXNET2015_FULLSET_DD_1991-2012_1-3.csv' is a sample datasheet for flux observations, from the site US-Ha1 (Harvard forest)

% The output include year, CUE, and the uncertainty of CUE (in standard deviation)
% Reference: Luo et al. https://www.researchsquare.com/article/rs-3989566/v1

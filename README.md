Version 1 of the code - Xiangzhong (Remi) Luo, originally posted on Oct 22, 2024, updated on Jan 14, 2025.

This is the code to estimate vegetation Carbon Use Efficiency (CUE) from eddy covariance measurements.
The code was compiled the ran on Matlab version R2021b on macOS Ventura 13.7.1. It does not need non-standard hardware.

The code is readily to be excuted after correctly edit the file path in a local desktop/laptop installed with Matlab.

The files we provide include:
1. main_CUE_v1.m is the main function
2. readfluxnet_data.m is the function to read FLUXNET2015/Oneflux format datasheet and organize the daily flux in the way we needed
3. estimate_site_CUE.m is the function that adopt MCMC method to derive CUE and associated metrics.
4. mcmcstat-master.zip is the 3rd party package for MCMC. Need to UNZIP before running the code.
5. FLX_US-Ha1_FLUXNET2015_FULLSET_DD_1991-2012_1-3.csv' is a sample datasheet for flux observations, from the site US-Ha1 (Harvard forest)

The output include year, CUE, and the uncertainty of CUE (in standard deviation) of the site US-Ha1. The output is stored under the variable name "CUE_site_year"

Reference: Luo et al. https://www.researchsquare.com/article/rs-3989566/v1

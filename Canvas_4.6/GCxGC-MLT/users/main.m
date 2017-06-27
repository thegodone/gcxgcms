% J. Gros and J. Samuel Arey, EPFL, March 17, 2016.

close all;
clear all;
clc;

% -----------------------------------------------------------------------------
% ALL PROGRAM PARAMETERS THAT SHOULD BE SET BY THE USER ARE SHOWN HERE.

% INSTRUMENT PARAMETERS

% Set program flag: 'A','B','C', ... based on the selected instrument program.
program_flag = 'B';

% Set the modulation period (units of seconds)
modulation_period = 7.5; 

% Set the detector acquisition rate (units of Hertz)
acquisition_rate = 100; 

% Set the acquisition delay (units of seconds)
acquisition_delay =1000;

% CHROMATOGRAM FILES

% Reference chromatogram file:
Reference_chromatogram_file = 'ChromatoB.csv';

% Weathered chromatogramvfile:
Weathered_chromatogram_file = 'Pseudo_weathered_ChromatoB.csv';

% REMOVING BLEED LINE

% The earliest part of the second dimension of the GCxGC chromatogram
% usually contains only column bleed signal. This signal should be removed
% to avoid biasing the values in the lowest MLT cell. All pixels up to the
% time below (in the second dimension) will be set to zero 
% (first pixel having a time of zero)  (units of seconds):
Bleed_cutoff = 1.9; % [s]

% NORMALIZATION

% Volume of peak used for normalisation, for the Reference chromatogram:
% (set it to 1 if no normalization is to be performed)
Vol_Reference = 1.;

% Volume of peak used for normalisation, for the Weathered chromatogram:
% (set it to 1 if no normalization is to be performed)
Vol_Weathered = 1.;

% MODEL CHOICE PARAMETERS

% Set groupflag to "0" to use the entire nonpolar training set.
% Set groupflag to "1" to use the hydrocarbons-only training set (* FOR OIL ANLAYSIS *).
group_flag = 1; 

% Decide on the finite element cell size. The default values should fit most
% needs.
winP = 0.2;  % logPl dim window size. A value of 0.4 is about 1 alkane / window
winC = 0.5;  % logCw dim window size

% Decide on the limits of log10(Solubility) and log10(Vapor pressure) used
% to define the MLT.
bdP = [-4.40 3.17];  % log10(vapor pressure) range (Pa)
bdC = [-3.3 0.7];  % log10(aqueous solubility) range (mol/m3)

% Decide on criterion to identify noisy cells.
NoiseCutoff = 1e-5; % fraction. E.g. 2e-4 = 0.02%

% INPUT/OUTPUT PARAMETERS

% Set plot_flag to a value of 0 to suppress plots.
% Set to a value of 1 to see "normal" level of plotting (DEFAULT).
% Set to a value of 2 to see a lot of plots (for debugging/trouble-shooting).
plot_flag = 1;
 
% Set the output file path
output_path = 'users/output/';

% Set the input file path
input_path = 'users/input/';

% Set Matlab console output level. Choose: 'minimal', 'normal', or 'verbose'.
prompt_output = 'normal';

% -----------------------------------------------------------------------------

cd('../model_code');

main_code;


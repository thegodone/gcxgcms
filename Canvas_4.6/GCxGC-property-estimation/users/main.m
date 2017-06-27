% J. Samuel Arey, EPFL, May 15, 2014.

close all;
clear all;
clc;

% -----------------------------------------------------------------------------
% ALL PROGRAM PARAMETERS THAT SHOULD BE SET BY THE USER ARE SHOWN HERE.

% INSTRUMENT PARAMETERS

% Set program flag: 'A','B','C', ... based on the selected instrument program.
program_flag = 'P';

% Set the modulation period (units of seconds)
modulation_period = 11; 

% Set the detector acquisition rate (units of Hertz)
acquisition_rate = 50; 

% MODEL CHOICE PARAMETERS

% Set groupflag to "0" to use the entire nonpolar training set (DEFAULT).
% Set groupflag to "1" to use the hydrocarbons-only training set (* BOB *).
group_flag = 0; 

% Which properties do you want to map onto the chromatogram?
% Enter a vector of integers ranging from 1 to 11. 
mapped_properties = [1 7 11];

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


% This file compiles all quaternion and angular velocity data files from 
% single subject trials. Assign hand signal value when prompted. Save 
% all_data matrix and use to train classification model. 

% Prepare workspace
clear all % clear workspace
clc % clear command window

% Locate data files
[filenames, pathnames] = uigetfile('*.mat','MultiSelect','on');
cd(pathnames);

% Compile all quaternion data and assign hand signal
for jj = 1:length(filenames)
    loaded_data = load(fullfile(pathnames, filenames{jj})); 
    variable_names = fieldnames(loaded_data);
    
    data = loaded_data.(variable_names{1});
    data = data(2:end, :);
    
    hand_signal = input(['Which hand signal for ', filenames{jj}, ' ?: ']);
    data = [data, hand_signal * ones(size(data, 1), 1)];
    
    if jj == 1
        all_data = data;
    else
        all_data = [all_data; data];
    end
end
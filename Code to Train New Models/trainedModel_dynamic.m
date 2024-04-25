% This file reads JSON files and extracts quaternion and angular velocity 
% data. Data is then run through respective trained classification model 
% to predict static or dynamic hand signals of test trial videos. Signal 
% output is determined by repetition and displayed as number squence or 
% signal name. 

% Prepare workspace
clear all % clear workspace
clc % clear command window

%% Read in JSON file
[filename, pathname] = uigetfile('*.json', 'Select JSON data file');
fullFilePath = fullfile(pathname, filename);

fid = fopen(fullFilePath); % Open file
raw = fread(fid, inf); % Read raw JSON data
str = char(raw'); % Convert to character array
fclose(fid); % Close the file
data = jsondecode(str); % Decode JSON data

%% Extract quaternion and angular velocity data from hand/arm/finger channels
L = length(data.animations.channels(12).rotationkeys);
i = 1; % index
c = 0; % index
rot_key = [];

while i < 75
    rot_key_length = length(data.animations.channels(i).rotationkeys);
    if rot_key_length > 2
        c = c + 1;
        for sample = 1:L %
            rot_num = (data.animations.channels(i).rotationkeys{sample,1}{2,1})';
            rot_key(sample,1:4) = rot_num;
        end
        q = quaternion(rot_key(2:L,4),rot_key(2:L,1),rot_key(2:L,2),rot_key(2:L,3));
        ang = angvel(q,1/30,"frame"); % angular velocity

        segmentName = data.animations.channels(i).name;
        movement.(segmentName).q = rot_key; % quaternions
        movement.(segmentName).w = ang; % ang velocity 
        movement.(segmentName).w_mag = vecnorm(movement.(segmentName).w,2,2); % ang vel magnitude

        clear rot_key
        clear ang
    end
    i = i + 1;
end

%% Compile matrix of quaternion and angular velocity values
segmentNames = fieldnames(movement);

allq = [];
allw = [];

for j = 1:length(segmentNames)
    if j == 1
        allq = movement.(char(segmentNames(j))).q;
        allw = movement.(char(segmentNames(j))).w_mag;
    else
        allq = [allq, movement.(char(segmentNames(j))).q];
        allw = [allw, movement.(char(segmentNames(j))).w_mag];
    end
end

allq = allq(2:end, :); % remove first row of reference quats
alldata = [allq, allw]; % first 88 columns are quat, next 66 columns are w

%% Figure out if file is static one signal, static series, or dynamic and display accordingly 
avg_w = mean(allw(2:end,:));

if avg_w < 1 % threshold for single number series
    disp('Static Hand Signal:')
    load('trainedModel_0to9_FINAL.mat');
    yfit = trainedModel_0to9_FINAL.predictFcn(allq); % Outputs yfit
    disp(mode(yfit))

elseif avg_w < 2 % threshold for number sequence 
    disp('Static Hand Signal Series:')
    load('trainedModel_0to9_FINAL.mat');
    yfit = trainedModel_0to9_FINAL.predictFcn(allq); % Outputs yfit

    % Use findblocks function to determine series of signals.
    [block_ind, block_length] = findblocks(gradient(yfit)==0);
    kk = 1;
    for jj = 1:length(block_length)
        if block_length(jj) >= 20
            sequence(kk) = mode(yfit(block_ind(jj,1):block_ind(jj,2)));
            kk = kk + 1;
        else
        end
    end
    disp(num2str(sequence))

else % all else go into dynamic 
    disp('Dynamic Hand Signal:')
    load('trainedModel_dynamic_FINAL.mat');
    yfit_d = trainedModel_dynamic_FINAL.predictFcn(alldata); % Outputs yfit

    % Use assigned numerical values to show word signal
    if yfit_d(1) == 10
        disp('Rally Point')
    elseif yfit_d(1) == 11
        disp('Move Up')
    elseif yfit_d(1) == 12
        disp('Column Formation')
    end
end
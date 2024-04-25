% This file reads JSON files from Rokoko --> Filestar and extracts
% quaternion and angular velocity data from each hand/arm/finger joint 
% segment. Edit last line to save matrix as .mat file with descriptive 
% file name. 

% Prepare workspace
clear all % clear workspace
clc % clear command window

%% Read in JSON file
[filename, pathname] = uigetfile('*.json', 'Select JSON data file');
if isequal(filename, 0) || isequal(pathname, 0)
    disp('User canceled the file selection. Exiting.');
    return;
end

fullFilePath = fullfile(pathname, filename);

fid = fopen(fullFilePath); % Open file
raw = fread(fid, inf); % Read raw JSON data
str = char(raw'); % Convert to character array
fclose(fid); % Close the file
data = jsondecode(str); % Decode JSON data

%% Extract quaternion data from hand/arm/finger channels
L = length(data.animations.channels(12).rotationkeys);
i = 1; % index
c = 0; % index
rot_key = [];

while i < 75
    rot_key_length = length(data.animations.channels(i).rotationkeys);
    if rot_key_length > 2 
        c = c +1;
        for sample = 1:L %
            rot_num = (data.animations.channels(i).rotationkeys{sample,1}{2,1})';
            rot_key(sample,1:4) = rot_num;
        end
        q = quaternion(rot_key(2:L,4),rot_key(2:L,1),rot_key(2:L,2),rot_key(2:L,3));
        ang = angvel(q,1/30,"frame"); % angular velocity 

        segmentName = data.animations.channels(i).name;
        movement.(segmentName).q = rot_key;
        movement.(segmentName).w = ang;
        movement.(segmentName).w_mag = vecnorm(movement.(segmentName).w,2,2);

        clear rot_key
        clear ang
    end
    i = i + 1;
end

%% Compile matrix of quaternion data
segmentNames = fieldnames(movement);

allq = [];
allw = [];

for jj = 1:length(segmentNames)
    if jj == 1
        allq = movement.(char(segmentNames(jj))).q;
        allw = movement.(char(segmentNames(jj))).w_mag;
    else
        allq = [allq, movement.(char(segmentNames(jj))).q];
        allw = [allw, movement.(char(segmentNames(jj))).w_mag];
    end
end

allq = allq(2:end, :); % remove first row of reference quats
alldata = [allq, allw]; % first 88 columns are quat, next 66 columns are w

%% Save quaternion data as .mat file 
save moveup_megan.mat alldata  % Edit this line for each file 
% This file reads JSON files from Rokoko --> Filestar and extracts
% quaternion data from each hand/arm/finger joint segment. Edit last line 
% to save matrix as .mat file with descriptive file name. 

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

while i < 75
    rot_key_length = length(data.animations.channels(i).rotationkeys);
    if rot_key_length > 2 
        c = c +1;
        for sample = 1:L %
            rot_num = (data.animations.channels(i).rotationkeys{sample,1}{2,1})';
            rot_key(sample,1:4) = rot_num;
        end
        q = quaternion(rot_key(2:L,4),rot_key(2:L,1),rot_key(2:L,2),rot_key(2:L,3));
        segmentName = data.animations.channels(i).name;
        movement.(segmentName).q = rot_key;
        clear rot_key
    end
    i = i + 1;
end

%% Compile matrix of quaternion data

segmentNames = fieldnames(movement);

for jj = 1:length(segmentNames)
    if jj == 1
        allq = movement.(char(segmentNames(jj))).q;
    else
        allq = [allq, movement.(char(segmentNames(jj))).q];
    end
end

%% Save quaternion data as .mat file 
save 5_ethan.mat allq  % Edit this line for each file 
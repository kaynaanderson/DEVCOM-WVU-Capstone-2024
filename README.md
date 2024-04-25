Final code and trained models from the 2024 WVU Biomedical Engineering capstone project with DEVCOM and NSIN. 
Project: Using Wearable Sensors to Enhance Communication in the U.S. Army (NONVERBAL GESTURE-BASED COMMUNICATION TOOL)
Team Members: Kayna Anderson, Megan Weaver, Christian Kantz, Ethan Hicks

Includes JSON files exported from ROKOKO Studio using ROKOKO smartgloves. 

**Code to train new models:**
angvel_data.m - Use this to prepare dynamic files for making a large training data matrix. 
	- Converts JSON file to MAT file. 
	- Extracts quaternion and angular velocity data for all joint segments arm to finger. 

quaternion_data.m - Use this to prepare static files for making a training data matrix. 
	- Converts JSON file to MAT file. 
	- Extracts quaternion data for all joint segments arm to finger. 

training_data.m - Use this to actually compile the training data matrix. 
	- Prompts you to select all MAT files of quaternion and/or angular velocity data.
	- Compiles the large training data. 

trainingdata_0to9_FINAL.mat - Training data used April 2024 for final classifier 
trainingdata_dynamic_FINAL.mat - Training data used April 2024 for final classifier


**Script file version of MATLAB app:**
trainedModel_dynamic.m - Use this script file to predict hand signals from a recording. 
	- Prompts you to select JSON file . 
	- Extracts quaternion and angular velocity data from that file. 
 	- Evaluates average angular velocity of file to know what type of hand signal.
	- Loads appropriate trainedModel from workspace (make sure name matches). 
	- Puts data through trained model and outputs prediction for each timepoint. 
	- Uses findblocks.m to pick up deliberate hand signals by repetitive predictions. 

**Display Hand Signal App (and files to use with it):**
display_handsignal_dynamic.mlapp - App to predict hand signals from recording. 
	- “Load Hand Signal” prompts you to select JSON file. 
	- Performs exact same process as trainedModel_dynamic.m script file ^^
	- Displays number, sequence, or dynamic hand signal message. 
 
findblocks.m - Function used by app and script file. Must have this in same folder
	- Find sections of prediction outputs where same number is predicted 10 times. 
	- Gets rid of noise data when switching between signals 

*Must have these to run app*
trainedModel_0to9_FINAL.mat - Trained static model exported April 2024
trainedModel_dynamic_FINAL.mat - Trained dynamic model exported April 2024 

%% Load Rigid Body Tree from SimScape model
[DOF3_RRR,ArmInfo] = importrobot('DOF3_RRR');

%% Creating slTuner and configuring it
% Create slTuner interface
TunedBlocks = {'PD1', 'PD2', 'PD3'};
ST0 = slTuner('DOF3_RRR_PID_new',TunedBlocks);
% Mark outputs of PID blocks as plant inputs
addPoint(ST0,TunedBlocks)
% Mark joint angles as plant outputs
addPoint(ST0,'Robot/qm');
% Mark reference signals
RefSignals = {...
   'DOF3_RRR_PID_new/Signal Builder/q1', 'DOF3_RRR_PID_new/Signal Builder/q2', 'DOF3_RRR_PID_new/Signal Builder/q3'};
addPoint(ST0,RefSignals)

%% Defining Input and Outputs and Tuning the system
Controls = TunedBlocks;      % actuator commands
Measurements = 'DOF3_RRR_PID_new/Robot/qm';  % joint angle measurements
options = looptuneOptions('RandomStart',80','UseParallel',false); % Optimization 
% routine will restart 80 times from random locations, and if 'UseParallel' 
% is true, then parallel processing will be used to speed up the tuning process
TR = TuningGoal.StepTracking(RefSignals,Measurements,0.05,0);
ST1 = looptune(ST0,Controls,Measurements,TR,options);

%% Update PID Block
writeBlockValue(ST1)

%% Simulating the model
%  sim('DOF3_RRR_PID_new.slx',3)
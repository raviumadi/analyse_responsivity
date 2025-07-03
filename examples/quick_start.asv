% Usage demo for BiosonarResponsivity class

% file = './data/BAT006.WAV'; % or load any file of your own. Also see provided sample data files.
% file = './data/14-Sep-2021_20-06-38_fruityard_IN.wav';
file = './data/14-Sep-2021_21-44-39_fruityard_IN.wav';
% file = './data/03-Sep-2021_20-39-00_fruityard_IN.wav';
kr = 5; % Starting point
RcMax = 200; % Starting point. Adjust according to your data
% Create BiosonarResponsivity object with kr, RcMax
bsr = BiosonarResponsivity(file, kr, RcMax);

% Run interactive call timestamp selection
bsr.getCallTimestampsInteractive();

% Run responsivity analysis
bsr.analyseResponsivity();

% Print summary of results
bsr.summary();

% Plot detailed responsivity results (calls external plotResponsivityResults)
bsr.plotDetailedResults();

% Plot responsivity curve & inflection point (calls external plotResponsivityFromResults)
bsr.plotRespCurve();

% Plot IPI vs CR plot
bsr.plotIPI();

%%
bsr.exportResults('results')
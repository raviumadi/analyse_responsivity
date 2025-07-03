% Usage demo for BiosonarResponsivity class

file = './data/BAT006.WAV'; % or load any file of your own. Also see provided sample data files.
% file = './data/04-Sep-2021_20-39-10_fruityard_IN.wav';
kr = 5;
RcMax = 180;
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

bsr.exportResults('results')
# BioSonar Responsivity Analysis Toolkit
### UNDER DEVELOPMENT - Check again soon
**See the following papers for the original descritpion of the methods and theory**

[Biosonar Responsivity Sets the Stage for the Terminal Buzz](https://www.biorxiv.org/content/10.1101/2025.06.16.659925v1)

[Temporal Precision Necessitates Wingbeat-Call Asynchrony in Actively Echolocating Bats](https://www.biorxiv.org/content/10.1101/2025.06.18.660328v1)

This repository contains MATLAB tools for analyzing biosonar call timing and responsivity in echolocating animals, including interactive call selection, call timing analysis, and visualization.

## Features
-	Interactive Call Picker: GUI tool to select call timestamps and durations from audio waveforms with adjustable markers.
-	Responsivity Analysis: Calculate inter-phonation intervals (IPI), echo delays (Ta), biological reaction times (Tb), and responsivity metrics.
-	Visualization: Plot call rates, buzz readiness, and call timing summaries.
-	Class Interface: BiosonarResponsivity class encapsulates audio loading, interactive call selection, analysis, plotting, and result export.

```matlab
% Create object and load audio
bsr = BiosonarResponsivity('path/to/audio.wav', kr_value, RcMax_value);

% Select calls interactively
bsr.getCallTimestampsInteractive();

% Run responsivity analysis
bsr.analyzeResponsivity();

% View summary in command window
bsr.summary();

% Plot results
bsr.plotResponsivityCurve();
bsr.plotDetailedResults();

% Export results and figures to folder
bsr.exportResults('path/to/save/folder');
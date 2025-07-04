classdef BiosonarResponsivity < handle
    properties
        filename          % audio filename (string)
        waveform          % audio data vector
        fs                % sample rate
        callData          % struct from getCallTimestampsInteractive
        callTimes         % vector of call timestamps (seconds)
        t_call            % vector of call durations (seconds)
        results           % struct from analyse_responsivity_xyz
        kr                % responsivity scaling factor
        RcMax             % maximum physiological call rate (Hz)
        c = 343           % speed of sound (m/s), default 343
    end

    methods
        function obj = BiosonarResponsivity(filename, kr, RcMax, varargin)
            obj.filename = filename;
            [obj.waveform, obj.fs] = audioread(filename);
            obj.kr = kr;
            obj.RcMax = RcMax;
            for i = 1:length(varargin)
                arg = varargin{i};
                if isscalar(arg)
                    obj.c = arg;
                end
            end
        end

        function getCallTimestampsInteractive(obj)
            [obj.callData, obj.waveform, obj.fs] = getCallTimestampsInteractive(obj.filename);
            obj.callTimes = [obj.callData.startTime]';
            obj.t_call = [obj.callData.duration]';
        end

        function analyseResponsivity(obj)
            if isempty(obj.callTimes)
                error('Call timestamps not defined. Run getCallTimestampsInteractive first.');
            end
            varargin = {};
            if ~isempty(obj.t_call)
                varargin{end+1} = obj.t_call;
            end
            varargin{end+1} = obj.c;
            obj.results = analyse_responsivity(obj.callTimes, obj.kr, obj.RcMax, varargin{:});
        end

        function summary(obj)
            fprintf('Filename: %s\n', obj.filename);
            fprintf('Number of calls: %d\n', length(obj.callTimes));
            if ~isempty(obj.results)
                fprintf('Buzz readiness index: %d, time: %.3f s\n', ...
                    obj.results.readinessIndex, obj.results.readinessTime);
                fprintf('Mean IPI: %.3f ms\n', mean(obj.results.ipi)*1000);
                fprintf('Mean Ta (two-way echo delay): %.3f ms\n', mean(obj.results.Ta)*1000);
                fprintf('Mean Tb (reaction time): %.3f ms\n', mean(obj.results.Tb)*1000);
                fprintf('Tb prime: %.3f ms\n', obj.results.Tb_prime*1000);
            end
        end

        function plotRespCurve(obj)
            if isempty(obj.results)
                error('Run analyzeResponsivity first.');
            end
            plotResponsivityCurve(obj.results);  % calls external function
        end

        function plotDetailedResults(obj)
            if isempty(obj.results)
                error('Run analyzeResponsivity first.');
            end
            plotResponsivityResults(obj.results);
        end

        function plotIPI(obj)
            if isempty(obj.results)
                error('Run analyzeResponsivity first.');
            end
            plotIPI_CR(obj.results);
        end

        function exportResults(obj, destFolder)
            if isempty(obj.results)
                error('Run analyzeResponsivity first.');
            end
            if ~isfolder(destFolder)
                mkdir(destFolder);
            end

            % Extract base filename without path and extension
            [~, baseName, ~] = fileparts(obj.filename);

            % Create subfolder inside destFolder
            saveFolder = fullfile(destFolder, baseName);
            if ~isfolder(saveFolder)
                mkdir(saveFolder);
            end

            % Save responsivity curve figure
            fig2 = plotResponsivityCurve(obj.results);
            exportgraphics(fig2, fullfile(saveFolder, 'responsivity_curve.pdf'), 'ContentType', 'vector', 'Resolution', 300);
            close(fig2);

            % Save detailed results figure
            fig1 = plotResponsivityResults(obj.results);
            exportgraphics(fig1, fullfile(saveFolder, 'responsivity_analysis.pdf'), 'ContentType', 'vector', 'Resolution', 300);
            close(fig1);
            
            % Save IPI Curve
            fig3 = plotIPI_CR(obj.results);
            exportgraphics(fig3, fullfile(saveFolder, 'IPI_CR.pdf'), 'ContentType', 'vector', 'Resolution', 300);
            close(fig3);

            % Save results struct (the whole object)
            save(fullfile(saveFolder, 'results.mat'), 'obj');
        end
    end
end
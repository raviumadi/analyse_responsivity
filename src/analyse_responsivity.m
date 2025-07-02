function results = analyse_responsivity(callTimes, kr, RcMax, varargin)
% analyse_responsivity - Responsivity and buzz readiness analysis from call times
%
% Inputs:
%   callTimes : Nx1 vector of call timestamps (seconds)
%   kr        : responsivity scaling factor (Tb = kr * Ta)
%   RcMax     : maximum physiological call rate (Hz)
%   varargin  : optional
%               - t_call: call durations (s)
%               - c     : speed of sound (m/s), default 343
%
% Output:
%   results : structure with all derived fields

    % Defaults
    t_call = [];
    c = 343;

    % Parse optional inputs
    for i = 1:length(varargin)
        arg = varargin{i};
        if isvector(arg) && isempty(t_call) && all(arg < 0.1) && length(arg) == length(callTimes)
            t_call = arg(:);
        elseif isscalar(arg)
            c = arg;
        end
    end

    % Validate and align lengths
    ipi = diff(callTimes);
    if ~isempty(t_call)
        if length(t_call) == length(callTimes) - 1
            t_call = [t_call; NaN];
        elseif length(t_call) > length(callTimes)
            t_call = t_call(1:length(callTimes));
        elseif length(t_call) < length(callTimes)
            error('t_call must match callTimes length or be one less');
        end
    end

    % Core calculations
    Rc_n = 1 ./ ipi;
    Ta = ipi ./ (1 + kr);
    Tb = kr .* Ta;

    % Responsivity: inverse of ΔΔt
    dIpi = diff(ipi);
    R = 1 ./ dIpi;
    R = [NaN; R(:)]; % enforce column vector

    % Buzz readiness: where responsivity ~ RcMax
    [~, readinessIndex] = min(abs(abs(R) - RcMax));
    readinessTime = callTimes(readinessIndex);
    Tb_prime = NaN;
    if readinessIndex < length(ipi)
        Tb_prime = dIpi(readinessIndex+1);
    end

    % Target distance (estimate)
    targetDistance_estimated = Ta * c / 2;

    % Pack results
    results = struct();
    results.callTimes = callTimes;
    results.ipi = ipi;
    results.Rc_n = Rc_n;
    results.Ta = Ta;
    results.Tb = Tb;
    results.R = R;
    results.readinessIndex = readinessIndex;
    results.readinessTime = readinessTime;
    results.Tb_prime = Tb_prime;
    results.kr = kr;
    results.RcMax = RcMax;
    results.t_call = t_call;
    results.targetDistance_estimated = targetDistance_estimated;
    results.c = c;
end
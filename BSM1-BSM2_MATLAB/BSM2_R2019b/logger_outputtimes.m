function logger_outputtimes(model, start_time, stop_time, interval)
%SAFE_SET_OUTPUTTIMES Safely sets and logs the OutputTimes variable for a Simulink model
%   Arguments:
%     model       - Simulink model name (string)
%     start_time  - Start of simulation output time vector
%     stop_time   - End of simulation time
%     interval    - Time step interval (e.g., 1/96 for 15-min resolution)

    if nargin < 4
        interval = 1/96;
    end

    if start_time >= stop_time
        warning('Start time (%.3f) is not less than stop time (%.3f). Skipping OutputTimes update.', start_time, stop_time);
        return;
    end

    outputtimes = start_time:interval:stop_time;
    assignin('base', 'outputtimes', outputtimes);

    fprintf('✔ OutputTimes set for model %s\n', model);
    fprintf('  → Range: [%.3f : %.5f : %.3f] (%d steps)\n', ...
        start_time, interval, stop_time, length(outputtimes));
end

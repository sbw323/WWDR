function safe_set_outputtimes(model)
%SAFE_SET_OUTPUTTIMES Adjust the 'OutputTimes' setting in Simulink config
%
% This function reads the model StartTime and StopTime, aligns the start
% time to 15-minute steps (1/96 day), and assigns a compatible OutputTimes
% string to avoid Simulink range errors.

    try
        t_start = str2double(get_param(model, 'StartTime'));
        t_stop  = str2double(get_param(model, 'StopTime'));

        % Align start to 15-min step to match output steps (avoid 0.0001 precision errors)
        aligned_start = floor(t_start);

        % Build output time vector expression
        output_expr = sprintf('[%g:1/96:%g]', aligned_start, t_stop);

        % Apply to the model OutputTimes parameter
        set_param(model, 'OutputTimes', output_expr);
        fprintf('✔ OutputTimes set to %s for model %s\n', output_expr, model);

    catch ME
        fprintf('Failed to set OutputTimes on model %s\n', model);
        disp(getReport(ME, 'extended'));
    end
end

ss = 'bsm2_ss';
model = 'DR_bsm2_ol';
simend = 609;
cal_time = 245;       % Absolute first pause point [days]
pause_time = 14;      % Segment duration [days]
iteration = 1;        % Current iteration (manually set or loaded)
ss_done = false;
cal_pause_done = false;
segment_pause_done = false;
recal_segment_pause_done = false;

% === Setup Steady State === 
bsm2_ss;
init_bsm2_DR;
if ~ss_done
    set_param(ss, 'SimulationCommand', 'start');
    status = get_param(ss, 'SimulationStatus');
    if strcmp(status, 'stopped')
        stateset_bsm2
    end
    ss_done = true;
end
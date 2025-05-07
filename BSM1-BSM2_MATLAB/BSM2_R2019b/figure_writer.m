% Define the base output directory
base_output_dir = '/Users/aya/github/WWDR/BSM1-BSM2_MATLAB/BSM2_R2019b/DR_images';

% Define the iteration-specific subfolder name
iteration_folder = sprintf('iter%d', iteration);

% Construct the full output path
full_output_path = fullfile(base_output_dir, iteration_folder);

% Create the directory if it doesn't exist
if ~exist(full_output_path, 'dir')
    mkdir(full_output_path);
end

% Get list of all figure handles
figHandles = findall(0, 'Type', 'figure');

% Loop over all figures
for i = 1:length(figHandles)
    fig = figHandles(i);
    % Make sure it's the active figure
    figure(fig);

    % Try to get the title of the first axes
    ax = findall(fig, 'Type', 'axes');
    if isempty(ax)
        title_str = sprintf('Figure_%d', i);
    else
        % Use the first axes only
        ax_title = get(get(ax(1), 'Title'), 'String');
        if iscell(ax_title)
            ax_title = ax_title{1};
        end
        % Default to fallback name if title is empty
        if isempty(ax_title)
            title_str = sprintf('Figure_%d', i);
        else
            title_str = ax_title;
        end
    end

    % Clean title string to make it a valid filename
    title_str = regexprep(title_str, '[^\w]', '_');  % Replace non-alphanumerics with underscores

    % Create filename
    filename = sprintf('%s_iter%d.png', title_str, iteration);

    % Full file path
    full_path = fullfile(full_output_path, filename);

    % Save the figure
    exportgraphics(fig, full_path, 'Resolution', 300);
end

fprintf('Saved %d figures to "%s".\n', length(figHandles), full_output_path);
close all
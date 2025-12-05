function analyze_datasets()
    % Define datasets to analyze
    % Check for existence within known paths
    files = {
        'alice29.txt', 'Alice In Wonderland (Text)';
        'kennedy.xls', 'Kennedy Excel (Binary)'
    };
    
    % Attempt to find the data directory
    if exist('data/canterbury', 'dir')
        base_path = 'data/canterbury';
    elseif exist('data', 'dir')
        base_path = 'data';
    else
        error('Could not find data directory');
    end
    
    % Ensure images directory exists
    if ~exist('images', 'dir')
        mkdir('images');
    end
    
    for i = 1:size(files, 1)
        fname = files{i, 1};
        nice_name = files{i, 2};
        full_path = fullfile(base_path, fname);
        
        if exist(full_path, 'file')
            fprintf('Processing %s...\n', fname);
            process_file(full_path, fname, nice_name);
        else
            fprintf('Warning: File %s not found. Skipping.\n', full_path);
        end
    end
end

function process_file(filepath, name, nice_name)
    % Read file
    fid = fopen(filepath, 'r');
    if fid == -1
        return;
    end
    data = fread(fid, Inf, 'uint8');
    fclose(fid);
    
    [~, n_base, ~] = fileparts(name);
    
    % --- 1. Histogram ---
    h1 = figure('Visible', 'off');
    histogram(data, 0:255, 'Normalization', 'probability', 'EdgeColor', 'none', 'FaceColor', 'b');
    title(['Byte Frequency: ' nice_name]);
    xlabel('Byte Value (0-255)');
    ylabel('Probability');
    grid on;
    % Force axis to full byte range
    xlim([0 255]);
    
    out_hist = fullfile('images', ['hist_' n_base '.png']);
    saveas(h1, out_hist);
    close(h1);
    
    % --- 2. Rolling Entropy ---
    w_size = 1000;
    step = 200;
    
    if length(data) < w_size
        return; % Too small for this window analysis
    end
    
    indices = 1:step:(length(data)-w_size);
    entropy_vals = zeros(length(indices), 1);
    
    % Pre-calculate logs for speed (classic entropy optimization)
    % Actually standard loop is fine for these file sizes
    
    for k = 1:length(indices)
        idx = indices(k);
        window = data(idx : idx+w_size-1);
        
        % Calculate entropy of window
        counts = histcounts(window, 0:256);
        p = counts(counts > 0) / w_size;
        entropy_vals(k) = -sum(p .* log2(p));
    end
    
    h2 = figure('Visible', 'off');
    plot(indices, entropy_vals, 'LineWidth', 1.5, 'Color', [0.8500 0.3250 0.0980]);
    title(['Rolling Entropy (Window=1KB): ' nice_name]);
    xlabel('File Offset (Bytes)');
    ylabel('Entropy (bits/symbol)');
    ylim([0 8]); % Entropy is bounded by 8 for bytes
    grid on;
    
    out_ent = fullfile('images', ['entropy_' n_base '.png']);
    saveas(h2, out_ent);
    close(h2);
end

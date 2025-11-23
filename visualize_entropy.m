% visualize_entropy.m
% Visualizes the instantaneous entropy (information content) of a file
% as perceived by a probability model.

function visualize_entropy()
    % Configuration
    filename = 'data/canterbury/alice29.txt';
    model_type = 'markov1'; % Options: 'markov1', 'markov2', 'fsm'
    window_size = 100; % Moving average window size
    
    % Check if file exists
    if ~exist(filename, 'file')
        % Use random data if file not found (for testing)
        fprintf('File %s not found. Using random data.\n', filename);
        seq = randi([1, 27], 1, 2000);
    else
        fid = fopen(filename, 'r');
        seq = fread(fid, 2000, 'uint8')'; % Read first 2000 bytes for visualization
        fclose(fid);
        % Map to 1-based index if needed (simple assumption for text)
        % In a real scenario, we'd use the same mapping as the main coder
        seq = double(seq) + 1; 
    end
    
    alphabet_size = 256;
    
    % Instantiate Model
    switch model_type
        case 'markov1'
            model = model_markov_1(alphabet_size);
        case 'markov2'
            model = model_markov_2(alphabet_size);
        case 'fsm'
            model = model_fsm(alphabet_size);
        otherwise
            error('Unknown model type');
    end
    
    % Calculate Information Content
    n = length(seq);
    info_content = zeros(1, n);
    
    fprintf('Processing sequence of length %d...\n', n);
    
    for i = 1:n
        symbol = seq(i);
        
        % Get probability of the symbol
        [~, L, H] = model.get_symbol(symbol); 
        % Note: get_symbol returns [symbol_decoded, low, high] or similar depending on impl.
        % Actually, standard interface is [low, high] = get_range(symbol)
        % But we need the probability P = high - low.
        
        [low, high] = model.get_range(symbol);
        prob = high - low;
        
        % Avoid log(0)
        if prob <= 0
            prob = 1e-10;
        end
        
        % Information Content (bits)
        info_content(i) = -log2(prob);
        
        % Update model
        model.update(symbol);
    end
    
    % Calculate Moving Average
    moving_avg = movmean(info_content, window_size);
    
    % Plot
    h = figure('Visible', 'off'); % Invisible figure for saving
    plot(1:n, info_content, 'Color', [0.8 0.8 0.8], 'DisplayName', 'Instantaneous');
    hold on;
    plot(1:n, moving_avg, 'r', 'LineWidth', 2, 'DisplayName', sprintf('Moving Avg (w=%d)', window_size));
    xlabel('Symbol Index');
    ylabel('Information Content (bits)');
    title(sprintf('Entropy Visualization (%s)', model_type));
    legend;
    grid on;
    
    % Save
    output_file = 'images/entropy_plot.png';
    saveas(h, output_file);
    fprintf('Plot saved to %s\n', output_file);
    
    % Close figure
    close(h);
end

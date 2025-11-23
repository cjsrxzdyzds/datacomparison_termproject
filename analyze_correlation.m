% -------------------------------------------------------------------------
% Section: Analysis
% Purpose: Analyze correlation between probability models
% Input:   None
% Output:  Correlation matrix plot
% -------------------------------------------------------------------------

fprintf('=== Model Correlation Analysis ===\n\n');

% 1. Load Data
filename = 'data/alice29.txt';
if ~isfile(filename)
    fprintf('Warning: %s not found. Using random data.\n', filename);
    seq = randi([0, 255], 1, 2000);
else
    fid = fopen(filename, 'r');
    seq = fread(fid, 2000, 'uint8')'; % Read first 2000 bytes
    fclose(fid);
end

% Shift to 1-based indexing
seq = double(seq) + 1;
alphabet_size = 256;
n = length(seq);

% 2. Initialize Models
models = {
    'Markov 1', model_markov_1(alphabet_size);
    'Markov 2', model_markov_2(alphabet_size);
    'Markov 3', model_markov_3(alphabet_size);
    'FSM',      model_fsm(alphabet_size);
    'RNN',      model_lstm(alphabet_size)
};

num_models = size(models, 1);
probabilities = zeros(n, num_models);

fprintf('Processing %d symbols with %d models...\n', n, num_models);

% 3. Collect Predictions
for i = 1:n
    symbol = seq(i);
    
    for m = 1:num_models
        model = models{m, 2};
        
        % Get probability of the actual symbol
        [L, H] = model.get_range(symbol);
        prob = H - L;
        probabilities(i, m) = prob;
        
        % Update model
        model.update(symbol);
    end
    
    if mod(i, 500) == 0
        fprintf('  Processed %d/%d symbols\n', i, n);
    end
end

% 4. Compute Correlation
% Manual implementation of Pearson correlation to avoid toolbox dependency
% corr(X, Y) = cov(X, Y) / (std(X) * std(Y))
mean_probs = mean(probabilities);
centered_probs = probabilities - mean_probs;
cov_matrix = (centered_probs' * centered_probs) / (n - 1);
std_devs = std(probabilities);
corr_matrix = cov_matrix ./ (std_devs' * std_devs);

% 5. Visualize
figure('Name', 'Model Correlation', 'NumberTitle', 'off');
h = heatmap(models(:, 1), models(:, 1), corr_matrix);
h.Title = 'Correlation of Model Probabilities';
h.ColorLimits = [0, 1];
colormap('jet');

% Save
if ~exist('images', 'dir')
    mkdir('images');
end
saveas(gcf, 'images/model_correlation.png');
fprintf('Correlation matrix saved to images/model_correlation.png\n');

% Display Matrix
disp('Correlation Matrix:');
disp(array2table(corr_matrix, 'RowNames', models(:, 1), 'VariableNames', models(:, 1)));

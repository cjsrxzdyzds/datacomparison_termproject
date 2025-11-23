% -------------------------------------------------------------------------
% Section: Experiments
% Purpose: Benchmark Context Mixing Model against individual models
% Input:   None
% Output:  Console output with compression results
% -------------------------------------------------------------------------

fprintf('=== Context Mixing Benchmark ===\n\n');

% Load a test file (using one of the Canterbury Corpus files if available, else generate random)
filename = 'data/alice29.txt';
if ~isfile(filename)
    fprintf('Warning: %s not found. Using random data.\n', filename);
    seq = randi([0, 255], 1, 1000);
else
    fid = fopen(filename, 'r');
    seq = fread(fid, 1000, 'uint8')'; % Read first 1000 bytes for speed
    fclose(fid);
end

% Shift to 1-based indexing for MATLAB
seq = double(seq) + 1;

alphabet_size = 256;
fprintf('Data size: %d bytes\n', length(seq));

%% 1. Individual Models
fprintf('\n--- Individual Models ---\n');

% Markov 1
model = model_markov_1(alphabet_size);
tic;
code = arithmetic_encode(seq, model);
t = toc;
fprintf('Markov 1: %.2f bits/symbol (%.4f s)\n', length(code)/length(seq), t);

% Markov 2
model = model_markov_2(alphabet_size);
tic;
code = arithmetic_encode(seq, model);
t = toc;
fprintf('Markov 2: %.2f bits/symbol (%.4f s)\n', length(code)/length(seq), t);

%% 2. Context Mixing
fprintf('\n--- Context Mixing ---\n');

% Mix 1 & 2
models = {model_markov_1(alphabet_size), model_markov_2(alphabet_size)};
model = model_mixing(models, alphabet_size);
tic;
code = arithmetic_encode(seq, model);
t = toc;
fprintf('Mixing (M1+M2): %.2f bits/symbol (%.4f s)\n', length(code)/length(seq), t);

% Check weights
fprintf('Final Weights: M1=%.2f, M2=%.2f\n', model.weights(1), model.weights(2));

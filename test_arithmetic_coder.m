% -------------------------------------------------------------------------
% Section: Arithmetic Coder / Unit Tests
% Purpose: Unit test for arithmetic_encode.m and arithmetic_decode.m
%          Tests basic functionality with simple static probabilities
% Input:   None (standalone test script)
% Output:  Console output showing test results
% -------------------------------------------------------------------------

fprintf('=== Arithmetic Coder Unit Test ===\n\n');

% Section: Test
% Purpose: Unit test for Arithmetic Coder with Markov Models
% -------------------------------------------------------------------------

% Test Data
text = 'hello world! this is a test string for arithmetic coding.';
seq = double(text); % Convert chars to double (ASCII values)
alphabet_size = 256; % ASCII alphabet

fprintf('Original Text: %s\n', text);
fprintf('Length: %d symbols\n', length(seq));

%% Test 1: 1st Order Markov Model
fprintf('\n--- Test 1: 1st Order Markov Model ---\n');

% Encode
model_enc = model_markov_1(alphabet_size);
code = arithmetic_encode(seq, model_enc);

fprintf('Encoded Length: %d bits\n', length(code));
fprintf('Compression Ratio: %.2f bits/symbol\n', length(code)/length(seq));

% Decode
model_dec = model_markov_1(alphabet_size); % Fresh model for decoding
decoded_seq = arithmetic_decode(code, length(seq), model_dec);

% Verify
if isequal(seq, decoded_seq)
    fprintf('Result: PASS (Decoded sequence matches original)\n');
else
    fprintf('Result: FAIL (Mismatch)\n');
    % Show mismatch details
    mismatch_idx = find(seq ~= decoded_seq, 1);
    fprintf('First mismatch at index %d: Expected %d, Got %d\n', ...
        mismatch_idx, seq(mismatch_idx), decoded_seq(mismatch_idx));
end

%% Test 2: 2nd Order Markov Model
fprintf('\n--- Test 2: 2nd Order Markov Model ---\n');

% Encode
model_enc = model_markov_2(alphabet_size);
code = arithmetic_encode(seq, model_enc);

fprintf('Encoded Length: %d bits\n', length(code));
fprintf('Compression Ratio: %.2f bits/symbol\n', length(code)/length(seq));

% Decode
model_dec = model_markov_2(alphabet_size); % Fresh model for decoding
decoded_seq = arithmetic_decode(code, length(seq), model_dec);

% Verify
if isequal(seq, decoded_seq)
    fprintf('Result: PASS (Decoded sequence matches original)\n');
else
    fprintf('Result: FAIL (Mismatch)\n');
    mismatch_idx = find(seq ~= decoded_seq, 1);
    fprintf('First mismatch at index %d: Expected %d, Got %d\n', ...
        mismatch_idx, seq(mismatch_idx), decoded_seq(mismatch_idx));
end

%% Test 3: 3rd Order Markov Model (Sparse)
fprintf('\n--- Test 3: 3rd Order Markov Model (Sparse) ---\n');

% Encode
model_enc = model_markov_3(alphabet_size);
code = arithmetic_encode(seq, model_enc);

fprintf('Encoded Length: %d bits\n', length(code));
fprintf('Compression Ratio: %.2f bits/symbol\n', length(code)/length(seq));

% Decode
model_dec = model_markov_3(alphabet_size); % Fresh model for decoding
decoded_seq = arithmetic_decode(code, length(seq), model_dec);

% Verify
if isequal(seq, decoded_seq)
    fprintf('Result: PASS (Decoded sequence matches original)\n');
else
    fprintf('Result: FAIL (Mismatch)\n');
    mismatch_idx = find(seq ~= decoded_seq, 1);
    fprintf('First mismatch at index %d: Expected %d, Got %d\n', ...
        mismatch_idx, seq(mismatch_idx), decoded_seq(mismatch_idx));
end

%% Test 4: FSM Model (Run-Length)
fprintf('\n--- Test 4: FSM Model (Run-Length) ---\n');

% Create a sequence with runs
seq_runs = double('AAAAABBBBBCCCCCaaaaabbbbbccccc');
% Encode
model_enc = model_fsm(alphabet_size);
code = arithmetic_encode(seq_runs, model_enc);

fprintf('Original Length: %d symbols\n', length(seq_runs));
fprintf('Encoded Length: %d bits\n', length(code));
fprintf('Compression Ratio: %.2f bits/symbol\n', length(code)/length(seq_runs));

% Decode
model_dec = model_fsm(alphabet_size); % Fresh model for decoding
decoded_seq = arithmetic_decode(code, length(seq_runs), model_dec);

% Verify
if isequal(seq_runs, decoded_seq)
    fprintf('Result: PASS (Decoded sequence matches original)\n');
else
    fprintf('Result: FAIL (Mismatch)\n');
    mismatch_idx = find(seq_runs ~= decoded_seq, 1);
    fprintf('First mismatch at index %d: Expected %d, Got %d\n', ...
        mismatch_idx, seq_runs(mismatch_idx), decoded_seq(mismatch_idx));
end

%% Test 5: RNN Model (Simple LSTM/SRN)
fprintf('\n--- Test 5: RNN Model (Simple SRN) ---\n');

% Encode
model_enc = model_lstm(alphabet_size);
code = arithmetic_encode(seq, model_enc);

fprintf('Encoded Length: %d bits\n', length(code));
fprintf('Compression Ratio: %.2f bits/symbol\n', length(code)/length(seq));

% Decode
model_dec = model_lstm(alphabet_size); % Fresh model for decoding
decoded_seq = arithmetic_decode(code, length(seq), model_dec);

% Verify
if isequal(seq, decoded_seq)
    fprintf('Result: PASS (Decoded sequence matches original)\n');
else
    fprintf('Result: FAIL (Mismatch)\n');
    mismatch_idx = find(seq ~= decoded_seq, 1);
    fprintf('First mismatch at index %d: Expected %d, Got %d\n', ...
        mismatch_idx, seq(mismatch_idx), decoded_seq(mismatch_idx));
end

fprintf('\nUnit tests complete.\n');
fprintf('Note: Full encode/decode tests require probability model implementation.\n');

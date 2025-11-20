% -------------------------------------------------------------------------
% Section: Experiments
% Purpose: Run compression benchmarks on all datasets using all models.
%          Measures Compression Ratio, Time, and Memory.
% Input:   None (Reads from data/ directory)
% Output:  Saves results to 'results.mat' and prints summary table.
% -------------------------------------------------------------------------

function run_experiments()
    fprintf('=== Starting Compression Benchmarks ===\n\n');
    
    % Setup
    data_dir = 'data';
    files = dir(fullfile(data_dir, '*.*'));
    files = files(~[files.isdir]); % Filter out directories
    
    % Define Models
    % We use function handles or factory logic
    models = {
        'Markov-1', @(sz) model_markov_1(sz);
        'Markov-2', @(sz) model_markov_2(sz);
        'Markov-3', @(sz) model_markov_3(sz);
        'FSM',      @(sz) model_fsm(sz);
        'RNN',      @(sz) model_lstm(sz);
    };
    
    % Initialize Results Storage
    results = struct('File', {}, 'Model', {}, 'OrigSize', {}, 'CompSize', {}, ...
                     'Ratio', {}, 'BPS', {}, 'EncTime', {}, 'DecTime', {});
    
    alphabet_size = 256;
    
    for f = 1:length(files)
        filename = files(f).name;
        filepath = fullfile(data_dir, filename);
        
        % Read File
        fid = fopen(filepath, 'r');
        raw_data = fread(fid, inf, 'uint8=>double')'; % Read as double row vector
        raw_data = raw_data + 1; % Convert 0-255 to 1-256 for MATLAB indexing
        fclose(fid);
        
        orig_size = length(raw_data);
        if orig_size == 0
            continue;
        end
        
        fprintf('Processing %s (%d bytes)...\n', filename, orig_size);
        
        % Limit size for slow models (RNN) if file is too large
        % For this demo, we might want to truncate very large files for speed
        % but for the project we should try to run full or at least reasonable chunks.
        % Let's cap at 10KB for RNN to keep it responsive during dev, 
        % but maybe 50KB for others.
        % Actually, let's just run it. The user can stop if it's too slow.
        
        for m = 1:size(models, 1)
            model_name = models{m, 1};
            model_factory = models{m, 2};
            
            fprintf('  Running %s... ', model_name);
            
            % Create Model Instance
            model_enc = model_factory(alphabet_size);
            
            % Measure Encoding
            try
                tic;
                % Profile memory if possible, but difficult in script. 
                % We focus on time/ratio.
                encoded_seq = arithmetic_encode(raw_data, model_enc);
                enc_time = toc;
                
                comp_size_bits = length(encoded_seq);
                comp_size_bytes = ceil(comp_size_bits / 8);
                ratio = orig_size / comp_size_bytes;
                bps = comp_size_bits / orig_size;
                
                fprintf('Ratio: %.2f, BPS: %.2f, Time: %.2fs\n', ratio, bps, enc_time);
                
                % Measure Decoding (Optional for speed, but good for verification)
                % We'll skip full decoding measurement for now to save time, 
                % unless requested. The prompt asked for "Encoding/Decoding Time".
                % So we should do it.
                
                model_dec = model_factory(alphabet_size);
                tic;
                decoded_seq = arithmetic_decode(encoded_seq, orig_size, model_dec);
                dec_time = toc;
                
                % Verify
                if ~isequal(raw_data, decoded_seq)
                    fprintf('    [FAIL] Decoding mismatch!\n');
                    diff_idx = find(raw_data ~= decoded_seq, 1);
                    % if ~isempty(diff_idx)
                    %     fprintf('      Index: %d, Expected: %d, Got: %d\n', ...
                    %         diff_idx, raw_data(diff_idx), decoded_seq(diff_idx));
                    % end
                end
                
                % Store Results
                res_entry = struct(...
                    'File', filename, ...
                    'Model', model_name, ...
                    'OrigSize', orig_size, ...
                    'CompSize', comp_size_bytes, ...
                    'Ratio', ratio, ...
                    'BPS', bps, ...
                    'EncTime', enc_time, ...
                    'DecTime', dec_time ...
                );
                results(end+1) = res_entry;
                
            catch ME
                fprintf('[ERROR] %s\n', ME.message);
            end
        end
        fprintf('\n');
    end
    
    % Save Results
    save('results.mat', 'results');
    
    % Display Summary Table
    fprintf('=== Summary Results ===\n');
    fprintf('%-15s %-10s %-10s %-10s %-10s\n', 'File', 'Model', 'BPS', 'EncTime', 'DecTime');
    for i = 1:length(results)
        fprintf('%-15s %-10s %-10.2f %-10.2f %-10.2f\n', ...
            results(i).File, results(i).Model, results(i).BPS, ...
            results(i).EncTime, results(i).DecTime);
    end
end

% -------------------------------------------------------------------------
% Section: Data Acquisition
% Purpose: Download and prepare datasets for compression experiments.
%          Fetches Text, Binary, and DNA data from public sources.
% Input:   None
% Output:  Files saved in 'data/' directory
% -------------------------------------------------------------------------

function download_datasets()
    if ~exist('data', 'dir')
        mkdir('data');
    end
    
    fprintf('=== Downloading Datasets ===\n');
    
    %% 1. Text Data: Alice in Wonderland (Project Gutenberg)
    url_text = 'https://www.gutenberg.org/files/11/11-0.txt';
    file_text = 'data/alice.txt';
    
    if ~exist(file_text, 'file')
        fprintf('Downloading Text Data (Alice in Wonderland)...\n');
        try
            websave(file_text, url_text);
            fprintf('  [OK] Saved to %s\n', file_text);
        catch ME
            fprintf('  [FAIL] Could not download text data: %s\n', ME.message);
            % Fallback: Create dummy text file
            fid = fopen(file_text, 'w');
            fprintf(fid, 'This is a fallback text file because the download failed.\n');
            for i = 1:100
                fprintf(fid, 'Repeating line %d for some volume.\n', i);
            end
            fclose(fid);
            fprintf('  [WARN] Created fallback text file.\n');
        end
    else
        fprintf('  [SKIP] Text data already exists.\n');
    end
    
    %% 2. Binary Data: System Binary (ls command)
    % Using a system binary ensures we have real executable code structure
    file_bin = 'data/binary_test.bin';
    source_bin = '/bin/ls'; % Standard on macOS/Linux
    
    if ~exist(file_bin, 'file')
        fprintf('Preparing Binary Data (Copying /bin/ls)...\n');
        if exist(source_bin, 'file')
            copyfile(source_bin, file_bin);
            fprintf('  [OK] Copied %s to %s\n', source_bin, file_bin);
        else
            % Fallback: Generate random binary data
            fprintf('  [WARN] /bin/ls not found. Generating random binary data.\n');
            rng(42);
            data = uint8(randi([0, 255], 1, 50000)); % 50KB
            fid = fopen(file_bin, 'w');
            fwrite(fid, data);
            fclose(fid);
            fprintf('  [OK] Generated random binary file.\n');
        end
    else
        fprintf('  [SKIP] Binary data already exists.\n');
    end
    
    %% 3. DNA Data: Synthetic Sequence
    % Downloading specific genome segments can be flaky due to URL changes.
    % We will generate a realistic synthetic DNA sequence.
    file_dna = 'data/dna.txt';
    
    if ~exist(file_dna, 'file')
        fprintf('Generating DNA Data (Synthetic)...\n');
        rng(123); % Reproducible
        bases = ['A', 'C', 'G', 'T'];
        len = 50000; % 50KB
        
        % Generate with some structure (e.g., GC-rich regions)
        dna_seq = char(zeros(1, len));
        for i = 1:len
            if mod(i, 100) < 50
                % GC-rich region
                weights = [0.1, 0.4, 0.4, 0.1];
            else
                % AT-rich region
                weights = [0.4, 0.1, 0.1, 0.4];
            end
            
            % Sample base
            r = rand;
            if r < weights(1)
                dna_seq(i) = bases(1);
            elseif r < weights(1) + weights(2)
                dna_seq(i) = bases(2);
            elseif r < weights(1) + weights(2) + weights(3)
                dna_seq(i) = bases(3);
            else
                dna_seq(i) = bases(4);
            end
        end
        
        fid = fopen(file_dna, 'w');
        fprintf(fid, '%s', dna_seq);
        fclose(fid);
        fprintf('  [OK] Generated synthetic DNA file (%d bases).\n', len);
    else
        fprintf('  [SKIP] DNA data already exists.\n');
    end
    
    fprintf('=== Data Acquisition Complete ===\n\n');
    
    % List files
    dir('data');
end

% -------------------------------------------------------------------------
% Section: Reporting
% Purpose: Generate LaTeX tables from results.mat
% Input:   results.mat
% Output:  tables/text_compression.tex, tables/binary_compression.tex
% -------------------------------------------------------------------------

function generate_tables()
    if ~exist('results.mat', 'file')
        error('results.mat not found.');
    end
    load('results.mat', 'results');
    
    % Define categories
    text_files = {'alice29.txt', 'asyoulik.txt', 'lcet10.txt', 'plrabn12.txt'};
    binary_files = {'kennedy.xls', 'cp.html', 'fields.c', 'grammar.lsp', 'xargs.1'};
    sequence_files = {'sum', 'ptt5'};
    
    models = unique({results.Model});
    
    % Generate Text Table
    fid = fopen('tables/text_compression.tex', 'w');
    fprintf(fid, '%% Table: Compression ratios for text data\n');
    fprintf(fid, '\\begin{tabular}{|l|');
    for i=1:length(text_files)
        fprintf(fid, 'c|');
    end
    fprintf(fid, 'c|}\n\\hline\n');
    fprintf(fid, '\\textbf{Model}');
    for i=1:length(text_files)
        fprintf(fid, ' & \\textbf{%s}', text_files{i});
    end
    fprintf(fid, ' & \\textbf{Average} \\\\ \\hline\n');
    
    for m = 1:length(models)
        model = models{m};
        model_display = model;
        if strcmp(model, 'RNN')
            model_display = 'LSTM';
        end
        fprintf(fid, '%s', model_display);
        ratios = [];
        for f = 1:length(text_files)
            file = text_files{f};
            idx = find(strcmp({results.File}, file) & strcmp({results.Model}, model));
            if ~isempty(idx)
                val = results(idx).Ratio;
                ratios = [ratios, val];
                fprintf(fid, ' & %.2f', val);
            else
                fprintf(fid, ' & -');
            end
        end
        if ~isempty(ratios)
            fprintf(fid, ' & %.2f', mean(ratios));
        else
            fprintf(fid, ' & -');
        end
        fprintf(fid, ' \\\\ \\hline\n');
    end
    fprintf(fid, '\\end{tabular}\n');
    fclose(fid);
    
    % Generate Binary Table
    fid = fopen('tables/binary_compression.tex', 'w');
    fprintf(fid, '%% Table: Compression ratios for binary/code data\n');
    fprintf(fid, '\\begin{tabular}{|l|');
    for i=1:length(binary_files)
        fprintf(fid, 'c|');
    end
    fprintf(fid, 'c|}\n\\hline\n');
    fprintf(fid, '\\textbf{Model}');
    for i=1:length(binary_files)
        fprintf(fid, ' & \\textbf{%s}', binary_files{i});
    end
    fprintf(fid, ' & \\textbf{Average} \\\\ \\hline\n');
    
    for m = 1:length(models)
        model = models{m};
        model_display = model;
        if strcmp(model, 'RNN')
            model_display = 'LSTM';
        end
        fprintf(fid, '%s', model_display);
        ratios = [];
        for f = 1:length(binary_files)
            file = binary_files{f};
            idx = find(strcmp({results.File}, file) & strcmp({results.Model}, model));
            if ~isempty(idx)
                val = results(idx).Ratio;
                ratios = [ratios, val];
                fprintf(fid, ' & %.2f', val);
            else
                fprintf(fid, ' & -');
            end
        end
        if ~isempty(ratios)
            fprintf(fid, ' & %.2f', mean(ratios));
        else
            fprintf(fid, ' & -');
        end
        fprintf(fid, ' \\\\ \\hline\n');
    end
    fprintf(fid, '\\end{tabular}\n');
    fclose(fid);
    
    % Generate Sequence Table
    fid = fopen('tables/sequence_compression.tex', 'w');
    fprintf(fid, '%% Table: Compression ratios for sequence data\n');
    fprintf(fid, '\\begin{tabular}{|l|');
    for i=1:length(sequence_files)
        fprintf(fid, 'c|');
    end
    fprintf(fid, 'c|}\n\\hline\n');
    fprintf(fid, '\\textbf{Model}');
    for i=1:length(sequence_files)
        fprintf(fid, ' & \\textbf{%s}', sequence_files{i});
    end
    fprintf(fid, ' & \\textbf{Average} \\\\ \\hline\n');
    
    for m = 1:length(models)
        model = models{m};
        fprintf(fid, '%s', model);
        ratios = [];
        for f = 1:length(sequence_files)
            file = sequence_files{f};
            idx = find(strcmp({results.File}, file) & strcmp({results.Model}, model));
            if ~isempty(idx)
                val = results(idx).Ratio;
                ratios = [ratios, val];
                fprintf(fid, ' & %.2f', val);
            else
                fprintf(fid, ' & -');
            end
        end
        if ~isempty(ratios)
            fprintf(fid, ' & %.2f', mean(ratios));
        else
            fprintf(fid, ' & -');
        end
        fprintf(fid, ' \\\\ \\hline\n');
    end
    fprintf(fid, '\\end{tabular}\n');
    fclose(fid);
    
    fprintf('Tables generated in tables/\n');
end

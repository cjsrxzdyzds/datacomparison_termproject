function code = arithmetic_encode(seq, model)
% -------------------------------------------------------------------------
% Section: Arithmetic Coder
% Purpose: Encodes a sequence of symbols using arithmetic coding based on
%          a provided probability model.
% Input:   seq   - Vector of symbols to encode
%          model - Struct or object containing the probability model
%                  Must support a method/function to get probability range:
%                  [low, high] = model.get_range(symbol)
%                  model.update(symbol)
% Output:  code  - Compressed binary stream (logical vector)
% -------------------------------------------------------------------------

    % Initialize intervals
    low = 0.0;
    high = 1.0;
    
    % Initialize output code
    code = logical([]);
    pending_bits = 0;
    
    % Loop through the sequence
    for i = 1:length(seq)
        symbol = seq(i);
        
        % Get probability range from model
        [L, H] = model.get_range(symbol); 
        
        % Update range
        range = high - low;
        high = low + range * H;
        low = low + range * L;
        
        % Renormalization (E1, E2, E3 mappings)
        while true
            if high < 0.5
                % E1: Output 0, then pending 1s
                code = [code, false, true(1, pending_bits)];
                pending_bits = 0;
                low = 2 * low;
                high = 2 * high;
            elseif low >= 0.5
                % E2: Output 1, then pending 0s
                code = [code, true, false(1, pending_bits)];
                pending_bits = 0;
                low = 2 * (low - 0.5);
                high = 2 * (high - 0.5);
            elseif low >= 0.25 && high < 0.75
                % E3: Increment pending bits, scale middle
                pending_bits = pending_bits + 1;
                low = 2 * (low - 0.25);
                high = 2 * (high - 0.25);
            else
                break;
            end
        end
        
        % Update model
        model.update(symbol);
    end
    
    % Final bits output
    pending_bits = pending_bits + 1;
    if low < 0.25
        code = [code, false, true(1, pending_bits)];
    else
        code = [code, true, false(1, pending_bits)];
    end
end

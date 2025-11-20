function seq = arithmetic_decode(code, len, model)
% -------------------------------------------------------------------------
% Section: Arithmetic Coder
% Purpose: Decodes a compressed binary stream into a sequence of symbols
%          using arithmetic coding based on a provided probability model.
% Input:   code  - Compressed binary stream (logical vector)
%          len   - Length of the original sequence to decode
%          model - Struct or object containing the probability model
%                  Must support a method/function to get symbol from prob:
%                  [symbol, low, high] = model.get_symbol(value)
%                  model.update(symbol)
% Output:  seq   - Reconstructed sequence of symbols
% -------------------------------------------------------------------------

    % Initialize intervals
    low = 0.0;
    high = 1.0;
    
    % Initialize output sequence
    seq = zeros(1, len);
    
    % Initialize value buffer
    % Read the first K bits from 'code' into 'value'
    % We use a fixed precision window, e.g., 16 bits or just double precision 
    % concept. Here we maintain 'value' as a double in [0, 1).
    
    value = 0.0;
    % Consume enough bits to fill the precision or just use the stream
    % For this implementation, we'll simulate reading bits one by one 
    % to maintain the 'value' inside the current [low, high) window?
    % Actually, standard implementation initializes 'value' with the first few bits.
    % Let's assume we read bits as needed or pre-fill.
    % Since we use doubles, let's read the first 32 bits (or length of code)
    
    code_idx = 1;
    PRECISION = 52;
    for k = 1:min(PRECISION, length(code))
        if code(k)
            value = value + 2^(-k);
        end
        code_idx = code_idx + 1;
    end
    % If code is shorter than PRECISION, subsequent bits are 0.
    
    % Loop to decode each symbol
    for i = 1:len
        % Find symbol that fits the current value
        % We need to map 'value' from [0, 1) global to [0, 1) local range
        % value_local = (value - low) / (high - low)
        
        range = high - low;
        value_local = (value - low) / range;
        
        [symbol, L, H] = model.get_symbol(value_local);
        seq(i) = symbol;
        
        % Update range
        high = low + range * H;
        low = low + range * L;
        
        % Renormalization (E1, E2, E3 mappings)
        while true
            if high < 0.5
                % E1: Shift out 0
                low = 2 * low;
                high = 2 * high;
                value = 2 * value;
            elseif low >= 0.5
                % E2: Shift out 1
                low = 2 * (low - 0.5);
                high = 2 * (high - 0.5);
                value = 2 * (value - 0.5);
            elseif low >= 0.25 && high < 0.75
                % E3: Scale middle
                low = 2 * (low - 0.25);
                high = 2 * (high - 0.25);
                value = 2 * (value - 0.25);
            else
                break;
            end
            
            % Read next bit
            if code_idx <= length(code)
                if code(code_idx)
                    value = value + 2^(-PRECISION); % Add bit at the LSB of the window
                end
                code_idx = code_idx + 1;
            end
        end
        
        % Update model
        model.update(symbol);
    end
end

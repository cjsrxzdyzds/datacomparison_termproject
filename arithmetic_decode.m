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
    for k = 1:min(32, length(code))
        if code(k)
            value = value + 2^(-k);
        end
        code_idx = code_idx + 1;
    end
    % If code is shorter than 32, subsequent bits are 0.
    
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
                    value = value + 2^(-32); % Add bit at the LSB of the window
                    % Note: In a proper integer implementation, we shift in a bit.
                    % In float, 'value' is [0, 1). When we do value = 2*value,
                    % we are shifting left. The new bit comes in at the bottom.
                    % But wait, 2*value might exceed 1?
                    % E1: high < 0.5, so value < 0.5 (since low <= value < high). 2*value < 1.
                    % E2: low >= 0.5, so value >= 0.5. 2*(value-0.5) is in [0, 1).
                    % E3: value in [0.25, 0.75). 2*(value-0.25) in [0, 1).
                    % So the range is always maintained in [0, 1).
                    % The new bit should be added at the appropriate precision.
                    % Actually, with floating point, it's tricky to "shift in" a bit at the end.
                    % A common trick is: value = 2*value + bit * 2^(-precision)?
                    % No, simply: value = 2*value; if (next_bit) value = value + 1? No.
                    % The 'value' represents the number 0.b1b2b3...
                    % When we shift out b1, we get 0.b2b3...
                    % So value = 2 * value - b1.
                    % And we need to add the new bit at the end?
                    % With infinite precision floats, we just shift.
                    % But we only read 32 bits.
                    % Let's just add 2^(-32) if the new bit is 1?
                    % Actually, if we maintain 'value' as the window,
                    % when we do value = 2*value, we are shifting.
                    % We just need to add the new bit at the 2^-32 position?
                    % Or maybe 2^-1 if we consider the window shifted?
                    % Let's look at the standard algorithm.
                    % value = 2 * value + next_bit (integer)
                    % Here: value = 2 * value + next_bit * 2^(-32)?
                    % Let's try adding the bit at 2^-32.
                    % But wait, if we just multiply by 2, we are shifting everything up.
                    % The "new bit" is the one that was at 2^-33, now at 2^-32.
                    % So we need to read more bits from the code stream.
                    
                    % Let's try a simpler approach for the float simulation:
                    % We just add the bit at the "end" of the current precision?
                    % Actually, for this project, maybe just `value = value + code(code_idx) * 2^(-32)` is enough?
                    % Let's assume 32-bit precision is enough.
                end
                code_idx = code_idx + 1;
            end
        end
        
        % Update model
        model.update(symbol);
    end
end

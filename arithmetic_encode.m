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
    
    % Initialize output code buffer
    % Pre-allocate generous buffer (e.g., 16 bits per symbol) to avoid resizing
    buf_len = length(seq) * 16 + 1000; 
    code_buf = false(1, buf_len);
    code_ptr = 1;
    
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
                [code_buf, code_ptr] = append_bits(code_buf, code_ptr, false, pending_bits, true);
                pending_bits = 0;
                low = 2 * low;
                high = 2 * high;
            elseif low >= 0.5
                % E2: Output 1, then pending 0s
                [code_buf, code_ptr] = append_bits(code_buf, code_ptr, true, pending_bits, false);
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
        [code_buf, code_ptr] = append_bits(code_buf, code_ptr, false, pending_bits, true);
    else
        [code_buf, code_ptr] = append_bits(code_buf, code_ptr, true, pending_bits, false);
    end
    
    % Truncate to actual length
    code = code_buf(1:code_ptr-1);
end

function [buf, ptr] = append_bits(buf, ptr, main_bit, count, follower_bit)
    % Helper to append bits and resize buffer if needed
    needed = 1 + count;
    if ptr + needed - 1 > length(buf)
        % Double buffer size
        buf = [buf, false(1, length(buf))];
    end
    
    buf(ptr) = main_bit;
    ptr = ptr + 1;
    
    if count > 0
        buf(ptr:ptr+count-1) = follower_bit;
        ptr = ptr + count;
    end
end

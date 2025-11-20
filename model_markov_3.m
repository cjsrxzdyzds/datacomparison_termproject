classdef model_markov_3 < handle
    % -------------------------------------------------------------------------
    % Section: Probability Models
    % Purpose: 3rd Order Markov Model for Arithmetic Coding
    %          Maintains adaptive counts of symbol transitions based on 3 previous symbols.
    %          Uses a sparse map to store contexts to avoid memory explosion.
    % Input:   alphabet_size - Number of unique symbols
    % -------------------------------------------------------------------------
    
    properties
        counts_map      % containers.Map: Key(uint32) -> Value(double vector)
        context         % Current context [ctx1, ctx2, ctx3]
        alphabet_size   % Size of the alphabet
        total_counts_map % containers.Map: Key(uint32) -> Value(double scalar)
    end
    
    methods
        function obj = model_markov_3(alphabet_size)
            % Constructor
            obj.alphabet_size = alphabet_size;
            % Initialize maps
            obj.counts_map = containers.Map('KeyType', 'uint32', 'ValueType', 'any');
            obj.total_counts_map = containers.Map('KeyType', 'uint32', 'ValueType', 'double');
            % Default context [1, 1, 1]
            obj.context = [1, 1, 1]; 
        end
        
        function key = get_key(obj, ctx)
            % Generate unique uint32 key from 3-symbol context
            % Assuming symbols are 1-256 (bytes)
            % Key = (c1-1)*65536 + (c2-1)*256 + (c3-1)
            % This fits in uint32 (max 255*65536 + 255*256 + 255 = 16777215)
            
            c1 = uint32(ctx(1) - 1);
            c2 = uint32(ctx(2) - 1);
            c3 = uint32(ctx(3) - 1);
            
            key = c1 * 65536 + c2 * 256 + c3;
        end
        
        function [counts, total] = get_counts(obj, key)
            % Retrieve counts for a key, initializing if not present
            if isKey(obj.counts_map, key)
                counts = obj.counts_map(key);
                total = obj.total_counts_map(key);
            else
                % Initialize with Laplace smoothing (all 1s)
                counts = ones(1, obj.alphabet_size);
                total = obj.alphabet_size;
                
                % Store in map
                obj.counts_map(key) = counts;
                obj.total_counts_map(key) = total;
            end
        end
        
        function [low, high] = get_range(obj, symbol)
            % Get range for symbol under current context
            
            key = obj.get_key(obj.context);
            [ctx_counts, total] = obj.get_counts(key);
            
            cum_counts = [0, cumsum(ctx_counts)];
            
            low = cum_counts(symbol) / total;
            high = cum_counts(symbol + 1) / total;
        end
        
        function [symbol, low, high] = get_symbol(obj, value)
            % Find symbol for value under current context
            
            key = obj.get_key(obj.context);
            [ctx_counts, total] = obj.get_counts(key);
            
            cum_counts = [0, cumsum(ctx_counts)];
            
            scaled_value = value * total;
            
            idx = find(cum_counts <= scaled_value, 1, 'last');
            symbol = idx;
            
            if symbol > obj.alphabet_size
                symbol = obj.alphabet_size;
            end
            
            low = cum_counts(symbol) / total;
            high = cum_counts(symbol + 1) / total;
        end
        
        function update(obj, symbol)
            % Update model
            
            key = obj.get_key(obj.context);
            
            % We know the key exists because get_range/get_symbol was called first
            % But for safety/completeness, we use get_counts logic or direct access if sure
            if isKey(obj.counts_map, key)
                counts = obj.counts_map(key);
                total = obj.total_counts_map(key);
            else
                % Should not happen in normal flow, but initialize if needed
                counts = ones(1, obj.alphabet_size);
                total = obj.alphabet_size;
            end
            
            % Update counts
            counts(symbol) = counts(symbol) + 1;
            total = total + 1;
            
            % Write back to map
            obj.counts_map(key) = counts;
            obj.total_counts_map(key) = total;
            
            % Update context: shift left
            % [c1, c2, c3] -> [c2, c3, symbol]
            obj.context = [obj.context(2), obj.context(3), symbol];
        end
    end
end

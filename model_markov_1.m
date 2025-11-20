classdef model_markov_1 < handle
    % -------------------------------------------------------------------------
    % Section: Probability Models
    % Purpose: 1st Order Markov Model for Arithmetic Coding
    %          Maintains adaptive counts of symbol transitions.
    % Input:   alphabet_size - Number of unique symbols (e.g., 256 for bytes)
    % -------------------------------------------------------------------------
    
    properties
        counts          % Transition counts (alphabet_size x alphabet_size)
        context         % Current context (previous symbol)
        alphabet_size   % Size of the alphabet
        total_counts    % Cached sum of counts for each context (alphabet_size x 1)
    end
    
    methods
        function obj = model_markov_1(alphabet_size)
            % Constructor
            obj.alphabet_size = alphabet_size;
            % Initialize with 1s for Laplace smoothing
            obj.counts = ones(alphabet_size, alphabet_size);
            obj.total_counts = sum(obj.counts, 2);
            % Default context (can be 1 or a specific start symbol)
            obj.context = 1; 
        end
        
        function [low, high] = get_range(obj, symbol)
            % Get the cumulative probability range for a symbol under current context
            % Input: symbol (1-based index)
            % Output: [low, high] range in [0, 1)
            
            % Get counts for the current context
            ctx_counts = obj.counts(obj.context, :);
            total = obj.total_counts(obj.context);
            
            % Calculate cumulative counts
            cum_counts = [0, cumsum(ctx_counts)];
            
            % Calculate range
            low = cum_counts(symbol) / total;
            high = cum_counts(symbol + 1) / total;
        end
        
        function [symbol, low, high] = get_symbol(obj, value)
            % Find symbol that fits the value in the current context
            % Input: value - current arithmetic code value (scaled to [0,1) relative to current range)
            % Output: symbol, and its [low, high] range
            
            ctx_counts = obj.counts(obj.context, :);
            total = obj.total_counts(obj.context);
            cum_counts = [0, cumsum(ctx_counts)];
            
            % Scale value to count domain
            % We are looking for symbol s such that:
            % low <= value < high
            % (cum_counts(s)/total) <= value < (cum_counts(s+1)/total)
            % cum_counts(s) <= value * total < cum_counts(s+1)
            
            scaled_value = value * total;
            
            % Find the symbol index
            % find(cum_counts <= scaled_value, 1, 'last') returns the index in cum_counts
            % cum_counts has size alphabet_size + 1.
            % Indices: 1..alphabet_size+1
            % If scaled_value is in [0, count(1)), it's symbol 1.
            % cum_counts = [0, c1, c1+c2, ...]
            % if val < c1, index is 1.
            
            idx = find(cum_counts <= scaled_value, 1, 'last');
            symbol = idx; 
            
            % Handle edge case where value might be slightly off due to precision
            if symbol > obj.alphabet_size
                symbol = obj.alphabet_size;
            end
            
            low = cum_counts(symbol) / total;
            high = cum_counts(symbol + 1) / total;
        end
        
        function update(obj, symbol)
            % Update model with the seen symbol
            
            % Increment count for (context -> symbol)
            obj.counts(obj.context, symbol) = obj.counts(obj.context, symbol) + 1;
            obj.total_counts(obj.context) = obj.total_counts(obj.context) + 1;
            
            % Update context
            obj.context = symbol;
        end
    end
end

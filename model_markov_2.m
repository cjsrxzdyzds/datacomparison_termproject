classdef model_markov_2 < handle
    % -------------------------------------------------------------------------
    % Section: Probability Models
    % Purpose: 2nd Order Markov Model for Arithmetic Coding
    %          Maintains adaptive counts of symbol transitions based on 2 previous symbols.
    % Input:   alphabet_size - Number of unique symbols
    % -------------------------------------------------------------------------
    
    properties
        counts          % Transition counts (alphabet_size x alphabet_size x alphabet_size)
                        % counts(ctx1, ctx2, sym)
        context         % Current context [ctx1, ctx2]
        alphabet_size   % Size of the alphabet
        total_counts    % Cached sum of counts (alphabet_size x alphabet_size)
    end
    
    methods
        function obj = model_markov_2(alphabet_size)
            % Constructor
            obj.alphabet_size = alphabet_size;
            % Initialize with 1s for Laplace smoothing
            % Dimensions: [prev_prev, prev, current]
            obj.counts = ones(alphabet_size, alphabet_size, alphabet_size);
            obj.total_counts = sum(obj.counts, 3);
            % Default context [1, 1]
            obj.context = [1, 1]; 
        end
        
        function [low, high] = get_range(obj, symbol)
            % Get range for symbol under current context
            
            ctx1 = obj.context(1);
            ctx2 = obj.context(2);
            
            ctx_counts = obj.counts(ctx1, ctx2, :);
            % Squeeze to 1D vector
            ctx_counts = reshape(ctx_counts, 1, []);
            
            total = obj.total_counts(ctx1, ctx2);
            
            cum_counts = [0, cumsum(ctx_counts)];
            
            low = cum_counts(symbol) / total;
            high = cum_counts(symbol + 1) / total;
        end
        
        function [symbol, low, high] = get_symbol(obj, value)
            % Find symbol for value under current context
            
            ctx1 = obj.context(1);
            ctx2 = obj.context(2);
            
            ctx_counts = obj.counts(ctx1, ctx2, :);
            ctx_counts = reshape(ctx_counts, 1, []);
            
            total = obj.total_counts(ctx1, ctx2);
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
            
            ctx1 = obj.context(1);
            ctx2 = obj.context(2);
            
            obj.counts(ctx1, ctx2, symbol) = obj.counts(ctx1, ctx2, symbol) + 1;
            obj.total_counts(ctx1, ctx2) = obj.total_counts(ctx1, ctx2) + 1;
            
            % Update context: shift left
            % [c1, c2] -> [c2, symbol]
            obj.context = [ctx2, symbol];
        end
    end
end

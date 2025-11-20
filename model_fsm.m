classdef model_fsm < handle
    % -------------------------------------------------------------------------
    % Section: Probability Models
    % Purpose: Finite State Machine (FSM) Model for Arithmetic Coding
    %          Extends Order-1 Markov by adding a "Run State" to the context.
    %          Context = [Previous Symbol, IsRun]
    %          IsRun = 1 if Previous == PrevPrev, else 0 (mapped to indices 2 and 1)
    % Input:   alphabet_size - Number of unique symbols
    % -------------------------------------------------------------------------
    
    properties
        counts          % Transition counts (alphabet_size x 2 x alphabet_size)
                        % counts(prev_sym, is_run_idx, current_sym)
        context         % Current context [prev_sym, prev_prev_sym]
        alphabet_size   % Size of the alphabet
        total_counts    % Cached sum of counts (alphabet_size x 2)
    end
    
    methods
        function obj = model_fsm(alphabet_size)
            % Constructor
            obj.alphabet_size = alphabet_size;
            % Initialize with 1s for Laplace smoothing
            % Dimensions: [prev_sym, is_run_idx, current_sym]
            % is_run_idx: 1 = No Run, 2 = Run
            obj.counts = ones(alphabet_size, 2, alphabet_size);
            obj.total_counts = sum(obj.counts, 3);
            % Default context [1, 1] (assuming 1 is a valid symbol)
            obj.context = [1, 1]; 
        end
        
        function [low, high] = get_range(obj, symbol)
            % Get range for symbol under current context
            
            prev = obj.context(1);
            prev_prev = obj.context(2);
            
            % Determine Run State
            if prev == prev_prev
                is_run_idx = 2;
            else
                is_run_idx = 1;
            end
            
            ctx_counts = obj.counts(prev, is_run_idx, :);
            % Squeeze to 1D vector
            ctx_counts = reshape(ctx_counts, 1, []);
            
            total = obj.total_counts(prev, is_run_idx);
            
            cum_counts = [0, cumsum(ctx_counts)];
            
            low = cum_counts(symbol) / total;
            high = cum_counts(symbol + 1) / total;
        end
        
        function [symbol, low, high] = get_symbol(obj, value)
            % Find symbol for value under current context
            
            prev = obj.context(1);
            prev_prev = obj.context(2);
            
            if prev == prev_prev
                is_run_idx = 2;
            else
                is_run_idx = 1;
            end
            
            ctx_counts = obj.counts(prev, is_run_idx, :);
            ctx_counts = reshape(ctx_counts, 1, []);
            
            total = obj.total_counts(prev, is_run_idx);
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
            
            prev = obj.context(1);
            prev_prev = obj.context(2);
            
            if prev == prev_prev
                is_run_idx = 2;
            else
                is_run_idx = 1;
            end
            
            obj.counts(prev, is_run_idx, symbol) = obj.counts(prev, is_run_idx, symbol) + 1;
            obj.total_counts(prev, is_run_idx) = obj.total_counts(prev, is_run_idx) + 1;
            
            % Update context: shift left
            % [prev, prev_prev] -> [symbol, prev]
            obj.context = [symbol, prev];
        end
    end
end

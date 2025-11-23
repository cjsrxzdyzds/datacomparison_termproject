classdef model_mixing < handle
    % -------------------------------------------------------------------------
    % Section: Probability Models
    % Purpose: Context Mixing Model for Arithmetic Coding
    %          Combines predictions from multiple sub-models using weighted averaging.
    % Input:   models - Cell array of model objects (e.g., {model_markov_1, model_markov_2})
    %          alphabet_size - Number of unique symbols
    % -------------------------------------------------------------------------
    
    properties
        models          % Cell array of sub-models
        weights         % Weights for each model (1 x num_models)
        alphabet_size   % Size of the alphabet
        learning_rate   % Rate at which weights adapt (0 to 1)
    end
    
    methods
        function obj = model_mixing(models, alphabet_size)
            % Constructor
            obj.models = models;
            obj.alphabet_size = alphabet_size;
            
            % Initialize weights equally
            num_models = length(models);
            obj.weights = ones(1, num_models) / num_models;
            
            % Default learning rate for weight adaptation
            obj.learning_rate = 0.05; 
        end
        
        function [low, high] = get_range(obj, symbol)
            % Get the cumulative probability range for a symbol by mixing models
            
            % 1. Get probability distribution from each model
            % We need the probability of *every* symbol to construct the mixed CDF
            % This is computationally expensive but necessary for true mixing.
            % Optimization: We can just get the prob of the target symbol if we only needed P(s),
            % but for arithmetic coding we need the cumulative range [L, H).
            % So we must reconstruct the mixed CDF.
            
            mixed_probs = zeros(1, obj.alphabet_size);
            
            for i = 1:length(obj.models)
                % Extract probabilities from model i
                % Most models store counts. We need to compute probs.
                % This assumes models have a method to get all probs or we derive it.
                % Since the interface only has get_range(symbol), we might have to call it for all symbols
                % OR add a get_probs() method to the base interface.
                % For now, let's iterate (slow but correct for the interface).
                
                % Optimization: Access internal counts if possible, but that breaks encapsulation.
                % Let's try to be generic.
                
                model_probs = zeros(1, obj.alphabet_size);
                for s = 1:obj.alphabet_size
                    [l, h] = obj.models{i}.get_range(s);
                    model_probs(s) = h - l;
                end
                
                mixed_probs = mixed_probs + (model_probs * obj.weights(i));
            end
            
            % Normalize (just in case)
            mixed_probs = mixed_probs / sum(mixed_probs);
            
            % Calculate cumulative range for the requested symbol
            cum_probs = [0, cumsum(mixed_probs)];
            
            low = cum_probs(symbol);
            high = cum_probs(symbol + 1);
        end
        
        function [symbol, low, high] = get_symbol(obj, value)
            % Find symbol for a given cumulative value
            
            % Reconstruct mixed CDF (same as get_range)
            mixed_probs = zeros(1, obj.alphabet_size);
            for i = 1:length(obj.models)
                model_probs = zeros(1, obj.alphabet_size);
                for s = 1:obj.alphabet_size
                    [l, h] = obj.models{i}.get_range(s);
                    model_probs(s) = h - l;
                end
                mixed_probs = mixed_probs + (model_probs * obj.weights(i));
            end
            mixed_probs = mixed_probs / sum(mixed_probs);
            cum_probs = [0, cumsum(mixed_probs)];
            
            % Find symbol
            % cum_probs(s) <= value < cum_probs(s+1)
            idx = find(cum_probs <= value, 1, 'last');
            symbol = idx;
            
            if symbol > obj.alphabet_size
                symbol = obj.alphabet_size;
            end
            
            low = cum_probs(symbol);
            high = cum_probs(symbol + 1);
        end
        
        function update(obj, symbol)
            % Update weights based on performance, then update sub-models
            
            % 1. Calculate probability assigned to this symbol by each model
            model_probs = zeros(1, length(obj.models));
            for i = 1:length(obj.models)
                [l, h] = obj.models{i}.get_range(symbol);
                model_probs(i) = h - l;
            end
            
            % 2. Update weights
            % Increase weight for models that predicted this symbol with higher probability
            % Simple strategy: w_new = w_old + learning_rate * prob(symbol)
            % Then re-normalize.
            
            obj.weights = obj.weights + (obj.learning_rate * model_probs);
            obj.weights = obj.weights / sum(obj.weights);
            
            % 3. Update all sub-models
            for i = 1:length(obj.models)
                obj.models{i}.update(symbol);
            end
        end
    end
end

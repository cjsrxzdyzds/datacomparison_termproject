classdef model_lstm < handle
    % -------------------------------------------------------------------------
    % Section: Probability Models
    % Purpose: Simple Recurrent Neural Network (RNN) for Arithmetic Coding
    %          Predicts next symbol probability using a hidden state and online SGD.
    %          Implemented from scratch to avoid Deep Learning Toolbox overhead.
    % Input:   alphabet_size - Number of unique symbols
    % -------------------------------------------------------------------------
    
    properties
        alphabet_size   % Size of the alphabet
        hidden_size     % Size of hidden layer
        
        % Weights and Biases
        W_xh            % Input to Hidden (hidden_size x alphabet_size)
        W_hh            % Hidden to Hidden (hidden_size x hidden_size)
        W_hy            % Hidden to Output (alphabet_size x hidden_size)
        b_h             % Hidden bias (hidden_size x 1)
        b_y             % Output bias (alphabet_size x 1)
        
        % State
        h               % Current hidden state (hidden_size x 1)
        prev_symbol     % Previous symbol index
        
        % Hyperparameters
        learning_rate
    end
    
    methods
        function obj = model_lstm(alphabet_size)
            % Constructor
            obj.alphabet_size = alphabet_size;
            obj.hidden_size = 16; % Small hidden size for speed
            obj.learning_rate = 0.1;
            
            % Initialize weights (Deterministic initialization using sin)
            % We use sin(k) to generate pseudo-random numbers that are identical
            % across encoder and decoder instances without changing global RNG.
            
            % Helper to generate deterministic weights
            function w = det_weights(rows, cols, offset)
                num = rows * cols;
                w = reshape(sin((1:num) + offset), rows, cols) * 0.1;
            end
            
            obj.W_xh = det_weights(obj.hidden_size, alphabet_size, 0);
            obj.W_hh = det_weights(obj.hidden_size, obj.hidden_size, 1000);
            obj.W_hy = det_weights(alphabet_size, obj.hidden_size, 2000);
            
            obj.b_h = zeros(obj.hidden_size, 1);
            obj.b_y = zeros(alphabet_size, 1);
            
            % Initialize state
            obj.h = zeros(obj.hidden_size, 1);
            obj.prev_symbol = 1; % Default start symbol
        end
        
        function p = predict(obj)
            % Forward pass to get probability distribution
            
            % Input is one-hot of prev_symbol
            x = zeros(obj.alphabet_size, 1);
            x(obj.prev_symbol) = 1;
            
            % Hidden layer
            % h_new = tanh(W_xh * x + W_hh * h_prev + b_h)
            % Note: W_xh * x is just the column of W_xh corresponding to prev_symbol
            h_in = obj.W_xh(:, obj.prev_symbol) + obj.W_hh * obj.h + obj.b_h;
            h_new = tanh(h_in);
            
            % Output layer
            % y = softmax(W_hy * h_new + b_y)
            logits = obj.W_hy * h_new + obj.b_y;
            
            % Softmax with stability shift
            logits = logits - max(logits);
            exp_logits = exp(logits);
            p = exp_logits / sum(exp_logits);
            
            % Store h_new for update step (but don't overwrite obj.h yet if we need it for backprop)
            % Actually, for this simple implementation, we can just re-compute in update or store it.
            % Let's re-compute in update to keep get_range pure-ish (though it depends on state).
            % Wait, get_range calls predict. predict shouldn't change state.
        end
        
        function [low, high] = get_range(obj, symbol)
            % Get range for symbol
            p = obj.predict();
            
            cum_p = [0; cumsum(p)];
            
            % Ensure last is exactly 1.0 to avoid precision issues
            cum_p(end) = 1.0;
            
            low = cum_p(symbol);
            high = cum_p(symbol + 1);
        end
        
        function [symbol, low, high] = get_symbol(obj, value)
            % Find symbol for value
            p = obj.predict();
            cum_p = [0; cumsum(p)];
            cum_p(end) = 1.0;
            
            idx = find(cum_p <= value, 1, 'last');
            symbol = idx;
            
            if symbol > obj.alphabet_size
                symbol = obj.alphabet_size;
            end
            
            low = cum_p(symbol);
            high = cum_p(symbol + 1);
        end
        
        function update(obj, target_symbol)
            % Update model weights using SGD (Backpropagation Through Time - 1 step)
            
            % Re-compute forward pass to get intermediate values
            x = zeros(obj.alphabet_size, 1);
            x(obj.prev_symbol) = 1;
            
            h_in = obj.W_xh(:, obj.prev_symbol) + obj.W_hh * obj.h + obj.b_h;
            h_new = tanh(h_in);
            
            logits = obj.W_hy * h_new + obj.b_y;
            logits = logits - max(logits);
            exp_logits = exp(logits);
            p = exp_logits / sum(exp_logits);
            
            % Gradient of Cross-Entropy Loss: dL/dy = p - target
            dy = p;
            dy(target_symbol) = dy(target_symbol) - 1;
            
            % Backprop to Output Weights
            % dL/dW_hy = dy * h_new'
            dW_hy = dy * h_new';
            db_y = dy;
            
            % Backprop to Hidden State
            % dL/dh = W_hy' * dy
            dh = obj.W_hy' * dy;
            
            % Backprop through tanh
            % dtanh = 1 - h_new^2
            dh_in = dh .* (1 - h_new.^2);
            
            % Backprop to Hidden Weights
            % dL/dW_hh = dh_in * h_prev'
            dW_hh = dh_in * obj.h';
            db_h = dh_in;
            
            % Backprop to Input Weights
            % dL/dW_xh = dh_in * x'
            % Since x is one-hot, this updates only the column for prev_symbol
            dW_xh_col = dh_in; 
            
            % Update Weights
            obj.W_hy = obj.W_hy - obj.learning_rate * dW_hy;
            obj.b_y = obj.b_y - obj.learning_rate * db_y;
            obj.W_hh = obj.W_hh - obj.learning_rate * dW_hh;
            obj.b_h = obj.b_h - obj.learning_rate * db_h;
            obj.W_xh(:, obj.prev_symbol) = obj.W_xh(:, obj.prev_symbol) - obj.learning_rate * dW_xh_col;
            
            % Update State
            obj.h = h_new;
            obj.prev_symbol = target_symbol;
        end
    end
end

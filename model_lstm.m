classdef model_lstm < handle
    % -------------------------------------------------------------------------
    % Section: Probability Models
    % Purpose: True LSTM (Long Short-Term Memory) for Arithmetic Coding
    %          Predicts next symbol probability using LSTM cells with gates.
    %          Implemented from scratch to avoid Deep Learning Toolbox overhead.
    % Input:   alphabet_size - Number of unique symbols
    % -------------------------------------------------------------------------
    
    properties
        alphabet_size   % Size of the alphabet
        hidden_size     % Size of hidden layer
        
        % LSTM Weights and Biases
        % F: Forget Gate, I: Input Gate, C: Cell Candidate, O: Output Gate
        
        % Forget Gate
        W_f, U_f, b_f
        
        % Input Gate
        W_i, U_i, b_i
        
        % Cell Candidate
        W_c, U_c, b_c
        
        % Output Gate
        W_o, U_o, b_o
        
        % Output Layer (Hidden to Softmax)
        W_hy, b_y
        
        % State
        h               % Current hidden state (hidden_size x 1)
        c               % Current cell state (hidden_size x 1)
        prev_symbol     % Previous symbol index
        
        % Hyperparameters
        learning_rate
    end
    
    methods
        function obj = model_lstm(alphabet_size)
            % Constructor
            obj.alphabet_size = alphabet_size;
            obj.hidden_size = 16; % Keep small for speed, but LSTM has more capacity
            obj.learning_rate = 0.05; % Slightly lower LR for LSTM stability
            
            % Initialize weights (Deterministic initialization)
            % Helper to generate deterministic weights
            function w = det_weights(rows, cols, offset)
                num = rows * cols;
                w = reshape(sin((1:num) + offset), rows, cols) * 0.1;
            end
            
            h_sz = obj.hidden_size;
            in_sz = alphabet_size;
            
            % Forget Gate
            obj.W_f = det_weights(h_sz, in_sz, 0);
            obj.U_f = det_weights(h_sz, h_sz, 1000);
            obj.b_f = ones(h_sz, 1); % Initialize forget bias to 1 to remember by default
            
            % Input Gate
            obj.W_i = det_weights(h_sz, in_sz, 2000);
            obj.U_i = det_weights(h_sz, h_sz, 3000);
            obj.b_i = zeros(h_sz, 1);
            
            % Cell Candidate
            obj.W_c = det_weights(h_sz, in_sz, 4000);
            obj.U_c = det_weights(h_sz, h_sz, 5000);
            obj.b_c = zeros(h_sz, 1);
            
            % Output Gate
            obj.W_o = det_weights(h_sz, in_sz, 6000);
            obj.U_o = det_weights(h_sz, h_sz, 7000);
            obj.b_o = zeros(h_sz, 1);
            
            % Output Layer
            obj.W_hy = det_weights(in_sz, h_sz, 8000);
            obj.b_y = zeros(in_sz, 1);
            
            % Initialize state
            obj.h = zeros(h_sz, 1);
            obj.c = zeros(h_sz, 1);
            obj.prev_symbol = 1; % Default start symbol
        end
        
        function [p, h_new, c_new, f, i, c_tilde, o] = forward(obj)
            % Helper for forward pass, returns all intermediates for backprop
            
            % Input vector (one-hot)
            % We optimize by selecting columns directly instead of matrix mult
            x_idx = obj.prev_symbol;
            
            % Forget Gate: f = sigmoid(W_f*x + U_f*h + b_f)
            f_in = obj.W_f(:, x_idx) + obj.U_f * obj.h + obj.b_f;
            f = 1 ./ (1 + exp(-f_in));
            
            % Input Gate: i = sigmoid(W_i*x + U_i*h + b_i)
            i_in = obj.W_i(:, x_idx) + obj.U_i * obj.h + obj.b_i;
            i = 1 ./ (1 + exp(-i_in));
            
            % Cell Candidate: c_tilde = tanh(W_c*x + U_c*h + b_c)
            c_in = obj.W_c(:, x_idx) + obj.U_c * obj.h + obj.b_c;
            c_tilde = tanh(c_in);
            
            % Cell State: c = f * c_prev + i * c_tilde
            c_new = f .* obj.c + i .* c_tilde;
            
            % Output Gate: o = sigmoid(W_o*x + U_o*h + b_o)
            o_in = obj.W_o(:, x_idx) + obj.U_o * obj.h + obj.b_o;
            o = 1 ./ (1 + exp(-o_in));
            
            % Hidden State: h = o * tanh(c)
            h_new = o .* tanh(c_new);
            
            % Output Probabilities
            logits = obj.W_hy * h_new + obj.b_y;
            logits = logits - max(logits); % Stability
            exp_logits = exp(logits);
            p = exp_logits / sum(exp_logits);
        end
        
        function p = predict(obj)
            [p, ~, ~, ~, ~, ~, ~] = obj.forward();
        end
        
        function [low, high] = get_range(obj, symbol)
            p = obj.predict();
            cum_p = [0; cumsum(p)];
            cum_p(end) = 1.0;
            low = cum_p(symbol);
            high = cum_p(symbol + 1);
        end
        
        function [symbol, low, high] = get_symbol(obj, value)
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
            % Update weights using 1-step BPTT
            
            % Re-run forward pass to get intermediates
            [p, h_new, c_new, f, i, c_tilde, o] = obj.forward();
            
            % Gradient of Loss w.r.t Output (Cross-Entropy)
            dy = p;
            dy(target_symbol) = dy(target_symbol) - 1;
            
            % Backprop to Output Layer Weights
            dW_hy = dy * h_new';
            db_y = dy;
            
            % Backprop to Hidden State
            dh = obj.W_hy' * dy;
            
            % Backprop through LSTM Output Gate
            % h = o * tanh(c)
            tanh_c = tanh(c_new);
            do = dh .* tanh_c;
            dc = dh .* o .* (1 - tanh_c.^2);
            
            % Backprop through Output Gate Activation (sigmoid)
            do_in = do .* o .* (1 - o);
            
            % Backprop to Cell State components
            % c = f * c_prev + i * c_tilde
            % Gradients for f, i, c_tilde
            df = dc .* obj.c;
            di = dc .* c_tilde;
            dc_tilde = dc .* i;
            
            % Backprop through Activations
            df_in = df .* f .* (1 - f);           % sigmoid
            di_in = di .* i .* (1 - i);           % sigmoid
            dc_tilde_in = dc_tilde .* (1 - c_tilde.^2); % tanh
            
            % Gradients for Weights
            % Input x is one-hot, so outer product with x selects the column
            x_idx = obj.prev_symbol;
            h_prev = obj.h;
            
            % Output Gate Gradients
            dW_o_col = do_in;
            dU_o = do_in * h_prev';
            db_o = do_in;
            
            % Forget Gate Gradients
            dW_f_col = df_in;
            dU_f = df_in * h_prev';
            db_f = df_in;
            
            % Input Gate Gradients
            dW_i_col = di_in;
            dU_i = di_in * h_prev';
            db_i = di_in;
            
            % Cell Candidate Gradients
            dW_c_col = dc_tilde_in;
            dU_c = dc_tilde_in * h_prev';
            db_c = dc_tilde_in;
            
            % Apply Updates (SGD)
            lr = obj.learning_rate;
            
            obj.W_hy = obj.W_hy - lr * dW_hy;
            obj.b_y = obj.b_y - lr * db_y;
            
            obj.W_o(:, x_idx) = obj.W_o(:, x_idx) - lr * dW_o_col;
            obj.U_o = obj.U_o - lr * dU_o;
            obj.b_o = obj.b_o - lr * db_o;
            
            obj.W_f(:, x_idx) = obj.W_f(:, x_idx) - lr * dW_f_col;
            obj.U_f = obj.U_f - lr * dU_f;
            obj.b_f = obj.b_f - lr * db_f;
            
            obj.W_i(:, x_idx) = obj.W_i(:, x_idx) - lr * dW_i_col;
            obj.U_i = obj.U_i - lr * dU_i;
            obj.b_i = obj.b_i - lr * db_i;
            
            obj.W_c(:, x_idx) = obj.W_c(:, x_idx) - lr * dW_c_col;
            obj.U_c = obj.U_c - lr * dU_c;
            obj.b_c = obj.b_c - lr * db_c;
            
            % Update State
            obj.h = h_new;
            obj.c = c_new;
            obj.prev_symbol = target_symbol;
        end
    end
end

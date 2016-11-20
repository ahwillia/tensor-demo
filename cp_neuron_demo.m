close all; clear; clc

%% Make some fake neural data

% dimensions & params
% -------------------
N = 50;      % neurons
T = 60;      % time points
K = 40;      % trials

% Rank of the data. (The number of factors
% needed to describe the data)
R = 4;

% neuron factors
A = randn(N,R);

% time (within-trial) factors
B = randn(T,R);

% smooth within-trial factors (neural firing rates
% or fluorescence shouldn't change instantaneously)
gauss_sigma = round(T/8);
t_ax = (-4*gauss_sigma):(4*gauss_sigma);
gaussFilter = exp(-t_ax.^2 / (2*gauss_sigma^2));
gaussFilter = gaussFilter / sum(gaussFilter); % normalize
for r = 1:R
    B(:,r) = conv(B(:,r), gaussFilter, 'same');
end

% preallocated across-trial factors
C = zeros(K,R);

% add more structure to data
% --------------------------
n1 = floor(N/2);     % split between cell type 1 and cell type 2
k1 = floor(K/3);     % split between trial type 1 -> trial type 2
k2 = floor(2*K/3);   % split between trial type 2 -> trial type 1
r1 = floor(R/2);     % split the latent factors

% add cell types
A(1:n1,1:r1) = 0.1*A(1:n1,1:r1);
A((n1+1):end,(r1+1):end) = 0.1*A((n1+1):end,(r1+1):end);

% add trial-to-trial structure
%   - first one-third of trials are trial type 1
%   - the middle third of trials are trial type 2
%   - the final third of trials are trial type 1
for r = 1:r1
    C(1:k1,r) = 1.0;
    C(k2:end,r) = 1.0;
end
for r = (r1+1):R
    C(k1:k2,r) = 1.0;
end

% generate the full dataset
% -------------------------
data = zeros(N,T,K);
for n = 1:N
    for t = 1:T
        for k = 1:K
            tmp = 0.0;
            for r = 1:R
                tmp = tmp + A(n,r)*B(t,r)*C(k,r);
            end
            data(n,t,k) = tmp;
        end
    end
end

% add some noise
noise_lev = 0.2;
data = data + randn(N,T,K)*noise_lev;

%% Fit CP Tensor Decomposition

% these commands require that you download Sandia Labs' tensor toolbox:
% http://www.sandia.gov/~tgkolda/TensorToolbox/index-2.6.html

% convert data to a tensor object
data = tensor(data);

% fit the model
est_factors = cp_als(tensor(data),R);

% the true
true_factors = ktensor(ones(R,1), A, B, C);

% visualize the result
visualize_neuron_ktensor(est_factors)
title('estimated factors')

% compare to grouth truth
visualize_neuron_ktensor(true_factors)
title('true factors')

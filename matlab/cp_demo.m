close all; clear; clc

%% Make some fake neural data

% dimensions & params
% -------------------
N = 50;      % neurons
T = 60;      % time points
K = 40;      % trials

% rank of the data. (the number of latent factors.)
R = 4;
r1 = floor(R/2); % split the latent factors to add interesting structure

% factor magnitude
lam = ones(R,1);%logspace(0.5,-0.5,R)';
lam = lam(randperm(R));

% neuron factors
% ---------------
A = randn(N,R);

% add cell types
%   - first half of the cells are strongly weighted on first half of
%   components
%   - second half of the cells are strongly weighted to the other half
n1 = floor(N/2);
A(1:n1,1:r1) = 0.1*A(1:n1,1:r1);
A((n1+1):end,(r1+1):end) = 0.1*A((n1+1):end,(r1+1):end);

% threshold small values of A
A(abs(A) < 0.1) = 0.0;

% time (within-trial) factors
% ---------------------------
B = zeros(T,R);
t_ax = linspace(-3, 3, T);
m = linspace(-3, 3, R);

% Each neuron factor is a gaussian bump
for r = 1:R
    B(:,r) = exp(-(t_ax-m(r)).^2 / 2);
    B(:,r) = B(:,r)/norm(B(:,r));
end

% across-trial factors
% --------------------
C = 0.4*randn(K,R);

% split trials into thirds
k1 = floor(K/3);
k2 = floor(2*K/3);

% one factor is large for middle third of trials
C(k1:k2, 1) = C(k1:k2, 1) + 1;

% one factor is large for final third of trials
C(k2:end, 2) = C(k2:end, 2) + 1;

% one factor grows linearly
C(:, 3) = C(:, 3) + (1:K)'/K;

% one is noisy across all trials
C(:, 4) = C(:, 4)*10;

% normalize factors to unit length
for r = 1:R
    C(:,r) = C(:,r)/norm(C(:,r));
end

% generate the full dataset
% -------------------------
data = zeros(N,T,K);
for n = 1:N
    for t = 1:T
        for k = 1:K
            tmp = 0.0;
            for r = 1:R
                tmp = tmp + lam(r)*A(n,r)*B(t,r)*C(k,r);
            end
            data(n,t,k) = tmp;
        end
    end
end

% add some noise
noise_lev = 0.001;
data = data + randn(N,T,K)*noise_lev;

% % NOTE - you can view the full dataset by uncommenting
% % the following code
% movie_fig = figure();
% for k = 1:K
%     image(data(:,:,k),'CDataMapping','scaled')
%     ylabel('neurons')
%     xlabel('time')
%     title(['trial ' num2str(k)])
%     pause(0.3)
% end
% close(movie_fig);

%% Fit CP Tensor Decomposition

% these commands require that you download Sandia Labs' tensor toolbox:
% http://www.sandia.gov/~tgkolda/TensorToolbox/index-2.6.html

% convert data to a tensor object
data = tensor(data);

% plot the ground truth
true_factors = ktensor(lam, A, B, C);
true_err = norm(full(true_factors) - data)/norm(true_factors);
viz_ktensor(true_factors, ... 
            'Plottype', {'bar', 'line', 'scatter'}, ...
            'Modetitles', {'neurons', 'time', 'trials'})
set(gcf, 'Name', 'true factors')

% fit the cp decomposition from random initial guesses
n_fits = 30;
err = zeros(n_fits,1);
for n = 1:n_fits
    % fit model
    est_factors = cp_als(tensor(data),R);
    
    % store error
    err(n) = norm(full(est_factors) - data)/norm(data);
    
    % visualize fit for first several fits
    if n < 4
        % score aligns the cp decompositions
        [sc, est_factors] = score(est_factors, true_factors);
        
        % plot the estimated factors
        viz_ktensor(est_factors, ... 
            'Plottype', {'bar', 'line', 'scatter'}, ...
            'Modetitles', {'neurons', 'time', 'trials'})
        set(gcf, 'Name', ['estimated factors - fit #' num2str(n)])
    end
end

figure(); hold on
plot(randn(n_fits,1), err, 'ob')
plot(0, true_err, 'or', 'markerfacecolor', 'r');
xlim([-10,10])
ylim([0 1.0])
set(gca,'xtick',[])
ylabel('model error')
legend('fits','true model')


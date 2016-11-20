function visualize_neuron_ktensor(decomp, meta, trialcolor)
% VISUALIZE_NEURON_KTENSOR, wraps VISUALIZE_KTENSOR for multi-day data
%
%     [Ax, BigAx, FigHandle] = VISUALIZE_NEURON_KTENSOR(X)
%
%     Parameters
%     ----------
%     trialcolor : 'start', 'error'

% color for the trials
c = cell(1,3);
if nargin >=3
    c{3} = categorical_colors(meta.(trialcolor));
end

% the neuron order is arbitrary, so permute/sort it along the first factor
prm = [true false false];

% bar plot for neuron factors
% line plot for within trial factors
% line and scatter plot for across trial factors
plt = {'bar', 'line', 'scatter'};

% plot titles
nm = {'neuron factors', 'time factors', 'trial factors'};

% formatting
lspc = {[], '-r', '-k'};
lw = [0 2 1];

visualize_ktensor(decomp, 'c', c, 'plots', plt, ...
                  'permute', prm, 'linewidth', lw, ...
                  'names', nm, 'linespec', lspc);



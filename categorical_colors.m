function colors = categorical_colors(labels)
% trial coloring labels

% convert labels to categorical array
if ~iscategorical(labels)
    labels = categorical(labels);
end
cats = categories(labels);
nc = length(cats);

% generate colormap
gr = 0.68;%618033988749895;
h = 0;
cm = zeros(nc,3);
for c = 1:length(cats)
    cm(c,:) = hsv2rgb(h,1,1);
    h = mod(h+gr,1);
end

% assign colors to datapoints
K = length(labels);
colors = zeros(K,3);
for k = 1:K
    colors(k,:) = cm(cats == labels(k),:);
end
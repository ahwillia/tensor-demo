function info = viz_ktensor(K, varargin)
%VIZ_KTENSOR Visualize a ktensor
%
% Xticks = cell array (one per mode)
% Xticklabels = cell array (one per mode)
% Xlims = cell array (one per mode)
% Ylims = cell array (one per mode)
% Hrelspace = Relative Horizontal Space Between Plots (.1)
% HspaceLeft = Absolute Space on Left of Each Plot (0)
% HspaceRight = Absolute Space on right of Each Plot (0)
% Vrelspace = Relative Hoizontal Space Between Plots (.1)
% VspaceTop = Absolute Space for Title (.1)
% VspaceBottom = Absolute Space for XTick Marks (.1)

%%
nd = ndims(K); % Order
nc = ncomponents(K); % Rank

% parse optional inputs


params = inputParser;
% Figure 
params.addParameter('Figure', []);
% Spacing
params.addParameter('Relmodespace', ones(nd,1)); % Horizontal space for each mode
params.addParameter('Hspace',0.01); % Horizontal space between axes
params.addParameter('Hspaceright',0.025); % Horizontal space on left
params.addParameter('Hspaceleft',0.05); % Horizontal space on right
params.addParameter('Vspace',0.01); % Vertical space between axes
params.addParameter('Vspacetop',0.05); % Vertical space at top
params.addParameter('Vspacebottom',0.05); % Vertical space at bottom
% Titles
params.addParameter('Modetitles', []);
params.addParameter('Factortitle', 'none'); % Default is 'none'. Options are 'weight' or 'number'
% Plots
params.addParameter('Plottype', repmat({'line'}, [nd 1]));
params.addParameter('Plotsize', -1 * ones(nd,1)); % Used for scatter dot size or plot linewidth
params.addParameter('Plotcolors', cell(nd,1));
params.addParameter('Sameylims', true(nc,1));


params.parse(varargin{:});
res = params.Results;

%% Create figure
if isempty(res.Figure)
    figure;
else
    figure(res.Figure);
    clf;
end

%% Create axes
Vplotspace = 1 - res.Vspacetop - res.Vspacebottom - (nc - 1) * res.Vspace;
height = Vplotspace / nc;

Hplotspace = 1 - res.Hspaceleft - res.Hspaceright - (nd - 1) * res.Hspace;
width = (res.Relmodespace ./ sum(res.Relmodespace)) .* Hplotspace;

% Global axis
GlobalAxis = axes('Position',[0 0 1 1]); % Global Axes
axis off;

% Factor axes
FactorAxes = gobjects(nd,nc); % Factor Axes
for k = 1 : nd
    for j = 1 : nc
        xpos = res.Hspaceleft + (k-1) * res.Hspace + sum(width(1:k-1));
        ypos = 1 - res.Vspacetop - height - (j-1) * (height + res.Vspace);
        FactorAxes(k,j) = axes('Position',[xpos ypos width(k) height]);
        set(FactorAxes(k,j),'FontSize',14);
    end
end


%% Plot each factor
h = gobjects(nd,nc);
for k = 1 : nd
    
    if res.Plotsize(k) == -1
        lw = 1;
        ss = 10;
    else
        lw = res.Plotsize(k);
        ss = res.Plotsize(k);
    end

    if isempty(res.Plotcolors{k})
        cc = [0 0 1];
    else
        cc = res.Plotcolors{k};
    end
    
    U = K.u{k};
    xl = [0 size(K,k)+1];
    yl = [min( 0, min(U(:)) ), max( 0, max(U(:)) )];

    for j = 1 : nc
        
        xx = 1:size(K,k);
        yy = U(:,j);
        hold(FactorAxes(k,j), 'off');

        switch res.Plottype{k}
            case 'line'
                hh = plot(FactorAxes(k,j), xx, yy, 'Linewidth', lw, 'Color', cc);
            case 'scatter'
                hh = scatter(FactorAxes(k,j), xx, yy, ss, cc, 'filled');
            case 'bar'
                hh = bar(FactorAxes(k,j), xx, yy, 'EdgeColor', cc, 'FaceColor', cc);
        end
        
        xlim(FactorAxes(k,j),xl);
        if res.Sameylims(k)
            ylim(FactorAxes(k,j),yl);
        else
            tmpyl = [ min(-0.01, min(U(:,j))), max( 0.01, max(U(:,j))) ];
            ylim(FactorAxes(k,j),tmpyl);
        end
        set(FactorAxes(k,j),'Ytick',[]);
        if j < nc
            set(FactorAxes(k,j),'XtickLabel',{});
        end            
        
        hold(FactorAxes(k,j), 'on');
        plot(FactorAxes(k,j), xl, [0 0], 'k:', 'Linewidth', 1.5);
                
        h(k,j) = hh;
        set(FactorAxes(k,j),'FontSize',14)
    end
end

%% Title for each mode
htitle = gobjects(nd,1);
if ( isscalar(res.Modetitles) && islogical(res.Modetitles) && (res.Modetitles == false) )
    ModeTitles = 'none';
else
    if isempty(res.Modetitles)
        ModeTitles = cell(nd,1);
        for i = 1:nd
            ModeTitles{i} = sprintf('Mode %d',i);
        end
    else
        ModeTitles = res.Modetitles;
    end
    
    axes(GlobalAxis);
    for k = 1:nd
        xpos = res.Hspaceleft + (k-1) * res.Hspace + sum(width(1:k-1)) + 0.5 * width(k);
        %xpos = res.Hspaceleft + (k-1) * (width + res.Hspace) + 0.5 * width;
        ypos = 1 - res.Vspacetop;
        htitle(k) = text(xpos,ypos,ModeTitles{k},'VerticalAlignment','Bottom','HorizontalAlignment','Center');
        set(htitle(k),'FontSize',16)
        set(htitle(k),'FontWeight','bold')
    end
end

%% Print factor titles
hftitle = gobjects(nc,1);
if ~strcmpi(res.Factortitle,'none')
    axes(GlobalAxis);
    rellambda = abs (K.lambda / K.lambda(1));
    for j = 1:nc
        xpos = 0.9 * res.Hspaceleft;
        ypos = 1 - res.Vspacetop - 0.5 * height - (j-1) * (height + res.Vspace);
        %ypos = 1 - res.Vspacetop - 0.5 * height - (j-1) * (1 + res.Vrelspace) * height;
        if strcmpi(res.Factortitle,'weight')          
            txt = sprintf('%3.2f', rellambda(j));
        else
            txt = sprintf('%d', j);
        end
        hftitle(j) = text(xpos,ypos,txt,'VerticalAlignment','Middle','HorizontalAlignment','Right');
        set(hftitle(j),'FontSize',14)
    end
end
%% Save stuff to return
info.height = height;
info.width = width;
info.ModeTitles = ModeTitles;
info.GlobalAxis = GlobalAxis;
info.FactorAxes = FactorAxes;
info.htitle = htitle;
info.hftitle = hftitle;
info.h = h;

axes(GlobalAxis)

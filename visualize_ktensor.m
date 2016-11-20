function [Ax, BigAx, fh] = visualize_ktensor(tnsrlist, varargin)
% VISUALIZE_KTENSOR, given a cell array of ktensors, plot the factors
%
%     [Ax, BigAx, FigHandle] = VISUALIZE_KTENSOR(X)
%     [Ax, BigAx, FigHandle] = VISUALIZE_KTENSOR({X,Y,...})

% check inputs
if ~iscell(tnsrlist) && ~isa(tnsrlist,'ktensor')
    error('input must be a ktensor or cell array of ktensors')
elseif ~iscell(tnsrlist)
    tnsrlist = {tnsrlist};
end

% tensor order, shape, and rank
nf = ndims(tnsrlist{1});
sz = size(tnsrlist{1});
nr = length(tnsrlist{1}.lambda);

% check that order, shapr, rank are consistent for all ktensors
for idx = 2:length(tnsrlist)
    if ndims(tnsrlist{idx}) ~= nf
        error(['ktensor at index ',num2str(idx),' has inconsistent number of dimensions.'])
    elseif ~all(size(tnsrlist{idx}) == sz)
        error(['ktensor at index ',num2str(idx),' has inconsistent shape.'])
    elseif length(tnsrlist{idx}.lambda) ~= nr
        error(['ktensor at index ',num2str(idx),' has inconsistent rank.'])
    end
end

% parse optional inputs
params = inputParser;

params.addParameter('nfactors', nr);
params.addParameter('align', true);
params.addParameter('space', 0.1);
params.addParameter('names', cell(1, nf));
params.addParameter('plots', repmat({'line'}, [1 nf]));
params.addParameter('a', repmat({10}, [1 nf]));
params.addParameter('c', cell(1, nf));
params.addParameter('linespec', repmat({'-'}, [1 nf]));
params.addParameter('link_yax', false(1,nf));
params.addParameter('ylims', cell(1, nf));
params.addParameter('pause', false);
params.addParameter('figure', -1);
params.addParameter('greedy', nr>5);
params.addParameter('permute', false(1,nf));
params.addParameter('linewidth', ones(1,3));

params.parse(varargin{:});
res = params.Results;

% TODO, other params: markertype %

% get appropriate figure
if isnumeric(res.figure) && res.figure < 1
    fh = figure();
elseif isgraphics(res.figure)
    fh = figure(res.figure);
    clf()
else
    error('invalid figure handle')
end

% set up the axes
[Ax,BigAx] = setup_axes(res.nfactors, nf, res.space, res.names);

% The 'sortdim' option sorts the entries along an axis by the top factor.
% This is useful if the tensor does not have a natural ordering along
% a certain dimension.
prm = cell(1, nf);
for f = 1:nf
    if res.permute(f)
        [~,prm{f}] = sort(tnsrlist{1}.u{f}(:,1),'descend');
    else
        prm{f} = 1:sz(f);
    end
end

% iterate over ktensors
for idx = 1:length(tnsrlist)

    if idx > 1 && res.align
        % align to first ktensor in list
        [~,X] = score(tnsrlist{1}, tnsrlist{idx}, 'greedy', res.greedy);
    else
        % don't do alignment
        X = tnsrlist{idx};
    end

    % main loop for plotting
    for f = 1:nf

        for r = 1:res.nfactors
            
            % fetch the axes to plot on
            axes(Ax(r,f));
            hold on

            % determine what to plot
            mkline = false;
            mkscat = false;
            mkbar = false;
            switch res.plots{f}
                case 'line'
                    mkline = true;
                case 'scatter'
                    mkscat = true;
                case 'bar'
                    mkbar = true;
                case 'scatterline'
                case 'linescatter'
                    mkscat = true;
                    mkline = true;
                otherwise
                    warn('did not understand plot type, defaulting to line plot.');
                    mkline = true;
            end

            % make plots
            x = 1:sz(f);
            y = X.u{f}(prm{f},r)*nthroot(X.lambda(r),nf);

            % line plot
            if mkline
                plot(x, y, res.linespec{f}, 'linewidth', res.linewidth(f))
            end

            % scatter plot
            if mkscat
                if isempty(res.c{f})
                    scatter(x, y, res.a{f})                        
                else
                    scatter(x, y, res.a{f}, res.c{f}, 'filled')
                end
            end

            % bar plot
            if mkbar
                bar(x, y)
            end

            % make axes tight
            axis tight
        end
    end


    % if user wants, pause before plotting next ktensor
    if res.pause
        pretty_ylims(Ax, res.ylims, res.link_yax);        
        pause
    end
end

% make the ylims look nice before returning
pretty_ylims(Ax, res.ylims, res.link_yax);        

%%%%%%%%%%%%%%%%%%%
% LOCAL FUNCTIONS %
%%%%%%%%%%%%%%%%%%%

function [Ax,BigAx] = setup_axes(nr, nf, space, names)

    % allocate storage
    Ax = gobjects(nr,nf);
    BigAx = gobjects(1,nf);
    
    % setup axes
    for f = 1:nf

        % invisible subplot bounding box
        BigAx(f) = subplot(1,3,f);
        set(BigAx(f),'Visible','off')
        pos = get(BigAx(f),'Position');
        w = pos(3);
        h = pos(4)/nr;
        pos(1:2) = pos(1:2) + space*[w h];

        % subaxes
        for r = 1:nr
            axPos = [pos(1) pos(2)+(nr-r)*h w*(1-space) h*(1-space)];
            Ax(r,f) = axes('Position',axPos);

            if ~isempty(names{f}) && r == 1
                title(names{f})
            end
            if r ~= nr
                set(Ax(r,f),'XTick',[])
            end
            if mod(r,2) == 0
                set(Ax(r,f),'YAxisLocation','right')
            end
        end
    end

function pretty_ylims(Ax, ylimits, link)

    % dimensions
    [nr,nf] = size(Ax);

    % set yticks %
    for f = 1:nf
        % if ylim pre-specified for this column
        if ~isempty(ylimits{f})
            yl = ylimits{f};
            yt = pretty_axticks(yl);
            set(Ax(:,f), 'ylim', yl, 'YTick', yt);

        % if ylim not pre-specified but linked in this column
        elseif link(f)
            % find new ylims
            yl = [Inf -Inf];
            for r = 1:nr
                ylr = get(Ax(r,f), 'ylim');
                if yl(1) > ylr(1)
                    yl(1) = ylr(1);
                end
                if yl(2) < ylr(2)
                    yl(2) = ylr(2);
                end
            end

            % set ylim and yticks
            yt = pretty_axticks(yl);
            set(Ax(:,f), 'ylim', yl, 'YTick', yt);

        % if ylim not pre-specified, just make the ticks pretty
        else
            for r = 1:nr
                yt = pretty_axticks(get(Ax(r,f), 'ylim'));
                set(Ax(r,f), 'YTick', yt);
            end
        end
    end

function ryl = pretty_axticks(yl)
    % round ylimits to 2 significant digits
    s = 10.^(floor(log10(abs(yl))-1));
    t0 = ceil(yl(1)/(s(1)+eps()))*s(1);
    t1 = floor(yl(2)/(s(2)+eps()))*s(2);
    ryl = [t0 t1];

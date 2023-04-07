function [line, blocks] = plotTT_to_explain_setup_times(timetable, blocksections, settings, type, include_blocks, firstTime)

try 
    blocksections.closed(1);
catch
    blocksections.closed(1) = 0;
end


headway = timetable.finish(3) - timetable.start(end-2)+ 12 + 9 + 6 + 9;
timetable = delayTrain(timetable, 102, headway, 1);

line = [];
ll = 0;
blocks = [];
bb = 0;
% 
blocksections.distance(7) = 8000;
blocksections.distance(8) = 9600;
blocksections.distance(9) = 11200;

% Generate the structure with lines and blocks, based on the timetable we
% have.

% Run over the complete timetable!
for ee = 1:size(timetable,1)
    
    switch timetable.direction(ee)
        case {2, 12}
            C = [238 130 144]/255;
            color = [139 0 0]/255;
        case {3, 13}
            C = [135 206 250]/255;
            color = [0 0 139]/255;
    end

    block = timetable.blocksection(ee);
    
    % Now the event on this section
    ll = ll+1;
    if timetable.direction(ee) == 12 | timetable.direction(ee) == 13
        line(ll).X1 = blocksections.distance(block) ...
                    - blocksections.length(block);
        line(ll).X2 = blocksections.distance(block);
    else
        line(ll).X1 = blocksections.distance(block);
        line(ll).X2 = blocksections.distance(block) ...
                    - blocksections.length(block);
    end
    line(ll).Y1 = timetable.arrival(ee);
    line(ll).Y2 = timetable.departure(ee);
    line(ll).Color = C;
    line(ll).Color = color;
    
    % Also the block
    
    bb = bb+1;
    if timetable.direction(ee) == 12 | timetable.direction(ee) == 13
        blocks(bb).left = line(ll).X1;
        blocks(bb).right = line(ll).X2;
    else
        blocks(bb).left = line(ll).X2;
        blocks(bb).right = line(ll).X1;
    end
    blocks(bb).bottom = timetable.start(ee);
    blocks(bb).top = timetable.finish(ee);
    blocks(bb).Color = C;
end

%% Actual plotting
figure;
hold on

% First, highlight the closed area
switch type
    case 'base'
        if max(timetable.finish) < 1200
            max_time = 1200;
        elseif max(timetable.finish) < 1800
            max_time = 1800;
        elseif max(timetable.finish) < 2400
            max_time = 2400;
        else
            max_time = 3600;
        end
    case 'hour'
        min_time = min([line.Y1, line.Y2]);
        max_time = min_time + 3600;
    case 'complete'
        max_time = settings.disruption.duration*3600;
end

for bb = 1:size(blocksections,1)
    if blocksections.closed(bb)
        x1 = blocksections.distance(bb) - blocksections.length(bb);
        rectangle('Position', [x1 -max_time blocksections.length(bb) max_time*2],...
                    'FaceColor', 0.90*[1 1 1],'EdgeColor','none');
    end
end



if include_blocks
    % Draw rectangles
    % rectangle('Position', [x_left_bottom, y_left_bottom, widht, height])
    for bb = 1:size(blocks,2)
        width = blocks(bb).right - blocks(bb).left;
        height = blocks(bb).top - blocks(bb).bottom;
        p = patch([blocks(bb).left  blocks(bb).right blocks(bb).right blocks(bb).left ],...  
            [blocks(bb).bottom blocks(bb).bottom blocks(bb).top blocks(bb).top],blocks(bb).Color);
        p.FaceAlpha = 0.3;
        p.EdgeAlpha = 0;  
    end
end

% Now plot everything
for ll = 1:size(line,2)
    plot([line(ll).X1, line(ll).X2], [line(ll).Y1, line(ll).Y2],'Color',line(ll).Color);
end

% Modify the axes
set(gca,'Ydir','reverse')
set(gca,'xaxislocation','top');
switch type
    case 'base'
        if max(timetable.finish) < 1200
            max_time = 1200;
        elseif max(timetable.finish) < 1800
            max_time = 1800;
        elseif max(timetable.finish) < 2400
            max_time = 2400;
        else
            max_time = 3600;
        end
    case 'hour'
        min_time = min([line.Y1, line.Y2]);
        max_time = min_time + 3600;
    case 'complete'
        max_time = settings.disruption.duration*3600;
end

try
    min_time;
catch
    min_time = 0;
end

min_time = -120;

xlim([0 11200]);
%xlim([0 max(blocksections.distance(strcmp(blocksections.type,'S2')))]);
ylim([min_time max_time]);

% % Get interesting axes!
% ax = gca;
% % set(ax,'XTick',[0, blocksections.distance'],'YGrid','on')
% % Where to put the YTicks? => every 15min?
% minT = ceil((min_time + firstTime)/900) * 900;
% YTickStart = mod(min_time + firstTime,900) + min_time;
% maxT = floor(max_time/900) * 900;
% maxT = floor((max_time + firstTime)/900) * 900;
% YTickEnd = floor((YTickStart + max_time - min_time)/900) * 900; % + firstTime;
% YTick = (YTickStart:900:YTickEnd);
% YTick_HHMMSS = {};
% YTickLab_num = minT:900:maxT;
% % First time
% startT = firstTime + min_time;
% if startT ~= YTickLab_num(1)
%     text = timeHHMMSS(startT);
%     YTick_HHMMSS{1} = text(1:end-3);
% %     YTick =[YTick(1) + startT - YTickLab_num(1), YTick];
%     YTick =[min_time, YTick];
%     for yy = 2:length(YTick)
%         text = timeHHMMSS(YTickLab_num(yy-1));
%         YTick_HHMMSS{yy} = text(1:end-3);
%     end
% else
%     for yy = 1:length(YTick)
%         text = timeHHMMSS(YTickLab_num(yy));
%         YTick_HHMMSS{yy} = text(1:end-3);
%     end
% end
% % Last time
% endT = startT + max_time - min_time;
% if endT ~= YTick(end)
%     text = timeHHMMSS(endT);
%     YTick_HHMMSS{end+1} = text(1:end-3);
%     YTick =[YTick, max_time + YTick(1) - min_time];
% end
% % YTick = YTick - 3600;
% 
% 
% while YTick(end) == YTick(end-1)
%     YTick(end) = [];
%     YTick_HHMMSS(end) = [];
% end
% 
% set(ax,'YTick',YTick,'YTickLabel',YTick_HHMMSS,'YGrid','on')
% set(ax, 'Ydir', 'reverse')
% Hide the x-axis tick labels and axis lines
% Hide the x-axis tick labels and axis lines
% Hide the x-axis ticks and lines


% Hide the x-axis ticks and lines
set(gca, 'XTick', []);
box off

% Add the x-axis label with adjusted font properties
xlabel('Distance', 'FontWeight', 'bold', 'FontSize', 12);

% Hide the y-axis ticks and lines
set(gca, 'YTick', []);
box off

% here
% Add the y-axis label with adjusted font properties
ylabel('Time', 'FontWeight', 'bold', 'FontSize', 12);

title('Set-up time case 4','Fontsize', 20);


% Show the closed area
try
    blocksections.closed(1);
catch
    blocksections.closed(1) = 0;
end

hold off;



end
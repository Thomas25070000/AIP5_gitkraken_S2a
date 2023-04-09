clear all;
close all;

pathSubfunctions = '/Users/thomasvandendorpe/Dropbox/Thesis/Code/AIP5_gitkraken_S2a/Case 1/Subfunctions';
addpath(genpath(pathSubfunctions));
addpath(genpath(pwd));
saveFigures = 1;
saveStats = 0;

%% Inputs and outputs


maxCC = 4;

for rr = 2
    runs = 1;   % 1 = tlimit 120s; 2 = tlimit 900s; 3 = MIPfocus
    runs = rr;
    
%     filename = 'Case 1 - input Tienen - morning';
	filenameInput = 'Case 1 - dummy data';
    sheet = 'Parameters';

    filenameOutput = 'Case 1 - dummy data - statistics.xlsx';
    sheetOutput = 'All';

    switch runs
        case 1
            filename = [filenameInput];
            sheetOutput = 'tlimit 120s';se
        case 2
            filename = [filenameInput];
            sheetOutput = 'tlimit 900s';
        case 3
            filename = [filenameInput];
            sheetOutput = 'MIP focus';
        otherwise
            error('Invalid run identifier');
    end
    
    
	[~,parameters,~] = xlsread(filenameInput,sheet,'A:A');
	[multi_param_values,textv,~] = xlsread(filenameInput,sheet,'B:Z');
	textv = textv(1,:);
    
	
	for cc = 1  %1:maxCC
		close all

		% Read the values
		param_values = multi_param_values(:,cc);
		settings = createSetting_Case1_singlemachine(parameters, param_values);
		

		% Give additional settings
		settings.general.caseName = 'Dummy';
		settings.saveStats = saveStats;
		settings.general.subName = textv{1,cc};
		switch runs
            case 1
                settings.general.subName = [settings.general.subName ' - tlimit 120s'];
            case 2
                settings.general.subName = [settings.general.subName ' - tlimit 900s'];
            case 3
                settings.general.subName = [settings.general.subName ' - MIP focus'];
            otherwise
                error('Invalid run identifier');
        end

		subName = settings.general.subName;

        %% Now an initial timetable can be generated.
        % Create the blocksections based on the infra data
        blocksections = generateBlockSections(settings);
        % Close blocksections
        blocksections = closeBlockSections(blocksections,settings);
        
        if (settings.trains.length.IC == 0) || (settings.trains.length.R == 0)
	        % Generate running times for both train types and all possible
	        % combinations! E.g. regular, disrupted, acc, decc, IC, L ...
	        runningtimes = generateRunningTimes(blocksections, settings);
	        Nblocks = size(blocksections,2);
	        clearingtimes.L1.regular = repmat(settings.TT.blocktimes.afterR,1,Nblocks);
	        clearingtimes.L0.regular = repmat(settings.TT.blocktimes.afterR,1,Nblocks);
	        clearingtimes.L1.disrupted = repmat(settings.TT.blocktimes.afterR,1,Nblocks);
	        clearingtimes.L0.disrupted = repmat(settings.TT.blocktimes.afterR,1,Nblocks);
	        clearingtimes.IC1.regular = repmat(settings.TT.blocktimes.afterIC,1,Nblocks);
	        clearingtimes.IC0.regular = repmat(settings.TT.blocktimes.afterIC,1,Nblocks);
	        clearingtimes.IC1.disrupted = repmat(settings.TT.blocktimes.afterIC,1,Nblocks);
	        clearingtimes.IC0.disrupted = repmat(settings.TT.blocktimes.afterIC,1,Nblocks);
        else
	        % Also generate the clearing times!
	        [runningtimes, clearingtimes] = generateRunningAndClearingTimes(blocksections, settings);
        end
        % Create the timetable
        if settings.TT.givenComplete
	        sheet = 'TimetableComplete';
	        [rawdata.num,rawdata.text,~] = xlsread(filename,sheet);
	        data.direction = rawdata.num(:,1);
	        data.entryHH = rawdata.num(:,3);
	        data.entryMM = rawdata.num(:,4);
        %   data.stops = rawdata.num(:,7);
        %   data.stops(find(isnan(data.stops))) = 0;
	        rawdata.text(1,:) = [];
	        data.type = rawdata.text(:,2);
	        [base_tt, hour_tt, complete_tt] = generateGivenTimetableComplete_v2(settings,blocksections,runningtimes,clearingtimes,data);
        elseif settings.TT.givenHour
	        sheet = 'TimetableHour';
	        [rawdata.num,rawdata.text,~] = xlsread(filename,sheet);
	        rawdata.num(:,2) = [];
	        rawdata.text(1,:) = [];
	        rawdata.text(:,[1,3]) = [];
	        [base_tt, hour_tt, complete_tt] = generateGivenTimetableHour_v2(settings,blocksections,runningtimes,clearingtimes,rawdata);
        else        
	        [base_tt, hour_tt, complete_tt] = generateTimetable_v2(settings,blocksections,runningtimes,clearingtimes);
        end
        
        timetable = complete_tt;
        allblocks = blocksections;
        complete_runningtimes = runningtimes;
        
        % If there are still blocks A/B and C, remove these from the timetable!
        [timetable, blocksections, runningtimes] = slimTimetable(timetable,blocksections,runningtimes);
        
        
        HH = 17;
        MM = 40;
        SS = 0;
        firstTime = HH * 3600 + MM * 60 + SS;
        [arrtime, arrtimeHHMMSS, deptime, deptimeHHMMSS] = retrieveArrivalAndDepartureTimes(timetable, firstTime);
        settings.firstTime = firstTime;
        
        % Extract a specific hour for the timetable
        hour = 1;
        hour_tt = getHourFromTimetable(complete_tt,settings,hour);
        % This one gives the most busy hour!
        hour_tt = getHourFromTimetable(complete_tt,settings);
        
        % Plot and save figures
        include_blocks = 1;
%         [line, blocks] = plotTT_2(hour_tt, allblocks, settings, 'hour', include_blocks, firstTime);
%         [line, blocks] = plotTT_3(hour_tt, allblocks, settings, 'hour', include_blocks, firstTime);

%        [line, blocks] = plotTT(hour_tt, allblocks, settings, 'hour', include_blocks, firstTime);
% 
%         if saveFigures
% 	        figname = [settings.general.caseName ' ' settings.general.subName ' original - 1h.fig'];
% 	        savefig(gcf,figname);
%         end
% %         [line, blocks] = plotTT(complete_tt, allblocks, settings, 'complete', include_blocks, firstTime);
% %         if saveFigures
% % 	        figname = [settings.general.caseName ' ' settings.general.subName ' original - complete.fig'];
% % 	        savefig(gcf,figname);
% %         end
%         
%         regular.TT = timetable;


		%% Apply blockage
		% Due to the blockage, the running times will increase, which make the
		% timetable (probably) infeasible.


		% Update the running times
		timetable = updateRunningTimes_v2(timetable, runningtimes, settings);
        full_timetable = updateRunningTimes_v2(complete_tt,complete_runningtimes,settings);
        regular.TT = timetable;

        % Create headway matrix for full section
		[minHW, trains] = createHeadwayMatrixClosedSection(full_timetable, allblocks, settings);
		[minHW_reg] = createHeadwayMatrixRegularTT(full_timetable, allblocks, settings);
		
		settings.clearingtimes = clearingtimes;

		regular.HW = minHW_reg;
        
        [new_timetable, measures, statistics] = scheduleFIFO(full_timetable, allblocks, settings)
        
                
		% Create headway matrix for closed section
% 		[minHW, trains] = createHeadwayMatrixClosedSection(timetable, blocksections, settings);
% 		[minHW_reg] = createHeadwayMatrixRegularTT(regular.TT, blocksections, settings);
% 		
% 		settings.clearingtimes = clearingtimes;
% 
% 		regular.HW = minHW_reg;
       % [new_timetable, measures, statistics] = scheduleFIFO(timetable, blocksections, settings)
        
         % Create headway matrix for full section
% 		[minHW, trains] = createHeadwayMatrixClosedSection(full_timetable, allblocks, settings);
% 		[minHW_reg] = createHeadwayMatrixRegularTT(full_timetable, allblocks, settings);
% 		
% 		settings.clearingtimes = clearingtimes;
% 
% 		regular.HW = minHW_reg;
    %    [new_timetable, solu, measures, statistics] = modelCase1_singleMachine(full_timetable, regular, allblocks, trains, minHW, settings, complete_runningtimes)


        [minHW, trains] = createHeadwayMatrixClosedSection(full_timetable, allblocks, settings);
		[minHW_reg] = createHeadwayMatrixRegularTT(regular.TT, blocksections, settings);
		
		settings.clearingtimes = clearingtimes;

		regular.HW = minHW_reg;
                

       [timetable, solu] = modelCase1_singleMachine_v2(full_timetable, allblocks, trains, minHW, settings)%         figname = 'Tienen - evening - FIFO - low vD';
        title('Tienen - evening - FIFO - low vD');
%         
		% Save the adjusted figure
		if saveFigures
			figname = [settings.general.caseName ' ' settings.general.subName ' adjusted.fig'];
			savefig(gcf,figname);
		end

		% Save the statistics and measures.
		if saveStats
			statsname = [settings.general.caseName ' ' settings.general.subName ' adjusted - stats.mat'];
			try
				save(statsname,'settings','statistics','measures','new_timetable');
			catch
				disp('Statistics not generated, impossible to save them');
			end
		end
		
		% Write the statistics to Excel!
		if saveStats
			writeStatsToExcel_parameterVariation(filenameOutput, sheetOutput, settings, statistics);
		end
		
    end


end
    
    

    


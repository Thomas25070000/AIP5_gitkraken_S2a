function writeStatsToExcel(filenameOutput, sheetOutput, settings, statistics)

[~,columnnames,~] = xlsread(filenameOutput,sheetOutput,'A1:Q1');

% Find the row number
[~,versionNames,~] = xlsread(filenameOutput,sheetOutput,'A:A');

newVersion = ['v' int2str(settings.general.modelVersion)];
if settings.general.modelVersion >= 9
    orderLimit = settings.TT.orderlimit;
    settings.general.subName = [settings.general.subName ' max' int2str(orderLimit)];
    newVersion = ['v' int2str(settings.general.modelVersion) ' - max. ' int2str(orderLimit)];
elseif settings.general.modelVersion == 8
    newVersion = ['v' int2str(settings.general.modelVersion) ' - hour after'];
elseif settings.general.modelVersion == 7
    newVersion = ['v' int2str(settings.general.modelVersion) ' - basic'];
end

newrow = length(versionNames) + 1;    

% We now know the row that has to be filled, start filling the columns
tobewritten = [];
tobewritten{1} = newVersion;

% Max. delay information
col = find(strcmp(columnnames,'max. delay (s)'));
tobewritten{col} = int2str(statistics.maxDelay);
col = find(strcmp(columnnames,'mD - HHMMSS'));
tobewritten{col} = statistics.maxDelay_HHMMSS;
col = find(strcmp(columnnames,'mD - dir 0'));
tobewritten{col} = statistics.maxDelay_HHMMSS_0;
col = find(strcmp(columnnames,'mD - dir 1'));
tobewritten{col} = statistics.maxDelay_HHMMSS_1;

% Total delay information
col = find(strcmp(columnnames,'total delay (s)'));
tobewritten{col} = int2str(statistics.totalDelay);
col = find(strcmp(columnnames,'tD - HHMMSS'));
tobewritten{col} = statistics.totalDelay_HHMMSS;
col = find(strcmp(columnnames,'tD - dir 0'));
tobewritten{col} = statistics.totalDelay_HHMMSS_0;
col = find(strcmp(columnnames,'tD - dir 1'));
tobewritten{col} = statistics.totalDelay_HHMMSS_1;

% Average delay information
col = find(strcmp(columnnames,'average delay (s)'));
tobewritten{col} = int2str(statistics.averageDelay);
col = find(strcmp(columnnames,'aD - HHMMSS'));
tobewritten{col} = statistics.averageDelay_HHMMSS;
col = find(strcmp(columnnames,'aD - dir 0'));
tobewritten{col} = statistics.averageDelay_HHMMSS_0;
col = find(strcmp(columnnames,'aD - dir 1'));
tobewritten{col} = statistics.averageDelay_HHMMSS_1;

% Cancellation information
col = find(strcmp(columnnames,'# cancelled'));
tobewritten{col} = int2str(statistics.nrCancelled);
col = find(strcmp(columnnames,'# cancelled - dir 0'));
tobewritten{col} = int2str(statistics.nrCancelled_dir0);
col = find(strcmp(columnnames,'# cancelled - dir 1'));
tobewritten{col} = int2str(statistics.nrCancelled_dir1);

% CPU time
col = find(strcmp(columnnames,'CPU time (s)'));
tobewritten{col} = num2str(statistics.CPUtime);


xlsRange = ['A' int2str(newrow)];
xlswrite(filenameOutput,tobewritten,sheetOutput,xlsRange);

end
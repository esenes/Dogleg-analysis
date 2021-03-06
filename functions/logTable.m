function [ msg ] = logTable( fname, l00, l01, l02, l03, l04, l05, l06, l07, mode  )
%   initLog.m appends the table with results to the report file
%
%   Inputs:
%     - fname: enter the full path ending with extension
%     - l00: numebr of B0 events
%     - l01: number of BDs in the metric
%     - l02: number of good BDs overall
%     - l03: number of spikes
%     - l04: number of BDs in clusters (sorted out)
%     - l05: number of BDs from missed beams
%     - l06: number of secondaries from spikes
%     - l07: number of secondaries from missed beams
%     - mode: select the message for the loaded or unloaded case
%     
%   Last modified: 26.08.2016 by Eugenio Senes

logID = fopen(fname, 'a' ); 
tab = ' | ';

if strcmpi(mode, 'loaded')
    msg = ['BD candidates found: ' num2str(l00) ' of which ' num2str(l01) ' are into the metric' '\n' ...
        '\n' 'Into the metric:' '\n\n' ...
        ...%title
        'BDs' tab 'BDs with spikes' tab 'BDs clusters' tab 'BDs missed beams' tab ...
        'secondaries from spikes' tab 'secondaries from missed beams' '\n'...
        ...%hline
        '---------------------------------------------------------------------'...
        '---------------------------------------------' '\n'...
        ...%data
        num2str( l02 ) '           ' num2str(l03) '               '  num2str(l04)  ...
        '               ' num2str(l05)  '                     ' num2str(l06) ...
        '                            ' num2str(l07) '\n'...
    '\n \n' ...
    ];
elseif strcmpi(mode, 'unloaded')
    msg = ['BD candidates found: ' num2str(l00) ' of which ' num2str(l01) ' are into the metric' '\n' ...
        '\n' 'Into the metric:' '\n\n' ...
        ...%title
        'BDs' tab 'BDs with spikes' tab 'BDs clusters' tab 'BDs missed beams' tab ...
        'secondaries from spikes' tab 'secondaries from missed beams' '\n'...
        ...%hline
        '---------------------------------------------------------------------'...
        '---------------------------------------------' '\n'...
        ...%data
        num2str( l02 ) '           ' num2str(l03) '               '  num2str(l04)  ...
        '               ' num2str(l05)  '                     ' num2str(l06) ...
        '                            ' num2str(l07) '\n'...
    '\n \n' ...
    ];
end
    
fprintf(logID,msg);
fclose(logID);

end


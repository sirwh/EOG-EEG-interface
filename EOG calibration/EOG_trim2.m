%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: To delete the unnecessary parts of EOG data. Only keep 3-second data (2~4s) for each trial.
%--------------------------------------------------------------------------------------------------------------------------------
% Used in: matchingtrain.m
%--------------------------------------------------------------------------------------------------------------------------------
% Update : 2014/12/26 by Jiaxin MA @Kyoto Univ.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function result = EOG_trim2(input, fs, chn, trail, delay)

input(:, 1:delay*fs) = []; % delete the blank interval of beginning 
result = [];
head=fs*1; % the start time
tail=fs*4-1; % the end time
len=fs*5; % the trial length (5s)

for i = 1:trail
    result = [result input(2:2+chn-1, head:tail)]; % take 3-second data from a trial
    input(:,1:len)=[];
end

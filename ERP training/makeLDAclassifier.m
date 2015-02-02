function makeLDAclassifier(filename)

global P300classifier

load(filename);

samplefreq=64;
triallength=800;
NrOfChannels=size(y,1)-3;

%% Downsample to 64 Hz
tmp=y;
clear y;

for ii=1:size(tmp,1)
    kk=2;
    for jj=1:4:size(tmp,2)-3
        meantmp=tmp(ii,jj:jj+3)';
        y(ii,kk)=mean(meantmp);
        kk=kk+1;
        
    end
end
y(end-1,1:length(y(end-1,:))-2)=y(end-1,3:length(y(end-1,:)));
y(end,1:length(y(end,:))-2)=y(end,3:length(y(end,:)));


%% Convert triallength from ms to samples
triallength=ceil(triallength*samplefreq/1000)+1;


%% Create Trialnumbers, increase Trialnumber when a Row/Column flashes
size_y=size(y);
trialnr=[];
max_trial=0;
for ii=1:size_y(2)-1
    if (y(size_y(1)-1,ii+1) > 0) && (y(size_y(1)-1,ii) == 0)
        max_trial=max_trial+1;
    end
    trialnr(ii+1)=max_trial;
end

%% Find out how often a Row or Column was intensified
trials=unique(trialnr);

%% Initialization of target arrays
index_withP300=1;
index_withoutP300=1;
withP300=[];
withoutP300=[];

% Transpose recorded data for compatibility isssues
y=y';

signal_filtered=y(:,2:NrOfChannels+1);


%% Extract Data from Bandpass filtered signal

% Define length of pre-stimulus-interval in ms
preStimulusms=100;
% Convert time in ms to samplenumber
preStimulus=ceil(preStimulusms*samplefreq/1000);

for cur_trial=min(trials)+1:max(trials)

    % get the indeces of the samples of the right trial
    trialidx=find(trialnr == cur_trial);

    % extract data for response to each intensification
    % extraction starts at the beginning of each intensification
    % data for the length of the time window is extracted
    trialdata=...
        signal_filtered(min(trialidx)+1:min(trialidx)...
        +triallength-preStimulus-1,:);
    
    % extract pre-stimulus-interval
    preStimulusData=...
        signal_filtered(min(trialidx)-preStimulus+2:...
        min(trialidx),:);
    % average pre-stimulus-interval
    
    preStimulusOffset=mean(preStimulusData);
    
    % Perform offset correction
    for ii=1:length(trialdata)
        trialdata(ii,:)=trialdata(ii,:)-preStimulusOffset;
    end
    
    % Find out if current trial contains desired character
    % 0... row/column does not contain desired character
    % 1... intensified column does contain desired character
    cur_stimulustype=max(y(trialidx, size_y(1)));

    % If response to stimulus does not contain P300
    % save data to array withoutP300
    if cur_stimulustype == 0
        withoutP300.data(:,index_withoutP300*NrOfChannels-(NrOfChannels-1):...
            index_withoutP300*NrOfChannels)=trialdata;
        index_withoutP300=index_withoutP300+1;

    % If response to stimulus does contain P300
    % save data to array withP300
    else
        withP300.data(:,index_withP300*NrOfChannels-(NrOfChannels-1):...
            index_withP300*NrOfChannels)=trialdata;
        index_withP300=index_withP300+1;
    end
end

%% Moving average filtering of extracted data
windowSize = 3;
withP300.filtered=filter...
    (ones(1,windowSize)/windowSize,1,withP300.data);
withoutP300.filtered=filter...
    (ones(1,windowSize)/windowSize,1,withoutP300.data);

%% Downsample data
withP300.downsampled=downsample(withP300.filtered, windowSize);
withoutP300.downsampled=downsample(withoutP300.filtered, windowSize);

%% Create data vectors for LDA
train_LDA=[];
size_withP300=size(withP300.downsampled);
size_withoutP300=size(withoutP300.downsampled);
train_LDA.X=zeros(size_withP300(1)*NrOfChannels,...
     size_withP300(2)/NrOfChannels+size_withoutP300(2)/NrOfChannels);

%% Write vectors for trainingdata with P300 response
for ii=1:size_withP300(2)/NrOfChannels
    for kk=1:NrOfChannels
        train_LDA.X(kk*size_withP300(1)-(size_withP300(1)-1):...
            kk*size_withP300(1),ii)=...
            withP300.downsampled(:,(ii-1)*NrOfChannels+kk);        
        kk=kk+1;
    end
    train_LDA.Y(ii)=1; % Class label is 1 if signal contains P300
    ii=ii+1;
end

%% Append vectors for trainingdata without P300 response
for ii=1:size_withoutP300(2)/NrOfChannels
    for kk=1:NrOfChannels
        train_LDA.X(kk*size_withoutP300(1)-(size_withoutP300(1)-1):...
            kk*size_withoutP300(1),ii+size_withP300(2)/NrOfChannels)=...
            withoutP300.downsampled(:,(ii-1)*NrOfChannels+kk);        
        kk=kk+1;
    end
    train_LDA.Y(ii+size_withP300(2)/NrOfChannels)=2;
    % Class label is 2 if signal does not contain P300
    ii=ii+1;
end

%% Create Classifier

X=train_LDA.X';
K=train_LDA.Y';


P300classifier.method=1;
P300classifier.F=lda(X,K);
save P300classifier_LDA P300classifier

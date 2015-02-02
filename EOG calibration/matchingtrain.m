%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: Use pattern matching method to detect eye movements (blink, frown, wink, gaze) from EOG signal.
%--------------------------------------------------------------------------------------------------------------------------------
% Use: Click "Run Section" to run sections of this script one by one. Each section detects a kind of eye movement. 
% Adjust the threshold values if the detection is not accurate.
%--------------------------------------------------------------------------------------------------------------------------------
% Update : 2014/12/26 by Jiaxin MA @Kyoto Univ.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
load 'test_0731_chen_0000.mat' % (MODIFY THIS LINE) load a file of EOG recording
result = EOG_trim2(y, 256, 4, 60, 20); % parameters: input data, sample rate, channel number, trial number, delay from begining 
for i=1:4 
    result2(i,:) = decimate(result(i,:), 8); % downsample the data (256Hz to 32Hz)
end
trial=10; % trial number for one kind of eye movement 
fs=32; % new sample rate (Hz)
triallen=3*trial*fs;

%% blink
% the pattern matching method is not good for detecting triple blink,
% because the 3-blinks could have large diversity.

%% frown
data = result2(1,triallen*0+1:triallen*1); % locate frown data
drawdata(data,trial,fs); % plot the data
[record difrecord] = getrecording(data,trial,fs,1); % retrieve a 1-sec interval (centered by local maximum) from each trial. The output are the frown patterns.
sample = sum(record,1)./size(record,1); % take average to get a standard pattern.
figure; plot(sample);
fdis = checkmatching(sample, result2(1,:), fs, 0.1); % (MODIFY THIS LINE) do pattern matching over the whole data. 0.1 is a threshold value.

%% left wink
dataL = result2(3,triallen*2+1:triallen*3);
drawdata(dataL,trial,fs);
[recordL difrecordL] = getrecording(dataL,trial,fs,1);
sample = sum(recordL,1)./size(recordL,1);
figure; plot(sample);
fdis = checkmatching(sample, result2(3,:), fs, 0.1);

%% right wink
dataR = result2(4,triallen*3+1:triallen*4);
drawdata(dataR,trial,fs);
[recordR difrecordR] = getrecording(dataR,trial,fs,1);
sample = sum(recordR,1)./size(recordR,1);
figure; plot(sample);
fdis = checkmatching(sample, result2(4,:), fs, 0.1);

%% left gaze
re = result2(3,:)-result2(4,:);
dataL = re(triallen*4+1:triallen*5);
drawdata(dataL,trial,fs);
[recordL difrecordL] = getrecording2(dataL,trial,fs,0.5); %here getrecording.m also works, but for single peak, better to use getrecording2.m
sample = sum(recordL,1)./size(recordL,1);
figure; plot(sample);
fdis = checkmatching(sample, re, fs, 0.1);

%% right gaze
dataR = -re(triallen*5+1:triallen*6);
drawdata(dataR,trial,fs);
[recordR difrecordR] = getrecording2(dataR,trial,fs,0.5);
sample = -sum(recordR,1)./size(recordR,1);
figure; plot(sample);
fdis = checkmatching(sample, re, fs, 0.1);

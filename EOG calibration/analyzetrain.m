%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: Use threshold method to detect eye movements (blink, frown, wink, gaze) from EOG signal.
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
data = result2(1,triallen*1+1:triallen*2); % locate blink data
drawdata(data,trial,fs); % plot the data
blkc = EOG_getpeak(data, 32, 10, -10, 150, 0.01, 0.5, 0, 0); % use default parameters to detect blinks
drawblinkline(data, blkc); % check whether the default parameter could detected all the blinks
for i=1:4:length(blkc)
    j=ceil(i/4);
    v1=max(data(blkc(i):blkc(i+3)));
    vp_blink(j) = max(diff(data(blkc(i):blkc(i+3))));  % positive peak velocity
    vn_blink(j) = min(diff(data(blkc(i):blkc(i+3))));  % negative peak velocity
    a_blink(j)  = v1-data(blkc(i)); % amplitude
end
vp_blink=sort(vp_blink); vn_blink=sort(vn_blink); a_blink=sort(a_blink);
throw=0;   % (MODIFY THIS LINE) how many outlier will be discarded
THblink = [0.5*vp_blink(1+throw) 0.5*vn_blink(end-throw) 0.8*a_blink(1+throw)];  % (MODIFY THIS LINE) calculate the thresholds, adjust the parameters if necessary

blkc = EOG_getpeak(result2(1,:), 32, THblink(1), THblink(2), THblink(3), 0.01, 0.5, 10, -10);  % (MODIFY THIS LINE) use thresholds to detect frown over the whole data, adjust the parameters if necessary
drawblinkline(result2(1,:), blkc);


%% for frown
data = result2(1,triallen*0+1:triallen*1); % locate frown data
drawdata(data,trial,fs); % plot the data
[record difrecord] = getrecording(data,trial,fs,1); % retrieve a 1-sec interval (centered by local maximum) from each trial. The output are the frown patterns.
for i=1:trial   % calculate amplitudes and velocities from patterns
    a_frown(i) = max(record(i,:)); % amplitude
    vp_frown(i) = max(difrecord(i,:)); % positive peak velocity
    vn_frown(i) = min(difrecord(i,:));  % negative peak velocity
end
vp_frown=sort(vp_frown); vn_frown=sort(vn_frown); a_frown=sort(a_frown);
throw=0; % (MODIFY THIS LINE) how many outlier will be discarded
THfrown = [0.4*vp_frown(1+throw) 0.5*vn_frown(end-throw) 0.8*a_frown(1+throw)]; % (MODIFY THIS LINE) calculate the thresholds, adjust the parameters if necessary

blkf = EOG_getpeak(result2(1,:), 32, THfrown(1), THfrown(2), THfrown(3), 0.6, 2, 10, 0); % (MODIFY THIS LINE) use thresholds to detect frown over the whole data, adjust the parameters if necessary
drawblinkline(result2(1,:), blkf); % plot the result

%% for left wink
dataL = result2(3,triallen*2+1:triallen*3); % locate wink data
drawdata(dataL,trial,fs); % plot the data
[recordL difrecordL] = getrecording(dataL,trial,fs,1); % retrieve a 1-sec interval (centered by local maximum) from each trial.
for i=1:trial   % calculate amplitudes and velocities from patterns  
    a_winkL(i) = max(recordL(i,:));
    vp_winkL(i) = max(difrecordL(i,:));
    vn_winkL(i) = min(difrecordL(i,:));
end
vp_winkL=sort(vp_winkL); vn_winkL=sort(vn_winkL); a_winkL=sort(a_winkL);
throw=0; % (MODIFY THIS LINE) how many outlier will be discarded
THwinkL = [0.5*vp_winkL(1+throw) 0.5*vn_winkL(end-throw) 0.8*a_winkL(1+throw)]; % (MODIFY THIS LINE) calculate the thresholds, adjust the parameters if necessary

blkwl = EOG_getpeak(result2(3,:), 32, THwinkL(1), THwinkL(2), THwinkL(3), 0.1, 0.5, 10, 0); % (MODIFY THIS LINE) use thresholds to detect wink over the whole data, adjust the parameters if necessary
drawblinkline(result2(3,:), blkwl); % plot the result

%compare the correlation of EOG ch3 and ch4, it should be positive-related for wink, and negative-related for gaze. This is to reduce the false-detection.
dis = zeros(1,length(blkwl)/4);
for i=1:4:length(blkwl)
    dis((i+3)/4) = corr(result2(3, blkwl(i):blkwl(i+3))', result2(4, blkwl(i):blkwl(i+3))');
    if dis((i+3)/4)<-0.8 % the correlation threshold is set to -0.8
        blkwl(i:i+3)=0;
    end
end
blkwl=blkwl(find(blkwl));
figure;
plot(dis) 

drawblinkline(result2(3,:), blkwl); % plot the result

%% right wink
dataR = result2(4,triallen*3+1:triallen*4);
drawdata(dataR,trial,fs);
[recordR difrecordR] = getrecording2(dataR,trial,fs,1);
for i=1:trial    
    a_winkR(i) = max(recordR(i,:));
    vp_winkR(i) = max(difrecordR(i,:));
    vn_winkR(i) = min(difrecordR(i,:));
end
vp_winkR=sort(vp_winkR); vn_winkR=sort(vn_winkR); a_winkR=sort(a_winkR);
throw=0;
THwinkR = [0.5*vp_winkR(1+throw) 0.5*vn_winkR(end-throw) 0.8*a_winkR(1+throw)]; 

blkwr = EOG_getpeak(result2(4,:), 32, THwinkR(1), THwinkR(2), THwinkR(3), 0.1, 0.5, 10, 0);
drawblinkline(result2(4,:), blkwr);

dis = zeros(1,length(blkwr)/4);
for i=1:4:length(blkwr)
    dis((i+3)/4) = corr(result2(3, blkwr(i):blkwr(i+3))', result2(4, blkwr(i):blkwr(i+3))');
    if dis((i+3)/4)<-0.8
        blkwr(i:i+3)=0;
    end
end
blkwr=blkwr(find(blkwr));
figure;
plot(dis) 

drawblinkline(result2(4,:), blkwr);

%% for left gaze
re = result2(3,:)-result2(4,:); % gaze data is detected from the difference of ch3 and ch4
dataL = re(triallen*4+1:triallen*5);
drawdata(dataL,trial,fs);
[recordL difrecordL] = getrecording2(dataL,trial,fs,0.5); %here getrecording.m also works, but for single peak, better to use getrecording2.m
for i=1:trial    
    vp_gazeL(i) = max(difrecordL(i,:));
    a_gazeL(i) = max(recordL(i,:));
end
vp_gazeL=sort(vp_gazeL); a_gazeL=sort(a_gazeL);
throw=0;
THgazeL = [0.8*vp_gazeL(1+throw) 0.8*a_gazeL(1+throw) 1.4*a_gazeL(end-throw)]; % (MODIFY THIS LINE) calculate the thresholds, adjust the parameters if necessary
blkgl = EOG_getgaze(re, fs, THgazeL(1), THgazeL(2), THgazeL(3), 0.05, 0.5); % (MODIFY THIS LINE) use thresholds to detect gaze over the whole data, adjust the parameters if necessary

dis = zeros(1,length(blkgl)/2);
for i=1:2:length(blkgl)
    dis((i+1)/2) = corr(result2(3, blkgl(i):blkgl(i+1))', result2(4, blkgl(i):blkgl(i+1))');
    if dis((i+1)/2)>-0.8  % the correlation threshold is set to -0.8
        blkgl(i:i+1)=0;
    end
end
blkgl=blkgl(find(blkgl));
figure;
plot(dis)

drawblinkline3(re, blkgl, 10);

%% right gaze
re = result2(4,:)-result2(3,:); % gaze data is detected from the difference of ch3 and ch4
dataR = re(triallen*5+1:triallen*6);
drawdata(dataR,trial,fs);
[recordR difrecordR] = getrecording2(dataR,trial,fs,0.5); %here getrecording.m also works, but for single peak, better to use getrecording2.m
for i=1:trial    
    vp_gazeR(i) = max(difrecordR(i,:));
    a_gazeR(i) = max(recordR(i,:));
end
vp_gazeR=sort(vp_gazeR); a_gazeR=sort(a_gazeR);
throw=0;
THgazeR = [0.8*vp_gazeR(1+throw) 0.8*a_gazeR(1+throw) 1.4*a_gazeR(end-throw)]; % (MODIFY THIS LINE) calculate the thresholds, adjust the parameters if necessary
blkgr = EOG_getgaze(re, fs, THgazeR(1), THgazeR(2), THgazeR(3), 0.05, 0.5); % (MODIFY THIS LINE) use thresholds to detect gaze over the whole data, adjust the parameters if necessary

dis = zeros(1,length(blkgr)/2);
for i=1:2:length(blkgr)
    dis((i+1)/2) = corr(result2(3, blkgr(i):blkgr(i+1))', result2(4, blkgr(i):blkgr(i+1))');
    if dis((i+1)/2)>-0.8  % the correlation threshold is set to -0.8
        blkgr(i:i+1)=0;
    end
end
blkgr=blkgr(find(blkgr));
figure;
plot(dis)

drawblinkline3(re, blkgr, 10);

%% save the thresholds
save('EOG_TH.mat', 'THblink', 'THfrown', 'THgazeL', 'THgazeR', 'THwinkL', 'THwinkR');
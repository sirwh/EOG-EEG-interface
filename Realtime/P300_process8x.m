function [sys,x0,str,ts] = P300_process8x(t,x,u,flag,windTime,...
    runmax,channels, method, P300classifier)
%
%   The Signal Processing Block has the following tasks to perform:
%       - detect an input at the data line ID-Flash
%       - load the EEG-Data into the correct Buffer
%       - when the Run-Number maximum has reached the S-function has to
%         activate the STOP control line
%       - the function has to detect the letter with the maximum value in
%         the appropriate EEG-Buffer
%       - set the control line ID-RESULT with the number of the Solution
%         Letter
%
%   With double-click on the Signal Processing Block in the Simulink model,
%   you can set the following Options:
%
%   1. Buffer Window Time[ms] - The time how long the EEG-data of every
%                               letter should be saved
%
%   2. Maximum Number of Runs
%
% Modified for Linear Discriminant Analysis and SVM
% Markus Waldhauser
% 15. Mai 2007
% Version 1.2
%
% 1999-2006 g.tec medical engineering GmbH

global userData

switch flag

%% Case 2    
    case 2      %Update of discrete states

        %----------------------------------------------------------
        % Save the EEG-Data in the AppendBuffer
        %  This buffer is used for the BaseLineCorrection. It will be
        %  appended in front of the EEG-Buffer of the Letter.
        %----------------------------------------------------------

        userData.appendBuffer.data(:,1:userData.appendBuffer.size-1)=...
            userData.appendBuffer.data(:, 2:userData.appendBuffer.size);
        userData.appendBuffer.data(1: userData.NrOfChannels,...
                 userData.appendBuffer.size) =...
                 u(1: userData.NrOfChannels)';
        
        
        tLoadBuf = userData.tLoadBuf;       % analysis time window for P300 classification
        if userData.runnumber <= userData.runmax
%%           
            %---------------------------------------------------
            % Initialization control line activated (ID-INIT)
            %---------------------------------------------------
            if u(userData.NrOfChannels+1) ~= 0         
                %-----------------------------
                % call the newInit function
                %-----------------------------
                newInit(windTime);
                
                input = u(userData.NrOfChannels+1); 
                
                %initalize the Buffer
                for k = 1:userData.runmax               % runmax: number of trials used for P300 classification
                    for i = 1:input
                        size = userData.buffSize;
                        userData.runBuffer(k,i).size = size;
                        userData.runBuffer(k,i).data = zeros(1,size);
                    end
                end
                
                %-----------------------------------------------------------
                % the ID-FLASH data line is activated when you need other
                % information from the Paradigm-Block. e.g. the Row/Col
                % Char Flash needs the number of rows+cols with an entry.
                %----------------------------------------------------------- 
%% Numner of flashes per trial  12 for Row/Colum, 36 for Single Char
                if u(userData.NrOfChannels+2) ~= 0     
                    userData.numFlashes = u(userData.NrOfChannels+2);
                else
                    userData.numFlashes = u(userData.NrOfChannels+1);
                    %numFlashes == number of Buffers
                end                              %e.g. Single Char Flash
%%           
            %---------------------------------------------------
            % Flash data line activated (ID-FLASH)
            %---------------------------------------------------
            elseif u(userData.NrOfChannels+2) ~= 0          % u(userData.NrOfChannels+2): which stimulus is flashing currently

                userData.k = userData.k+1;
                for i=1:numel(userData.flashArr)  %number of parallel filled Buffers
                    if isempty(userData.flashArr{i})  %new Buffer has to be filled
                        
                        if userData.numFlashes == 12
                            input = u(userData.NrOfChannels+2:length(u));
                            if input(1)==1 && input(2) == 2
                                BufferToFill=7;
                            elseif input(1)==7
                                BufferToFill=8;
                            elseif input(1)==13
                                BufferToFill=9;
                            elseif input(1)==19
                                BufferToFill=10;
                            elseif input(1)==25
                                BufferToFill=11;
                            elseif input(1)==31
                                BufferToFill=12;
                            else
                                BufferToFill=input(1);
                            end
                        elseif userData.numFlashes == 8
                            % if Single Character Flash
                            BufferToFill = u(userData.NrOfChannels+2:length(u));
                        end
                        
                        userData.flashArr{i} = BufferToFill;        % the buffer corresponding to the flashing stimulus will be filled
                        %**************************************
                        userData.runArr(i) = userData.runnumber;
                        %**************************************
                        logIndex = userData.flashArr{i} ~= 0;     %delete all 0-elements
                        userData.flashArr{i} = userData.flashArr{i}(logIndex);

                        break;
                    end
                end
                %% If all the stimuli are flashed runmax times
                if userData.k == userData.numFlashes && ...
                    userData.runnumber == userData.runmax
                    userData.output(1) = 1;     %STOP Flash Letters
                % if a flash block finish    
                elseif userData.k == userData.numFlashes  %run is ready
                    userData.runnumber = userData.runnumber+1;
                    userData.k = 0;
                end
            end
            
            
            
%%    
            for elem=1:numel(userData.flashArr)  %how many Buffers have to be filled parallel
                if ~isempty(userData.flashArr{elem}) ...    % >1 if the Buffer has to be filled
                        && userData.runnumber <= userData.runmax
                    if userData.newrun(elem)
                        userData.newrun(elem)=false;
                        userData.tStart(elem) = t;   %set the new starttime
                    end

                    if t > userData.tStart(elem)
%%                         
                        if userData.sample(elem) == 1   %first Sample
                            %-------------------------------------
                            % append the 100ms Running-Buffer in 
                            % front of the EEG-Buffer
                            %-------------------------------------
                            size1 = userData.appendBuffer.size;
                            size2 = userData.buffSize;

                            for i = 1:length(userData.flashArr{elem})
                                userData.runBuffer(userData.runArr(elem), ...
                                                   userData.flashArr{elem}(i)).data...
                                    (1: userData.NrOfChannels, 1:size1) = ...
                                    userData.appendBuffer.data...
                                    (1: userData.NrOfChannels,:);
                            end
                            userData.sample(elem) = size1+1;
                        end
                        
                        %----------------------------------
                        % load EEG-Data into the buffer
                        %----------------------------------
                        for i = 1:length(userData.flashArr{elem})
                            userData.runBuffer(userData.runArr(elem), ...
                                               userData.flashArr{elem}(i)). ...
                            data(1: userData.NrOfChannels, ...
                                 userData.sample(elem))...
                                = u(1:userData.NrOfChannels)';
                        end
                        userData.sample(elem) = userData.sample(elem)+1;
                    end

%%          
                    if t > userData.tStart(elem)+tLoadBuf
                        %----------------------------------
                        % call the baseCorr function
                        %----------------------------------
                        baseCorr(userData.flashArr{elem},userData.runArr(elem));
                        
%%                        
                        userData.flashArr{elem} = [];   %delete the appropriate cell
                        
                        %-----------------------------------------
                        % wait until all Buffers are filled ready
                        %-----------------------------------------
                        if userData.k == userData.numFlashes && userData.runnumber == userData.runmax
                            userData.loadBuffReady = true;
                            for i = 1:numel(userData.flashArr)
                                if ~isempty(userData.flashArr{i})
                                    userData.loadBuffReady = false;  
                                    break;
                                end
                            end
                            if userData.loadBuffReady == true
                                userData.runnumber = userData.runnumber+1;
                            end
                        end
                        
                        userData.sample(elem) = 1;     %first sample
                        userData.newrun(elem) = true;  %load the new time into tStart
                    end
                end
            end
%% Analysis of the recorded data when every stimulus has been flashed
        else
            if userData.loadBuffReady == true    %is set if all buffers are filled ready

                % Moving average filter & downsampling of recorded data
                % without pre-stimulus-interval

                for ii=1:userData.runmax
                    for kk=1:userData.numFlashes
                        userData.averaged(ii,kk).data=...
                            filter(ones(1,userData.windowSize)/...
                            userData.windowSize,1,...
                            userData.runBuffer(ii,kk).data...
                            (:,userData.appendBuffer.size+1:...
                            userData.buffSize-1)');
                        
                        userData.downsampled(ii,kk).data=...
                            downsample(userData.averaged(ii,kk).data,...
                            userData.windowSize);
                        
                        for jj=1:userData.NrOfChannels
                            userData.Features(((ii-1)*userData.numFlashes)+kk,...
                                (((jj-1)*userData.downsampledTrials)+1):...
                                (((jj-1)*userData.downsampledTrials)+...
                                userData.downsampledTrials))=...
                                userData.downsampled(ii,kk).data(:,jj);
                        end
                    end
                end
                
%% LDA Analysis

                if userData.method == 1 && P300classifier.method == 1
                
                   [userData.Classes, userData.DiscriminantScore] =...
                        classify(P300classifier.F, userData.Features);
                    userData.DiscriminantScore
                    userData.Classes

                    userData.result=zeros(1,userData.numFlashes);

                    for ii=1:userData.runmax
                        for jj=1:userData.numFlashes
                            userData.result(jj)=userData.result(jj)+...
                                userData.DiscriminantScore((ii-1)*...
                                userData.numFlashes+jj,1);                        
                        end
                    end
                   
                    if userData.numFlashes == 12

                        userData.Col_Index=find(userData.result(1,1:6)==...
                            max(userData.result(1,1:6)));
                        userData.Row_Index=find(userData.result(1,7:12)==...
                            max(userData.result(1,7:12)))+6;

                        if length(userData.Col_Index)>1
                            userData.output(2)=99;
                        elseif length(userData.Row_Index)>1
                            userData.output(2)=99;
                        else
                            userData.output(2)=userData.Col_Index+...
                                ((userData.Row_Index-7)*6);
                        end
                       
                    elseif userData.numFlashes == 8
                        % Protection in the case when two directions have
                        % the same `result'
                        result = find(userData.result(1,:)== ...
                                      max(userData.result(1,:)));
                        disp(userData.result(1,:));
                        userData.output(2) = result(1);
                    end

                

%% SVM

                elseif userData.method == 2 && P300classifier.method == 2
 
                        X=normalizemeanstd(userData.Features);

                        [userData.DiscriminantScore] =...
                            svmval(X,P300classifier.xsup,P300classifier.w,...
                            P300classifier.b,P300classifier.kernel,...
                            P300classifier.kerneloption, P300classifier.span);

                        userData.result=zeros(1,userData.numFlashes);

                        for ii=1:userData.runmax
                            for jj=1:userData.numFlashes
                                userData.result(jj)=userData.result(jj)+...
                                    userData.DiscriminantScore((ii-1)*...
                                    userData.numFlashes+jj,1);                        
                            end
                        end
                   
                        if userData.numFlashes == 12

                            userData.Col_Index=find(userData.result(1,1:6)==...
                                max(userData.result(1,1:6)));
                            userData.Row_Index=find(userData.result(1,7:12)==...
                                max(userData.result(1,7:12)))+6;

                            if length(userData.Col_Index)>1
                                userData.output(2)=99;
                            elseif length(userData.Row_Index)>1
                                userData.output(2)=99;
                            else
                                userData.output(2)=userData.Col_Index+...
                                    ((userData.Row_Index-7)*6);
                            end
                       
                        elseif userData.numFlashes == 8
                            result = find(userData.result(1,:)== ...
                                          max(userData.result(1,:)));
                            if length(result) ~= 1
                                disp(userData.result(1,:));
                            end
                            userData.output(2) = result(1);
                        end
                    
                else
                    userData.output(2)=99;
                end
%% Initialization                             
                %--------------------------------
                %start new trial
                %--------------------------------
                userData.newtrial = true;
                userData.waitNextTrial = false;
                output = userData.output;
                %-----------------------------
                % call the newInit function
                %-----------------------------
                newInit(windTime);
                userData.run = true;
                userData.output = output;
            else
                userData.runnumber = userData.runnumber - 1;        % weil noch nicht alle Buffer fertig geladen sind
            end
        end
        sys=[];
      
%% Case 3        
    case 3  % Calculates the outputs of the S-function

        sys = userData.output;       %STOP + Solution ID
        userData.output = [0 0];

%% Case 0
    case 0  %Initialization

        sizes=simsizes;
        sizes.NumContStates  = 0;
        sizes.NumDiscStates  = 0;
        sizes.NumOutputs     = 2;
        sizes.NumInputs      = -1;   %dynamically sized
        sizes.DirFeedthrough = 0;    %has no direct feedthrough
        sizes.NumSampleTimes = 1;  
        
        sys=simsizes(sizes);        
        
        x0  = [];
        str = [];
        ts  = [-1 0];   % inherited sample time run at the same rate
                        % as the block to which it is connected
               
        %---------------------------------------
        % save the parameters also in userData
        %---------------------------------------
        userData.windTime = windTime;
        userData.runmax = runmax;    %maximum number of runs - character flashes
        userData.NrOfChannels = channels;
        userData.method = method;
                        
        %-----------------------------
        % call the newInit function
        %-----------------------------
        userData.appendBuffer = struct();   %clear the Buffer
        newInit(windTime);
        userData.appendBuffer.data = zeros(1,userData.appendBuffer.size);

end

%% baseCorr function
%===============================================
% baseCorr function
%   Baseline Correction: Correct for reference
%   interval from 1sample to 5samples
%-----------------------------------------------
function baseCorr(index, subtrial)
global userData

for i = 1:length(index)
    meanSamp = 0; 
    numCorrSamp = userData.appendBuffer.size-1;
    tmp=userData.runBuffer(subtrial, ...
        index(i)).data(1:userData.NrOfChannels, 1:numCorrSamp);
    meanSamp = mean(tmp');
    meanSamp = -(meanSamp');
    %----------------------------------------------------
    %add the average of the samples to the EEG-Buffer
    %----------------------------------------------------
    for k=1:userData.NrOfChannels
        userData.runBuffer(subtrial, ...
        index(i)).data(k,:)=...
        userData.runBuffer(subtrial,...
        index(i)).data(k,:)...
        + meanSamp(k,1);
    end
end



%% newInit function
%===============================================
% newInit function
%   Run this function when you start a new
%   'translation'
%-----------------------------------------------
function newInit(windTime)
global userData

%--------------------------------------------------------------------
% Create the 100ms buffer to buffer the last the 100ms of the EEG-data
% This buffer is used for calculating the BaseLine Correction!!
%--------------------------------------------------------------------
% userData.appendBuffer = struct();   %clear the Buffer
appendBuffTime = 0.1; % [s]
size = ceil((appendBuffTime)/(1/64));    %100ms angenommen (windTime*0.001)
%userData.appendBuffer.data = zeros(1,size);
userData.appendBuffer.size = size;

%--------------------------------------------------------------------
% Clear the buffers which save the BCI-signals
% Sample Time: 1/64 s
%--------------------------------------------------------------------
userData.runBuffer = struct();   %clear runBuffer structure
userData.averaged = struct();
userData.downsampled=struct();
userData.Features=[];
userData.buffSize = ceil((windTime*0.001)/(1/64))+1;    
                           % e.g. 800ms: 53 elements

%-------------------------------------------------------------
% Intialize counting variables, boolean variables and constants
%-------------------------------------------------------------
userData.i = 0;          %Counting variable - count which buffer has to be filled
userData.k = 0;          %Counting variable
userData.buffIndex = 1;  %Counting variable used for the 100ms-Buffer

numBuffpara = 18;    %How many Buffers have to be filled parallel

%holds the Flash Number of the parallel filled Buffers
userData.flashArr = cell(numBuffpara, 1);

userData.sample = ones(numBuffpara, 1); %count the samples
userData.newrun = ones(numBuffpara, 1);
userData.runnumber = 1;  %holds the number of the actual run

userData.newtrial = false;
userData.tLoadBuf = (windTime*0.001) - appendBuffTime;  %only the time after the Flash!
                                                        % analysis time window for P300 classification
userData.loadBuffReady = false;  %true if all buffers filled ready

userData.output = [0 0];     %output variables

userData.windowSize=3;
userData.downsampledTrials=ceil((userData.buffSize-...
    userData.appendBuffer.size)/userData.windowSize)-1;


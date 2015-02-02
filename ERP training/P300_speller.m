function [sys,x0,str,ts] = P300_speller(t,x,u,flag,mode,flashtime,darktime);
%
% Sabstitue letters with images;  Eight flasing fields;
% 
% Bernhard Großwindhager     HTL-Steyr
% Diplomarbeit
% Last Changes: 08-02-2007  final check
% Version: 5.0
%
% 1999-2006 g.tec medical engineering GmbH
%
% Modified by Yu Zhang, 2011.6, RIKEN
%

global fig handles

switch flag

    case 'New'        % The new Game Button was pressed
        %----------------------------------
        % call the newInit function
        %----------------------------------
        set(gcf,'UserData',handles);    %save the handles object in the figure's UserData
        newInit();
        handles = get(gcf,'UserData');    %load the changes of the newInit function
        %----------------------------------          !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        % activate the ID-INIT control line
        %Signal Processing Block has to
        %clear the Buffers and start a new
        %initialization.
        %----------------------------------
        handles.outputINIT = numel(handles.arrFlashIndex);
        
        set(handles.flashFields,'Visible','off');
        set(handles.flashImg, 'Visible', 'off');
        set(handles.startHndl,'Visible','on');  %show the Start Button

        if handles.mode==1      %Copy Spelling
            handles.copySpell = true;
        end
        set(gcf,'UserData',handles);   %save the changes
        return;     %stop this step
 
    case 'Start'
        handles.newtrial = true;
        handles.trialnumber = 1;    %holds the number of the actual trial
        handles.run = true;         %start the 'translation'
        handles.result = 1;
        
        %%--- target order ---%%
        if handles.mode == 1
            n_stimuli = 8;             % number of stimuli in one run
        elseif handles.mode == 2
            n_stimuli = 100;
        end
        midrand = [];
        for ii = 1:n_stimuli/8;
            midrand = [midrand randperm(8)];
        end
        midCopyText = 0;
        for ii = 1:length(midrand)
            midCopyText = midCopyText+midrand(end-ii+1)*10^(ii-1);
        end
        handles.target = int2str(midCopyText);        % random order of targets
        handles.targetorder = midrand;
        handles.trialmax = length(midrand);           % number of commands need to be implemented
        
        if handles.mode == 2
            handles.trialmax = inf;
        end
        
        handles.faceCounter = 1;
        
        set(handles.startHndl,'Visible','off'); %don't show the Start Button
        set(handles.flashFields,'Visible','off');
        set(handles.grayImg, 'Visible', 'on');
        
        set(gcf,'UserData',handles);    %save changes
        return;     %stop this step
        
    case 'Closefig'
        close(gcf);     %close figure window
        set_param('P300_directions/Directions Randomizer/StopSimu','Gain','1');   %stop the Simulink Simulation
        return;     %stop this step
        
    case 2      % Update of discrete states
%         if u(3)==0
%             handles.newtrial = true;
%         else
        if any(get(0,'Children')==fig)       % is fig a 'Child' of the root object?
            if strcmp(get(fig,'Name'),'BCI P300 Matrix Speller - Single Character Flash'),
                set(0,'currentfigure',fig);  % set fig to the current figure
                handles=get(gcf,'UserData'); % load the handles obejct from UserData
                
                stop = u(1);
                if stop ~= 0
                    handles.stop = stop;
                end
                
                if handles.run
                    if handles.newtrial           % true...the program has to wait
                        handles.newtrial = false; % before starting the next trial
                        handles.waitNextTrial = true;
                        handles.starttimeTrial = t;
                    end
                    if ~handles.waitNextTrial     % false...Trial not ready
                        tDarkLetter = handles.tDarkLetter;
                        tFlash = handles.tFlash;

                        if handles.showtarget && handles.targetoff == ~true     % now show target
                            set(handles.dirImg(handles.result),'Visible','off');
                            if handles.mode == 1
                                set(handles.targImg(handles.targetorder(handles.trialnumber)),'Visible','on');
                            else
                                set(handles.targImg(handles.targetorder(handles.trialnumber)),'Visible','off');
                            end
                            handles.targetonset = t;                            % the time point of showing target
                            handles.showtarget = false;
                            while handles.randarr(1) == handles.targetorder(handles.trialnumber)
                                handles.randarr = randperm(numel(handles.arrFlashIndex));
                            end
                        end
                        
                        if t > handles.targetonset + handles.targetontime       % after 1s target disappear
                            set(handles.targImg(handles.targetorder(handles.trialnumber)),'Visible','off');
                            handles.targetoff = true;
                        end
                        
                        if handles.newrun && handles.targetoff && handles.stop ~= true     % new trial
                            handles.newrun = false;                             % whether next stimulus flash
                            handles.starttime = t;                              % set the new starttime
                            handles.flashIndex = handles.randarr(handles.k);    % current flashed stimulus
                            handles.k = handles.k+1;
                        end
                        
                        if handles.targetoff
                            if handles.stop ~= true
                                if t > handles.starttime
                                    if handles.draw                     % highlight the object, but only once
                                        %-----------------------------------
                                        % call the setClearTrigger function
                                        %-----------------------------------
                                        set(gcf,'UserData',handles);             % save the handles object
                                        setClearTrigger(handles.flashIndex);     % set Trigger   !!!!!!!!
                                        handles = get(gcf,'UserData');           % load the changes of the function
                                        handles.statTrigger = true;
                                        
                                        %%% highlight the current stimulus
                                        if strcmp(handles.type,'arrow')
                                            set(handles.flashImg(handles.flashIndex), 'Visible','on');
                                        else
                                            set(handles.flashImg(handles.flashIndex, ...
                                                                 handles.faceCounter), ...
                                                'Visible','on');
                                        end
                                        
                                        handles.outputID = handles.flashIndex;
                                        
                                        % Increment the `faceCounter'
                                        % variable or reset it to zero
                                        handles.faceCounter = ...
                                            handles.faceCounter + 1;
                                        if handles.faceCounter > size(handles.flashImg,2)
                                            handles.faceCounter = 1;
                                        end

                                        drawnow;

                                        handles.draw = false;

                                    elseif handles.statTrigger
                                        %-----------------------------------
                                        % call the setClearTrigger function
                                        %-----------------------------------
                                        set(gcf,'UserData',handles);  % save the handles object
                                        setClearTrigger(0);     % clear Trigger    !!!!!!
                                        handles.statTrigger = false;
                                    end
                                end
                            else
                                handles.newrun = false;
                            end

                            if t > (handles.starttime + tFlash)  % clear the FlashFields
                                if handles.clear
                                    set(handles.flashImg, 'Visible','off');
                                    drawnow;
                                    handles.clear = false;
                                    
                                    if handles.k > numel(handles.arrFlashIndex)
                                        lastelement(1) = handles.randarr(numel(handles.arrFlashIndex));
                                        lastelement(2) = handles.randarr(numel(handles.arrFlashIndex)-1);
                                        handles.randarr(1) = lastelement(1);
                                        %-------------------------
                                        % random Flash order
                                        %-------------------------
                                        % keep the first stimulus of next flash block is different
                                        % from the final two stimuli of the last flash block
                                        while(handles.randarr(1) == lastelement(1) ...
                                              || handles.randarr(1) == lastelement(2))
                                            handles.randarr = randperm(numel(handles.arrFlashIndex));
                                        end
                                        handles.runnumber = handles.runnumber+1;        % number of trials used for P300 classification
                                        handles.k = 1;
                                    end
                                end
                            end


                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % The next letter will FLASH
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            if t > (handles.starttime + tFlash + tDarkLetter)  % the next Letter will
                                                                               % flash on the screen
                                handles.draw=true;
                                handles.clear=true;
                                handles.newrun=true;    %load the new time into handles.starttime
                            end

                            if handles.stop == true
                                handles.newrun = false;

                                solIndex = u(2);            % output of the classfier

                                if solIndex ~= 0
                                    if mode == 2 && solIndex ~= 99      % Free Spelling
                                        set(handles.dirImg(:),...
                                            'Visible', 'off');
                                        set(handles.dirImg(solIndex),...
                                            'Visible', 'on');
                                        handles.result = solIndex;
                                    end
                                    
                                    % Add the command what you want to do here
                                    
                                    if mode == 1       %Copy Spelling
                                        if solIndex == 99
                                            newLetter ='@';
                                        else
                                            newLetter = get(handles.flashFields(solIndex),'String');
                                            set(handles.dirImg(solIndex),'Visible','on');
                                            handles.result = solIndex;
                                        end
                                        
                                        if strcmp(newLetter,handles.target(handles.trialnumber))
                                            handles.correctTrials = handles.correctTrials + 1;
                                        else
                                            handles.wrongTrials = handles.wrongTrials + 1;
                                        end
                                    end
                                    if handles.trialnumber == handles.trialmax  % all commands were implemented
                                        handles.run = false;     %stop the 'translation'
                                        if mode == 1
                                            accuracy = (handles.correctTrials/handles.trialmax)*100
                                        end
                                    end
                                    %--------------------------------
                                    % start new trial
                                    %--------------------------------
                                    handles.stop = false;
                                    handles.newtrial = true;
                                    handles.trialnumber = handles.trialnumber+1;    % number of commands have been implemented
                                end                      
                            end
                        end
                    else
                        if t>handles.starttimeTrial+handles.trialwaitTime+handles.trialwaitTime2
                            handles.waitNextTrial = false;
                            trialmax = handles.trialmax;
                            targetorder = handles.target;
                            correctTrials = handles.correctTrials;
                            wrongTrials = handles.wrongTrials;
                            %-----------------------------
                            % call the newInit function
                            %-----------------------------
                            set(gcf,'UserData',handles);  %save the handles object
                            newInit();
                            handles = get(gcf,'UserData');  %load the changes of the function
                            %----------------------------------
                            %activate the ID-INIT control line
                            % Signal Processing Block has to         !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                            % clear the Buffers and start a new
                            % initialization.
                            %----------------------------------
                            handles.outputINIT = numel(handles.arrFlashIndex);
                            
                            handles.run = true;
                            handles.trialmax = trialmax;
                            handles.target = targetorder;
                            handles.correctTrials = correctTrials;
                            handles.wrongTrials = wrongTrials;
                        end
                    end
                end
                set(gcf,'UserData',handles);     %save changes to UserData of the current figure
            end
        end
%         end
        sys=[];

    case 3  % Calculates the outputs of the S-function
        if any(get(0,'Children')==fig)   %if the figure still exists for example when the
                                         %close button was already pressed.
            handles=get(gcf,'UserData'); %load the handles obejct from UserData
            sys(1) = handles.outputINIT;        %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            sys(2) = handles.outputID;
            sys(3) = handles.outputSTIMULUSCODE;
            sys(4) = handles.outputTARGET;
            handles.outputID = 0;     %only for one sample
            handles.outputINIT = 0;
            handles.outputSTIMULUSCODE = 0;
            handles.outputTARGET = 0;
            set(gcf,'UserData',handles); %save the handles object in the figure's UserData
        end
            
    case 0  %Initialization
        %------------------------------------
        % clear the handles object and close
        % the old figure if it is still open
        %------------------------------------
        clear handles;
        h=findobj('Name','BCI P300 Matrix Speller - Single Character Flash');
        close(h);
        %------------------------------------
        % initialize the Figure
        %------------------------------------
        figure('Name','BCI P300 Matrix Speller - Single Character Flash', ...
            'NumberTitle','off');
        [flag,fig] = figflag('BCI P300 Matrix Speller - Single Character Flash');
        set(fig,'Visible','on', ...
            'NumberTitle','off');
        pos=get(0,'ScreenSize');    %Get the size of the screen
        pos=pos-[0 0 0 40];         %don't use the total sreen              !!!!!!!!!!!!!!!!!!
        set(fig, ...
            'Position',pos, ...
            'MenuBar','none', ...
            'Units','normalized');
        set (fig, 'Color', [0 0 0]);
        movegui(fig,'center');      %Move GUI figure to specified part of screen
        axesHndl = axes('Position',[0 0 1 1]);
        axis([-1 1 -1 1]);        %sets scaling for the x- and y-axes on the current plot
        axis('off');                %turns off all axis labeling
        hold on;                    %holds the current plot and all axis properties so that
                                    %subsequent graphing commands add to the
                                    %existing graph

        sizes=simsizes;             %SIMSIZES...utility used to set S-function sizes
                                    %For example:
                                    %sizes = simsizes;
                                    %This returns an uninitialized structure of the form:
                                    %sizes.NumContStates   Number of continuous states
                                    %sizes.NumDiscStates   Number of discrete states
                                    %sizes.NumOutputs      Number of outputs
                                    %sizes.NumInputs       Number of inputs
                                    %sizes.DirFeedthrough  Flag for direct feedthrough
                                    %sizes.NumSampleTimes  Number of sample times
        sizes.NumContStates  = 0;
        sizes.NumDiscStates  = 0;
        sizes.NumOutputs     = 4;
        sizes.NumInputs      = -1;
        sizes.DirFeedthrough = 0;   %has direct feedthrough
        sizes.NumSampleTimes = 1;  

        sys=simsizes(sizes);     %After initializing the structure above to fit the
                                 %specifications of the S-function, SIMSIZES should be called
                                 %again to convert the structure into a vector that can be 
                                 %processed by Simulink. For example:
                                 %    sys = simsizes(sizes);
        x0  = [];
        str = [];
        ts  = [-1 0];    %inherited sample time run at the same rate
                         %as the block to which it is connected

        numrows = 1;     %how many Rows and Columns should have the Field
        numcols = 8;
        handles.numrows = numrows;
        handles.numcols = numcols;

        FWIDTH = 0.09;    %Width of one Field
        FHEIGHT = 0.11;    %Height of one Field

        xoffset = ((0.80)/2) - (numcols/2)*FWIDTH;  %x-beginning of the field
                                                        
        yoffset = (0.47) + (numrows/2)*FWIDTH;    %y-beginning of the field

        flashMatrix = cell(numrows, numcols);   %cell array which holds the
                                                %Letters or words
        flashMatrix = {'1','2','3','4','5','6','7','8'};

        
        %-----------------------------------------
        % define colors
        %-----------------------------------------
        handles.darkColor = (40/255)*[1 1 1];
        handles.backTextCol = (192/255)*[1 1 1];
        
        % Matrix of possible Flash outputs
        handles.arrFlashIndex = [1:8];

        fontSize = 0.35;
        k = 1;
        i = 0;
        %-----------------------------------------------
        %The Textfields with the Letters or the words
        %  These Fields will flash on the screen
        %-----------------------------------------------
        % top -- left
        
        for m = 1:numrows
            for n = 1:numcols
                i=i+1;
                if ~isempty(flashMatrix{m,n})  %is the matrix not empty --> create a flash Field
                    handles.flashFields(k) = uicontrol('Style','text', ...
                        'Units','normalized', ...
                        'FontUnits','normalized', ...
                        'FontSize',fontSize, ...
                        'FontWeight','bold', ...
                        'BackgroundColor','black', ...
                        'ForegroundColor', handles.darkColor, ...     %!!!!!!!
                        'String',flashMatrix{m,n}, ...
                        'Visible','off');
                    
                    handles.arrFlashIndex(k) = k;
                    k = k+1;
                end
            end
        end
        
        
        %-----------------------------------------------
        % load images and place them on the positions
        %-----------------------------------------------
        % load arrow background
        imgN = imread ('Pic\gr2', 'png');
        imgE = imread ('Pic\gr4', 'png');
        imgW = imread ('Pic\gr8', 'png');
        imgS = imread ('Pic\gr6', 'png');
        imgNE = imread ('Pic\gr3', 'png');
        imgNW = imread ('Pic\gr1', 'png');
        imgSE = imread ('Pic\gr5', 'png');
        imgSW = imread ('Pic\gr7', 'png');
        
        % load output
        dir1 = imread('Pic\or1', 'png');
        dir2 = imread('Pic\or2', 'png');
        dir3 = imread('Pic\or3', 'png');
        dir4 = imread('Pic\or4', 'png');
        dir5 = imread('Pic\or5', 'png');
        dir6 = imread('Pic\or6', 'png');
        dir7 = imread('Pic\or7', 'png');
        dir8 = imread('Pic\or8', 'png');
        dirs = {dir1 dir2 dir3 dir4 dir5 dir6 dir7 dir8};           % arrows output
        
        % load target
        targ1 = imread('Pic\or1','png');
        targ2 = imread('Pic\or2','png');
        targ3 = imread('Pic\or3','png');
        targ4 = imread('Pic\or4','png');
        targ5 = imread('Pic\or5','png');
        targ6 = imread('Pic\or6','png');
        targ7 = imread('Pic\or7','png');
        targ8 = imread('Pic\or8','png');
        targ  = {targ1 targ2 targ3 targ4 targ5 targ6 targ7 targ8};  % target arrows
        
        % load stimuli
        handles.type = 'invface';       % 'arrow' or 'invface'
        switch handles.type
            case 'arrow'
                arst1 = imread('Pic\wr1','png');
                arst2 = imread('Pic\wr2','png');
                arst3 = imread('Pic\wr3','png');
                arst4 = imread('Pic\wr4','png');
                arst5 = imread('Pic\wr5','png');
                arst6 = imread('Pic\wr6','png');
                arst7 = imread('Pic\wr7','png');
                arst8 = imread('Pic\wr8','png');
                arst  = {arst1 arst2 arst3 arst4 arst5 arst6 arst7 arst8};  % stimuli arrows
            case 'invface'
                numberOfFaces = 4;
                for ii = 1:numberOfFaces
                    stiImg{ii} = imread(strcat('Pic\face',int2str(ii),'_inverse'), 'jpg');
                end
        end
        
        imgWidth = 0.25;                % 3
        imgHeight = 0.3067;             % 4
        
        xOffset = -0.9;
        yOffset = 0.5;
        
        % Position vectors for flashing fields
        currentImg{1} = imgNW;
        xPosition(1 ) = xOffset;
        yPosition(1 ) = yOffset;
        
        currentImg{2} = imgN;
        xPosition(2 ) = xOffset + 2*imgWidth;
        yPosition(2 ) = yOffset;
        
        currentImg{3} = imgNE;
        xPosition(3 ) = xOffset + 4*imgWidth;
        yPosition(3 ) = yOffset;
        
        currentImg{4} = imgE;
        xPosition(4 ) = xOffset + 4*imgWidth;
        yPosition(4 ) = yOffset - 2*imgHeight;
        
        currentImg{5} = imgSE;
        xPosition(5 ) = xOffset + 4*imgWidth;
        yPosition(5 ) = yOffset - 4*imgHeight;
        
        currentImg{6} = imgS;
        xPosition(6 ) = xOffset + 2*imgWidth;
        yPosition(6 ) = yOffset - 4*imgHeight;
        
        currentImg{7} = imgSW;
        xPosition(7 ) = xOffset;
        yPosition(7 ) = yOffset - 4*imgHeight;
        
        currentImg{8} = imgW;
        xPosition(8 ) = xOffset;
        yPosition(8 ) = yOffset - 2*imgHeight;
        
        % Place the arrows background over the draing area (fig)
        for ii = 1:numel(handles.arrFlashIndex)
            handles.grayImg(ii) = ...
                image (currentImg{ii}, ...
                       'XData', [xPosition(ii)   xPosition(ii)+imgWidth], ...
                       'YData', [yPosition(ii)+imgHeight   yPosition(ii)], ...
                       'Visible', 'on');
        end
        
        % Place the target arrows over the draing area (fig)
        for ii = 1:numel(handles.arrFlashIndex)
            handles.targImg(ii) = ...
                image (targ{ii}, ...
                       'XData', [xOffset+2*imgWidth   xOffset+3*imgWidth], ...
                       'YData', [yOffset-1*imgHeight  yOffset-2*imgHeight], ...
                       'Visible', 'off');
        end
        
        % Place the output arrows over the draing area (fig)
        for ii = 1:numel(handles.arrFlashIndex)
            handles.dirImg(ii) = ...
                image (dirs{ii}, ...
                       'XData', [xPosition(ii)   xPosition(ii)+imgWidth], ...
                       'YData', [yPosition(ii)+imgHeight   yPosition(ii)], ...
                       'Visible', 'off');
        end
        
        % Place the stimuli onto the figure.
        if strcmp(handles.type,'arrow')
            for ii = 1:numel(handles.arrFlashIndex)
                handles.flashImg(ii) = ...
                    image (arst{ii}, ...
                           'XData', [xPosition(ii)   xPosition(ii)+imgWidth], ...
                           'YData', [yPosition(ii)+imgHeight   yPosition(ii)], ...
                           'Visible', 'off');
            end
        else
            for face = 1:numberOfFaces
                for pos = 1:numel(handles.arrFlashIndex)
                    handles.flashImg(pos,face) = ...
                        image (stiImg{face}, ...
                               'XData', [xPosition(pos)   xPosition(pos)+imgWidth], ...
                               'YData', [yPosition(pos)+imgHeight   yPosition(pos)], ...
                               'Visible', 'on');
                end
            end
        end
 
        %-----------------------------
        % save the parameters also in
        % the handles structure
        %-----------------------------
        handles.mode = mode;
        handles.flashtime = flashtime/1000;
        handles.darktime = darktime/1000;
        
        
        %-----------------------------
        % call the newInit function
        %-----------------------------
        set(gcf,'UserData',handles);    %save the handles object in the figure's UserData
        newInit();
        handles = get(gcf,'UserData');    %load the changes of the newInit function
        
        if mode == 1    %Copy Spelling
            handles.copySpell = true;
        else
            handles.copySpell = false;
        end
        
        
        %======================================================================
        % Buttons
        %======================================================================
        % Information for all buttons
        yInitPos=0.90;
        top=0.95;
        left=0.80;
        bottom=0.05;
        btnWidth=0.15;
        btnHeight=0.10;
        % Space between the button and the next command's label
        space=0.04;
        %====================================
        % create the UIPANEL
        panBorder=0.02;
        yPos=0.05-panBorder;
        panPos=[left-panBorder yPos btnWidth+2*panBorder 0.9+2*panBorder];
        handles.uipan = uipanel( ...
            'Parent',fig, ... 
            'Units','normalized', ... 
            'Position',panPos, ...
            'BackgroundColor',[0.50 0.50 0.50], ...
            'Visible','on');

        %====================================
        % The START Button
        if mode == 1    %CopySpelling
            yPos = 0.56;
        else
            yPos = 0.6;
        end
        xPos = 0.29;
        labelStr = 'START';
        callbackStr='P300_speller([],[],[],''Start'',[])';
        
        %Generic Button Information
        btnPos=[xPos yPos-btnHeight btnWidth btnHeight];  %[left bottom width height]
        handles.startHndl = uicontrol( ...
            'Style','pushbutton', ...
            'FontUnits','normalized', ...
            'FontSize',0.2, ...
            'FontWeight','bold', ...
            'Units','normalized', ...
            'Position',btnPos, ...
            'String',labelStr, ...
            'TooltipString','Starts the Translation', ...
            'Callback',callbackStr );
        
        %====================================
        % The NEW GAME button
        btnNumber=1;
        yPos=top-(btnNumber-1)*(btnHeight+space);
        labelStr='New Run';
        callbackStr='P300_speller([],[],[],''New'',[])';

        % Generic button information
        btnPos=[left yPos-btnHeight btnWidth btnHeight];  %[left bottom width height]
        uicontrol( ...
            'Style','pushbutton', ...
            'Units','normalized', ...
            'Position',btnPos, ...
            'String',labelStr, ...
            'TooltipString','Starts a new Translation', ...
            'Callback',callbackStr );
        
        %====================================
        % The CLOSE button
        labelStr='Close';
        callbackStr='P300_speller([],[],[],''Closefig'',[])';
        uicontrol( ...
            'Style','pushbutton', ...
            'Parent', fig, ...
            'Units','normalized', ...
            'Position',[left bottom btnWidth btnHeight], ...
            'String',labelStr, ...
            'TooltipString','Closes the P300 Speller Window', ...
            'Callback',callbackStr);        
        %====================================
       
        set(0,'currentfigure',fig);     %after drawing in the other axes set
                                        %fig as the current figure
        set(gcf,'UserData',handles);    %save changes into UserData of the curr. figure

    case 9          %End of simulation tasks
        h=findobj('Name','BCI P300 Matrix Speller - Single Character Flash');
        close(h);
end


%% newInit function
%============================================
% newInit function
%   Run this function when you start a new
%   'translation'
%--------------------------------------------
function newInit()
handles = get(gcf,'UserData');    %load handles structure from UserData

%----------------------
%random Flash order
%----------------------
handles.randarr = randperm(numel(handles.arrFlashIndex));
                      %random permutation of the integers from 1 to n
%-------------------------------------------------------------
%set colors of uicontrols
%-------------------------------------------------------------
set(handles.flashFields,'ForegroundColor', handles.darkColor); %!!!!!!

set (handles.flashImg, 'Visible', 'off');

%-------------------------------------------------------------
%Intialize counting variables, boolean variables and constants
%-------------------------------------------------------------
handles.run = false;    %with the Start Button you can start the 'translation'
handles.stop = false;   %when the Signal Processing Block sends the STOP-Bit
                        %this variable will be set.
handles.flashIndex = 0; %the number of the currently flashing FlashField
handles.k = 1;          %Counting variable

handles.statTrigger = false;    %true if the Trigger should be set
handles.draw = true;    %true if a Field could flash
handles.clear = true;   %true if a Field could be cleared

handles.newrun = true;  %new run will start
handles.runnumber = 1;  %holds the number of the actual run

handles.targetoff = false;
handles.showtarget = true;      % whether show target
handles.targetontime = 1.5;       % show the target 1s
handles.waitNextTrial = false;
handles.newtrial = false;
handles.trialwaitTime = 1;  %[s] time before the next trial starts
handles.trialwaitTime2 = 0;
handles.correctTrials = 0;  %holds the number of correct Trials
handles.wrongTrials = 0;    %holds the number of wrong Trials

%hold the output variable (sys)
handles.outputID = 0;                   %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
handles.outputINIT = 0;                 %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
handles.outputTARGET = 0;
handles.outputSTIMULUSCODE = 0;

handles.tDarkLetter = floor(handles.darktime/(1/64))*(1/64);  %the time how long no letter
                                                                %should flash on the screen
handles.tFlash = floor(handles.flashtime/(1/64))*(1/64);   %the FlashTime


set(gcf,'UserData',handles);    %to save the changes of the newInit function



%% setClearTrigger function
%============================================
% setClearTrigger function
%--------------------------------------------
function setClearTrigger(flashnum) %flashnum...handles.flashIndex   !!!!!!!!
handles = get(gcf,'UserData');   %load handles structure from UserData

if flashnum ~= 0
    %-------------------------------------------------
    % set Trigger(Gain2), if the letter,on which you
    % have to look, flashes on the screen.
    %-------------------------------------------------
    if handles.mode == 1    %CopySpelling
        flashLetter = get(handles.flashFields(flashnum), 'String');
        if strcmp(flashLetter,handles.target(handles.trialnumber))
            handles.outputTARGET=1;
        end
    end
else
    handles.outputTARGET=0;  %clear Trigger
end

handles.outputSTIMULUSCODE=flashnum;

set(gcf,'UserData',handles);    %to save the changes of the setTrigger function




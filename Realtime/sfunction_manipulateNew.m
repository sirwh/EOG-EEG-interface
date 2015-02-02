%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: The s-function to control robots (Kobuki) in real time (by EOG command).
% It also provides a visual output in the "display" block, and a file output of Data.txt. 
%--------------------------------------------------------------------------------------------------------------------------------
% Used in: P300_directions.slx
%--------------------------------------------------------------------------------------------------------------------------------
% Update : 2015/02/02 by Jiaxin MA @Kyoto Univ.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sys,x0,str,ts] = sfunction_manipulateNew(t,x,u,flag)

DelayBegin=20;
fs=32;

if flag==0
    
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 2;
    sizes.NumOutputs     = 0;  % dynamically sized
    sizes.NumInputs      = -1;  % dynamically sized
    sizes.DirFeedthrough = 0;   % has direct feedthrough
    sizes.NumSampleTimes = 1;
    
    sys = simsizes(sizes);
    str = [];
    x0  = [0 0];   % [delay current_state]
    ts  = [-1 0];   % inherited sample time
    
elseif flag==2
    if t < DelayBegin,return,end
    if x(1) > 0 && u<=x(2) %if u>x(2), it means a higher priority movement is detected
        x(1)=x(1)-1;
        sys=[x(1) x(2)];
    else
        sys=[0 x(2)];
        if x(2) ~= 20 %EOG MODE 
            if u == 2 && x(2)~=2 %double blink -- stop  
                %Note that x(2)~=2 prevent multiple 'stop' in Data.txt, but also prevent the robot making 'stop -- stop'.
                %This will affect something like 'left--left' if one 'left' is a certain angle. 
                fid=fopen('Data.txt','a'); fprintf(fid,'%f stop\n',t); fclose(fid);
                set_param('P300_directions/Display','BackgroundColor','[1 1 0]','MaskDisplay', ['disp(' char(39) 'D blink' char(39) ');'])
                set_param('P300_directions/robot','mv','stop','mw','stop');
                sys = [fs*0 2];
            elseif u == 3 && x(2)~=3 %triple blink -- forward
                fid=fopen('Data.txt','a'); fprintf(fid,'%f forward\n',t); fclose(fid);
                set_param('P300_directions/Display','BackgroundColor','[1 1 0]','MaskDisplay', ['disp(' char(39) 'T blink' char(39) ');'])
                set_param('P300_directions/robot','mv','forward','mw','stop');
                sys = [fs*1 3]; 
            elseif u == 11 && x(2)~=11 %left gaze
                set_param('P300_directions/Display','BackgroundColor','[1 1 0]','MaskDisplay', ['disp(' char(39) 'L gaze' char(39) ');'])
                sys = [fs*1.5 11];
            elseif u == 12 && x(2)~=12 %right gaze
                set_param('P300_directions/Display','BackgroundColor','[1 1 0]','MaskDisplay', ['disp(' char(39) 'R gaze' char(39) ');'])
                sys = [fs*1.5 12];
            elseif u == 31 && x(2)~=31 %left wink -- turn left
                fid=fopen('Data.txt','a'); fprintf(fid,'%f left turn\n',t); fclose(fid);
                set_param('P300_directions/Display','BackgroundColor','[1 1 0]','MaskDisplay', ['disp(' char(39) 'L wink' char(39) ');'])
                set_param('P300_directions/robot','mv','stop','mw','left');
                sys = [fs*1.5 31];
            elseif u == 32 && x(2)~=32 %right wink -- turn right
                fid=fopen('Data.txt','a'); fprintf(fid,'%f right turn\n',t); fclose(fid);
                set_param('P300_directions/Display','BackgroundColor','[1 1 0]','MaskDisplay', ['disp(' char(39) 'R wink' char(39) ');'])
                set_param('P300_directions/robot','mv','stop','mw','right');
                sys = [fs*1.5 32];
            elseif u == 20 %frown -- P300mode
                fid=fopen('Data.txt','a'); fprintf(fid,'%f P300 mode\n',t); fclose(fid);
                set_param('P300_directions/Display','BackgroundColor','[0 1 0]','MaskDisplay', ['disp(' char(39) 'P300 mode' char(39) ');'])
                set_param('P300_directions/robot','mv','stop','mw','stop');
                set_param('P300_directions/Directions Randomizer/Switch','Gain','1');                
                sys = [fs*1.5 20];
            end
        elseif x(2) == 20
            if u == 32 %right wink -- cancel
                set_param('P300_directions/Display','BackgroundColor','[0 1 0]','MaskDisplay', ['disp(' char(39) 'EOG label' char(39) ');'])
                set_param('P300_directions/Directions Randomizer/Switch','Gain','2');
                sys = [fs*1 20]; %the mode should not be changed
            elseif u == 20 %frown -- EOGmode
                fid=fopen('Data.txt','a'); fprintf(fid,'%f EOG mode\n',t); fclose(fid);
                set_param('P300_directions/Display','BackgroundColor','[1 1 0]','MaskDisplay', ['disp(' char(39) 'EOG mode' char(39) ');'])
                set_param('P300_directions/Directions Randomizer/Switch','Gain','0');
                sys = [fs*2 21];
            end
        end
    end
    
end



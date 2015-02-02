%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: This s-function provides an interface for calibration when running the simulink model
%--------------------------------------------------------------------------------------------------------------------------------
% Used in: EOG_BCI2.mdl
%--------------------------------------------------------------------------------------------------------------------------------
% Update : 2015/2/1 by Jiaxin MA @Kyoto Univ.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sys,x0,str,ts] = sfunction_EOGparadigm2(t,x,u,flag,dofrown,doblink,dowink,dogaze,iteration)
% new paradigm designed for more complex eye movement
% delay 5s
% --trail begin----
% 0s show 'ready'
% 1s show movement category
% 4s erase movement category
% 5s end trail
% --trail end------

DelayBegin=20; % can be modified

if flag==0
    handles.pfeilrichtung=[]; % different eye movements to be executed
    if dofrown==1
        handles.pfeilrichtung=[handles.pfeilrichtung 0*ones(1,iteration)];
    end
    if doblink ==1
        handles.pfeilrichtung=[handles.pfeilrichtung 1*ones(1,iteration)];
    end
    if dowink ==1
        handles.pfeilrichtung=[handles.pfeilrichtung 2*ones(1,iteration) 3*ones(1,iteration)];
    end
    if dogaze ==1
        handles.pfeilrichtung=[handles.pfeilrichtung 4*ones(1,iteration) 5*ones(1,iteration)];
    end
    
    % set_param('EOG_BCI2/To File','Filename',filename);
    
    %initialize the figure for use with this simulation
    figure('Name','BCI Paradigm');
    axis([-1 1 -1 1]);
    axis('off');
    hold on;
    
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    sizes.NumOutputs     = 0; 
    sizes.NumInputs      = -1;  % dynamically sized
    sizes.DirFeedthrough = 0;
    sizes.NumSampleTimes = 1;
    
    sys = simsizes(sizes);
    str = [];
    x0  = [];
    ts  = [-1 0];   % inherited sample time
    
    handles.text1=text(0,0, 'ready', 'FontSize',30, 'HorizontalAlignment','center', 'Visible','off', 'EraseMode','Background', 'Color','r');
    handles.text2=text(0,0, 'relax', 'FontSize',30, 'HorizontalAlignment','center', 'Visible','off', 'EraseMode','Background');
    handles.text3=text(0,0, 'frown', 'FontSize',30, 'HorizontalAlignment','center', 'Visible','off', 'EraseMode','Background', 'Color','r');
    handles.text4=text(0,0, 'triple blink', 'FontSize',30, 'HorizontalAlignment','center', 'Visible','off', 'EraseMode','Background', 'Color','r');
    handles.text5=text(0,0, 'left wink', 'FontSize',30, 'HorizontalAlignment','center', 'Visible','off', 'EraseMode','Background', 'Color','r');
    handles.text6=text(0,0, 'right wink', 'FontSize',30, 'HorizontalAlignment','center', 'Visible','off', 'EraseMode','Background', 'Color','r');
    handles.text7=text(0,0, 'gaze left', 'FontSize',30, 'HorizontalAlignment','center', 'Visible','off', 'EraseMode','Background', 'Color','r');
    handles.text8=text(0,0, 'gaze right', 'FontSize',30, 'HorizontalAlignment','center', 'Visible','off', 'EraseMode','Background', 'Color','r');
    handles.text9=text(0,0, 'gaze up', 'FontSize',30, 'HorizontalAlignment','center', 'Visible','off', 'EraseMode','Background', 'Color','r');
    handles.text10=text(0,0, 'gaze down', 'FontSize',30, 'HorizontalAlignment','center', 'Visible','off', 'EraseMode','Background', 'Color','r');
    
    handles.text11=text(0,-0.5, 'detected: double blink', 'FontSize',20, 'HorizontalAlignment','center', 'Visible','off', 'EraseMode','Background', 'Color','r');
    handles.text12=text(0,-0.5, 'detected: triple blink', 'FontSize',20, 'HorizontalAlignment','center', 'Visible','off', 'EraseMode','Background', 'Color','r');
    handles.text13=text(0,-0.5, 'detected: left wink', 'FontSize',20, 'HorizontalAlignment','center', 'Visible','off', 'EraseMode','Background', 'Color','r');
    handles.text14=text(0,-0.5, 'detected: right wink', 'FontSize',20, 'HorizontalAlignment','center', 'Visible','off', 'EraseMode','Background', 'Color','r');
    
    handles.newtrial=1;
    handles.i=0;
    handles.part1=0;
    handles.part2=0;
    handles.part3=0;
    handles.part4=0;
    handles.part5=0;
    handles.part6=0;
    handles.rep=length(handles.pfeilrichtung);
    
    set_param('EOG_BCI2/Trigger/Gain','Gain','0');
    set(gca,'UserData',handles);
    
elseif flag==2
    
    if t < DelayBegin,return,end
    
    handles=get(gca,'UserData');
    
    if handles.rep~=0
        
        if handles.newtrial==1
            handles.i=handles.i+1;
            handles.starttime=t;
            handles.newtrial=0;
        end
        
        if (t>=handles.starttime)&&(handles.part1==0)
            % 0s, trigger on
            set_param('EOG_BCI2/Trigger/Gain','Gain','1');
            handles.part1=1;
        end;
        
        if (t>=handles.starttime+0.5)&&(handles.part4==0)
            % 0.5s, trigger off
            set_param('EOG_BCI2/Trigger/Gain','Gain','0');
            handles.part4=1;
        end;
        
        if (t>=handles.starttime)&&(handles.part5==0)
            % 0s, show 'ready'
            set(handles.text1, 'Visible','on');
            drawnow;
            handles.part5=1;
        end;
        
        if (t>=handles.starttime+1)&&(handles.part2==0)
            % 1s, show eye movement text
            for ii=1:10
                beep;
            end
            set(handles.text1, 'Visible','off');
            i=handles.i;
            if handles.pfeilrichtung(i)==0 %frown
                set(handles.text3,'Visible','on');
            elseif handles.pfeilrichtung(i)==1 %triple blink
                set(handles.text4,'Visible','on');
            elseif handles.pfeilrichtung(i)==2 % left wink
                set(handles.text5,'Visible','on');
            elseif handles.pfeilrichtung(i)==3 % right wink
                set(handles.text6,'Visible','on');
            elseif handles.pfeilrichtung(i)==4 %gaze left
                set(handles.text7,'Visible','on');
            elseif handles.pfeilrichtung(i)==5 % gaze right
                set(handles.text8,'Visible','on');
            elseif handles.pfeilrichtung(i)==6 % gaze up
                set(handles.text9,'Visible','on');
            elseif handles.pfeilrichtung(i)==7 % gaze down
                set(handles.text10,'Visible','on');
            end
            drawnow;
            handles.part2=1;
        end
        
        if (t>=handles.starttime+3)&&(handles.part3==0)
%             if paradigm==2
                if u == 2
                    set(handles.text11,'Visible','on');
                elseif u == 3
                    set(handles.text12,'Visible','on');
                elseif u == 4
                    set(handles.text13,'Visible','on');
                elseif u == 5
                    set(handles.text14,'Visible','on');
                end
                drawnow;
%             end
            
        end
        
        if (t>=handles.starttime+4)&&(handles.part6==0)
            % 4s, erase eye movement text, show 'relax'
%             if paradigm==2
                set(handles.text11,'Visible','off');
                set(handles.text12,'Visible','off');
                set(handles.text13,'Visible','off');
                set(handles.text14,'Visible','off');
%             end
            set(handles.text3,'Visible','off');
            set(handles.text4,'Visible','off');
            set(handles.text5,'Visible','off');
            set(handles.text6,'Visible','off');
            set(handles.text7,'Visible','off');
            set(handles.text8,'Visible','off');
            set(handles.text9,'Visible','off');
            set(handles.text10,'Visible','off');
            set(handles.text2,'Visible','on');
            handles.part3=1;
            handles.part6=1;
            
            drawnow;
            
        end;
        
        
        if (t>=handles.starttime+5)
            % 5s, erase 'relax'
            set(handles.text2, 'Visible','off');
            drawnow;
            handles.newtrial=1;
            handles.part1=0;
            handles.part2=0;
            handles.part3=0;
            handles.part4=0;
            handles.part5=0;
            handles.part6=0;
            handles.rep=handles.rep-1;
        end;
        
        set(gca,'UserData',handles);
    end
    sys=[];
    
elseif flag==9
    h=findobj('Name','BCI Paradigm');
    close(h);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: To get a certain-length interval (several seconds) from the EOG and differentiated EOG.
% The difference from getrecording.m is that the center of the interval is a local maximal value on differentiated EOG.
%--------------------------------------------------------------------------------------------------------------------------------
% Used in: matchingtrain.m, analyzetrain.m
%--------------------------------------------------------------------------------------------------------------------------------
% Update : 2014/12/26 by Jiaxin MA @Kyoto Univ.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [record difrecord] = getrecording2(data, trail, fs, dur)

d=round(fs*dur*0.5); 
record=zeros(trail,2*d+1);
difrecord=zeros(trail,2*d);
hp=zeros(1,trail);

figure;
subplot(2,1,1);plot(data);
hold on
subplot(2,1,2);plot(diff(data));
hold on

for i=1:trail
    head=fs*3*(i-1)+fs/4;
    tail=head+fs*2;
    [a, hp(i)]=max(diff(data(head:tail))); %this line is different from getrecording.m
    hp(i)=hp(i)+head-1;
    record(i,:)=data(hp(i)-d:hp(i)+d);
    record(i,:)=record(i,:)-record(i,1);
    difrecord(i,:)=diff(record(i,:));
    subplot(2,1,1);
    plot([hp(i)-d, hp(i)-d],[min(data),max(data)],'r');
    plot([hp(i)+d, hp(i)+d],[min(data),max(data)],'r');
    subplot(2,1,2);
    plot([hp(i)-d, hp(i)-d],[min(difrecord(i,:)),max(difrecord(i,:))],'r');
    plot([hp(i)+d, hp(i)+d],[min(difrecord(i,:)),max(difrecord(i,:))],'r');
end
hold off
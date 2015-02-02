%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: To plot the EOG data and its 1st order difference.
%--------------------------------------------------------------------------------------------------------------------------------
% Used in: matchingtrain.m, analyzetrain.m
%--------------------------------------------------------------------------------------------------------------------------------
% Update : 2014/12/26 by Jiaxin MA @Kyoto Univ.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function drawdata(data,trial,fs)

figure;
subplot(2,1,1); plot(data);
hold on
for i=1:trial-1
    x1=length(data)*i/trial;
    plot([x1,x1],[min(data),max(data)],'r');
end
axis([0 length(data) min(data) max(data)]);
set(gca,'XTick',0:fs:length(data));
set(gca,'XTickLabel',0:length(data)/fs);

ndata = diff(data);
subplot(2,1,2); plot(ndata);
hold on
for i=1:trial-1
    x1=length(data)*i/trial;
    plot([x1,x1],[min(ndata),max(ndata)],'r');
end
axis([0 length(data) min(ndata) max(ndata)]);
set(gca,'XTick',0:fs:length(data));
set(gca,'XTickLabel',0:length(data)/fs);

end
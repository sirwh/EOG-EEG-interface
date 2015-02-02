%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: To mark the detected gazes upon the EOG and differentiated EOG.
%--------------------------------------------------------------------------------------------------------------------------------
% Used in: analyzetrain.m
%--------------------------------------------------------------------------------------------------------------------------------
% Update : 2014/12/26 by Jiaxin MA @Kyoto Univ.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function drawblinkline3(data, result, Vcl)

figure;
subplot(2,1,1); plot(data);
hold on
for i=1:length(result) % before differentiating
    if result(i)>0
        plot([result(i),result(i)],[min(data),max(data)],'r');
    elseif result(i)<0
        plot([-result(i),-result(i)],[min(data),max(data)],'g');
    end
end

ndata = diff(data);
for i=1:length(ndata)
    if abs(ndata(i))<Vcl;
        ndata(i)=0;
    end
end

y=max(abs(ndata));
subplot(2,1,2); plot(ndata);
hold on
for i=1:length(result) % after differentiating
    if result(i)>0
        plot([result(i),result(i)],[-y,y],'r');
    elseif result(i)<0
        plot([-result(i),-result(i)],[-y,y],'g');
    end
end

hold off


% ndata2=ndata;
% for i=2:length(ndata)
%     ndata2(i)=ndata(i)+ndata2(i-1);
% end
% figure;
% plot(ndata2);
% y=max(abs(ndata));
% hold on
% for i=1:length(result)
%     if result(i)>0
%         plot([result(i),result(i)],[-y,y],'r');
%     elseif result(i)<0
%         plot([-result(i),-result(i)],[-y,y],'g');
%     end
% end
% hold off


end

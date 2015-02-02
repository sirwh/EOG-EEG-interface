%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: Do pattern matching. Use the standard pattern to match the data.
%--------------------------------------------------------------------------------------------------------------------------------
% Used in: matchingtrain.m
%--------------------------------------------------------------------------------------------------------------------------------
% Update : 2014/12/26 by Jiaxin MA @Kyoto Univ.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dis = checkmatching(sample, data, fs, alpha)
% alpha: a parameter related to the similarity threshold for the matching

threshold = alpha*min(sum((sample-max(sample)).^2),sum(sample.^2));
len=length(sample);
dis=zeros(1,length(data)-len+1);
for i=1:length(dis)
    cdata=data(i:i+len-1);
    cdata=cdata-cdata(1);
    dis(i) = sum((cdata-sample).^2);
    if dis(i)<threshold
        if corr(cdata', sample')>0.95 % check the correlation
            dis(i)=1;
        end
        if i-1~=0
            dis(i-1)=0;
        end
    else
        dis(i)=0;
    end
end

fdis = find(dis);
for i=length(fdis):-1:2
    if fdis(i)-fdis(i-1) < fs
        fdis(i)=0;
    end
end
fdis = fdis(find(fdis));

figure; plot(data); hold on  % draw the result of pattern matching
for i=1:length(fdis)
    plot([fdis(i), fdis(i)],[max(data),min(data)],'r');
    plot([fdis(i)+fs, fdis(i)+fs],[max(data),min(data)],'g');
end

end
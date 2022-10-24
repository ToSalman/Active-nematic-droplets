%% binning and getting the standard error 
Pq=[];
rad_max=max(Vr(:,1));
rad_min=min(Vr(:,1));
binsize=2;
count=0;
A=[];

for i=rad_min:binsize:rad_max
    
    I=find(Vr(:,1)>i & Vr(:,1)<(i+binsize));
    if length(I)==1
        count=count+1;
       % A(count,1:7)=Vr(I,:);
       A(count,1:2)=Vr(I,1:2);
        A(count,3)= sqrt(mean(Vr(I,3).*Vr(I,3))/length(I));
    end
%     if length(I)==0
%         A(count,1:4)=NaN;
%     end
    if length(I)>1
        count=count+1;
        %A(count,1:7)=mean(Vr(I,:));
        A(count,1:2)=mean(Vr(I,1:2));
        A(count,3)= sqrt(sum(std(Vr(I,2))^2)/length(I)); %(Vr(I,3).*Vr(I,3))+
    end
end
%%
%A=Ab69;
scatter(A(:,1), A(:,2),'filled')
hold on
errorbar(A(:,1), A(:,2), A(:,3), 'LineStyle','none','HandleVisibility','off');
xlabel('droplet diameter (um)')
% ylabel('d(grey value)/dt (hr^{-1})')
ylabel('Average flow speed (um/min)')
%ylabel('NADH fluorescence')
% xlabel('[K401] monomer (nM)')
set(findall(gcf,'-property','FontSize'),'FontSize',16)
%xlim([25 100])
box on

%Vr=[];
Ab=[];
X=x{1,1};
Y=y{1,1};
fu=v_smoothed{2,1};
cali=0.433; %caliberation
dt=30; %time interval in seconds
piv_win=0;
lc=5; %correlation length to eliminate noise from PIV
frames=length(u_original);
for k=1:length(centersNew)
    Co=centersNew(k,:);
    Ro=radiiNew(k,:);
    mask = createCirclesMask(I,Co,Ro-piv_win/2);
    [m, n]=size(fu);
    A=[];
    count=0;
    for ii=1:frames-lc       
        fv=v_smoothed{ii,1};
        fu=v_smoothed{ii,1};
        
        fvd=v_smoothed{ii,1};
        fud=v_smoothed{ii,1};
        
        for p=1:lc
            fv=v_smoothed{ii+p,1}+fv;
            fu=v_smoothed{ii+p,1}+fu;
        end
        
        count=0;
        v=velocity_magnitude{ii,1};
        %v=v_smoothed{ii,1};
        for i=1:m
            for j=1:n
            fu1(i,j)=fu(i,j)*mask(Y(i,j),X(i,j));
            fv1(i,j)=fv(i,j)*mask(Y(i,j),X(i,j));
            
            fvd(i,j)=fvd(i,j)*mask(Y(i,j),X(i,j));
            fud(i,j)=fud(i,j)*mask(Y(i,j),X(i,j));
            
            v_mag(i,j)=v(i,j)*mask(Y(i,j),X(i,j));
                if mask(Y(i,j),X(i,j))==1
                    count=1+count;
                end
            end
        end
        
        vxd=0;%sum(fv1,'all','omitnan')/(count);
        vyd=0;%sum(fu1,'all','omitnan')/(count);
        
        
        v1=sum(((fv1-vxd).^2+(fu1-vyd).^2).^0.5,'all', 'omitnan')/(lc*count);
        %v2=sum(v_mag,'all','omitnan')/count;
        %A(ii-1,1)=(ii-1);%*20/60;
        A(ii,1)=count;
        A(ii,2)=v1;
        A(ii,3)=vxd;
        A(ii,4)=vyd;
        
    end
    Ab(k,1)=2*Ro*cali;                  %Calibration of pixel size
    Ab(k,2)=mean(A(:,1));    
    Ab(k,3)=mean(A(:,2))*cali*60/dt;  %60/(time_intervel_in_sec)
    Ab(k,4)=std(A(:,2))*cali*60/dt;
    %scatter(Ab(:,1),Ab(:,2))
    %plot(Ab(:,1),Ab(:,2))
    %plot(A)

%      figure
%      imshow(I)
%      hold on
%      quiver(X,Y,fu1,fv1,1,'r')
%      hold off
    
end
Vr=[Ab;Vr];
scatter(Ab(:,1),Ab(:,3))
hold on
errorbar(Ab(:,1), Ab(:,3), Ab(:,4), 'LineStyle','none');
%%
xlabel('diameter (um)')
ylabel('average velocity (um/min)')
set(findall(gcf,'-property','FontSize'),'FontSize',16)
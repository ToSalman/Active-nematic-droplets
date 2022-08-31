%Vr=[];Gv=[];
%input required completePath,centers,radii,t1 (begining NADH image), t2 (end NADH image)
%return Slope_radius 1st column radius, 2nd column slope...




function slope_radius = NADH_slope(completePath,filteredCenters,filteredRadii,t1,t2)

%Ab(1:length(filteredRadii),1:3)=[];
Ab=[];
cali=0.65;   %0.217; %caliberation
dtN=8;      %in_minutes
centersNew=[filteredCenters filteredRadii];
dc=100; %dark-current


% myFolder = 'E:\Data\droplets_NADH_Fd\4_22_2022_4.95mM_NADH_fd_32_K15_frame_averaging\30X_b1_ham_200msExp_Frame_avg5_2\NADH_chan\active\20';
filePattern = fullfile(completePath, '*.tif'); % Change to whatever pattern you need.
theFiles = dir(filePattern);
G=[];
G1=[];

baseFileName = theFiles(t1).name;
fullFileName = fullfile(theFiles(t1).folder, baseFileName);
I= imread(fullFileName);

for k=1:length(centersNew)
    Co=centersNew(k,1:2);
    Ro=centersNew(k,3);
    mask = createCirclesMask(I,Co,Ro);
    N = nnz( mask );
        
    for ik = t1 : t2
        baseFileName = theFiles(ik).name;
        fullFileName = fullfile(theFiles(ik).folder, baseFileName);
        % Now do whatever you want with this file name,
        % such as reading it in as an image array with imread()
        imageArray = imread(fullFileName);
        G(k,1)=Ro*2*cali;
        G(k,1+ik)=(sum(double(imageArray).*mask,'all')/N-dc);  %/(f0{ik}(G(k,1))-100); %Normalization

        G1(k,1+ik)=sum(double(imageArray).*mask,'all')/N;
        G1(k,1)=G(k,1);
    end

    yy=G(k,2:size(G,2));
    xx=(1:(size(G,2)-1))*dtN/60;    %timeInt in min/60 so in hrs
    P = fitlm(xx,yy);
    %plot(xx,yy)

    Ab(k,1)=2*Ro*cali;                  %Calibration of pixel size
   % p11 = predint(f,Ab(k,1),0.90,'observation','off');
    Ab(k,2)=P.Coefficients{2,1};
    %  Ab(k,6)=P.Coefficients{2,2};
%     Ab(k,3)=Ab(k,5)*(P.Coefficients{2,2}/Ab(k,5)+abs(p11(1,1)-p11(1,2))/(f(Ab(k,1))-100));
    Ab(k,3)=P.Rsquared.Ordinary;
    %scatter(Ab(:,1),Ab(:,2))
    %plot(Ab(:,1),Ab(:,2))
    %plot(A)

    %      figure
    %      imshow(I)
    %      hold on
    %      quiver(X,Y,fu1,fv1,1,'r')
    %      hold off

end
slope_radius=Ab;
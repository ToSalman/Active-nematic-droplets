% NADH caliberation curve for drops of various size and [NADH]


function Gv = NADH_drop_linearFit(completePath,filteredCenters,filteredRadii,t1,t2,dt,px,fittedmodel)

filePattern = fullfile(completePath, '*.tif'); % Change to whatever pattern you need.
theFiles = dir(filePattern);

centersNew=[filteredCenters filteredRadii];

baseFileName = theFiles(t1).name;
fullFileName = fullfile(theFiles(t1).folder, baseFileName);
I= imread(fullFileName);

a=fittedmodel.a;
b=fittedmodel.b;
c=fittedmodel.c;
d=fittedmodel.d;
e=fittedmodel.e;
g=fittedmodel.g;

dDark=double(imread('E:\Data\NADH_drop\flat_field_correction20X_b2_200msExp_favg4\dark_vag.tif'));
Fs=double(imread('E:\Data\NADH_drop\flat_field_correction20X_b2_200msExp_favg4\Is.tif'));

for k=1:size(centersNew,1)
    Co=centersNew(k,1:2);
    Ro=centersNew(k,3);
    mask = createCirclesMask(I,Co,Ro);
    N = nnz( mask );
    count=0;
    for ik = t1 : 2 : t2
        
        count=count+1;
        baseFileName = theFiles(ik).name;
        fullFileName = fullfile(theFiles(ik).folder, baseFileName);
        % Now do whatever you want with this file name,
        % such as reading it in as an image array with imread()
        imageArray = double(imread(fullFileName));

        correctedImage=(imageArray-mean2(dDark))./((Fs-mean2(dDark))/mean((Fs-mean2(dDark)),'all'));

        G(k,1)=Ro*2*px;
        G(k,count+1)=sum(correctedImage.*mask,'all')/N;
        
        x=G(k,1);
        I_d=(d*x-e*x^2+0.0007*x^3);
        sol=roots([c*I_d b*I_d a*I_d (g-G(k,count+1))]);
        nadh(k,count)=sol(imag(sol)==0);
        xx(count)=(t1+count-1)*dt/60;
    end
    figure(3)
    yy=G(k,2:size(G,2));
    %xx=(1:(size(G,2)-1))*dt/60;    %timeInt in min/60 so in hrs
    P = fitlm(xx,yy);
    plot(xx,yy)
    set(findall(gcf,'-property','FontSize'),'FontSize',16)
    hold on
    plot(P)
    ylabel('Intensity')
    xlabel('time (hrs)')

    figure(4)
    zz=nadh(k,1:size(nadh,2));
    P1= fitlm(xx,zz);
    plot(xx,zz)
    set(findall(gcf,'-property','FontSize'),'FontSize',16)
    hold on
    plot(P1)
    ylabel('[NADH] mM/hr')
    xlabel('time (hrs)')

  % p11 = predint(f,Ab(k,1),0.90,'observation','off');
      %  Ab(k,6)=P.Coefficients{2,2};
%     Ab(k,3)=Ab(k,5)*(P.Coefficients{2,2}/Ab(k,5)+abs(p11(1,1)-p11(1,2))/(f(Ab(k,1))-100));
   
    Gv(k,1)=2*Ro*px;
    Gv(k,2)=P1.Coefficients{2,1};
    Gv(k,3)=P1.Coefficients{2,2};
    Gv(k,4)=P1.Rsquared.Ordinary;
    Gv(k,5)=std(zz);
    
end
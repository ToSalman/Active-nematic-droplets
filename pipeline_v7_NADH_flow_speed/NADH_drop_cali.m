% NADH caliberation curve for drops of various size and [NADH]


function Gv = NADH_drop_cali(completePath,filteredCenters,filteredRadii,t1,t2,dt,px,NADH,dDark,Fs)

Ithresh=20;
filePattern = fullfile(completePath, '*.tif'); % Change to whatever pattern you need.
theFiles = dir(filePattern);

centersNew=[filteredCenters filteredRadii];

baseFileName = theFiles(t1).name;
fullFileName = fullfile(theFiles(t1).folder, baseFileName);
I= imread(fullFileName);
count1=0;
for k=1:size(centersNew,1)
    Co=centersNew(k,1:2);
    Ro=centersNew(k,3);
    mask = createCirclesMask(I,Co,Ro);
    N = nnz( mask );
    count=1;
    for ik = t1 : 2 : t2
        
        count=count+1;
        baseFileName = theFiles(ik).name;
        fullFileName = fullfile(theFiles(ik).folder, baseFileName);
        % Now do whatever you want with this file name,
        % such as reading it in as an image array with imread()
        imageArray = double(imread(fullFileName));

        correctedImage=(imageArray-mean2(dDark))./((Fs-mean2(dDark))/mean((Fs-mean2(dDark)),'all'));

        G(k,1)=Ro*2*px;
        G(k,count)=sum(correctedImage.*mask,'all')/N;
    end
    figure(1)
    yy=G(k,2:size(G,2));

    d1=yy(1:(length(yy)-1));
    d2=yy(2:length(yy));

    Ifind=find(abs(d2-d1)>yy(1,1)*0.03);

    if length(Ifind)<1 && std(yy)<7
        count1=count1+1;
        plot(yy);
        hold on
        Gv(count1,1)=NADH;
        Gv(count1,2)=2*Ro*px;
        Gv(count1,3)=mean(yy);
        Gv(count1,4)=std(yy);
    end



    


%     plot(yy);
%     hold on
%     Gv(k,1)=NADH;
%     Gv(k,2)=2*Ro*px;
%     Gv(k,3)=mean(yy);
%     Gv(k,4)=std(yy);
end

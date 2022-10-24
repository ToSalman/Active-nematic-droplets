function [centersNew,radiiNew]=RemoveOverLap(centers,radii,tol,I)
% This function deals with overlaping circles by:
% option 1: removes one circle of the two (if it does not matter which one).
% option 2: removes the smaller circle of the two
% option 3: kills both all overlaping circles
% centers - (x,y) circles centers.
% radii - the circles radius
% tol - tolerance for an overlap, im number of pixels.
% option - 1,2 or 3, see above.
% Uses the function snip() from the file exchange.
option=2;
l=length(centers);
for i= 1: l
    s=i+1;
    for j=s:l
        d_ij=sqrt((centers(i,1)-centers(j,1)).^2+(centers(i,2)-centers(j,2)).^2);
        k=radii(i)+radii(j)-tol;
        if d_ij < k && radii(j)>0
            %option 1
            if option == 1
             centers(i,1)=0;
             centers(i,2)=0;
             radii(i)=0;
            end
            %option 2 
            if option == 2
                 if radii(i)>radii(j)
                     centers(j,1)=0;
                     centers(j,2)=0;
                     radii(j)=0;
                 else
                    centers(i,1)=0;
                    centers(i,2)=0;
                    radii(i)=0;
                 end
            end
            %option 3
            if option ==3
                     centers(j,1)=0;
                     centers(j,2)=0;
                     radii(j)=0;
                     centers(i,1)=0;
                     centers(i,2)=0;
                     radii(i)=0;
            end
        end
   end
end
%create new circles vectors using snip()
% centersNew1=snip(centers,'0');
% radiiNew1=snip(radii,'0');

centers = snip(centers, '0');
radii = snip(radii,'0');

nDroplets = length(centers);
    
    imSize=size(I,1);
    %iterate through each droplet and determine whether it is too close to
    %boundary to measure
    for i = 1:nDroplets
        
        %calculate the extent of the droplet in both x and y directions
            %extent is just the range of x and y values the droplet covers
        extent = [centers(i,1)-radii(i), centers(i,1)+radii(i); ...
            centers(i,2)-radii(i), centers(i,2)+radii(i)];
        
        %calculate, based on imSize, whether the droplet is fully enclosed
        %or not
        if max(extent,[],'all')>imSize || min(extent,[],'all')<0
            filterList(i) = 0;
        else
            filterList(i) = 1;
        end
    end
    
    %output filtered data to be used
    centersNew = centers(filterList==1, :);
    radiiNew = radii(filterList==1);

viscircles(centersNew,radiiNew,...
        'color', 'b');
    for i = 1:size(radiiNew,1)
        text(centersNew(i,1)-25,centersNew(i,2),num2str(i),...
            'color','g')
    end
    hold off

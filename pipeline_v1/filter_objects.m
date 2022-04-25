% function that packages flows in a structure array

function [droplets, newMask] = filter_objects(binary,tolerance)

    %calculate the components connected in the binary image provided
    stats = regionprops(binary,'Area','Centroid',...
        'Solidity','LabelName','Perimeter','Circularity');
   
    %get centers info and sort into x and y
    centersUnpacking = [stats(:).Centroid];
    numberOfCenters = length(centersUnpacking)./2;
    centers(1,:) = centersUnpacking(1:2:end);
    centers(2,:) = centersUnpacking(2:2:end);
    
    %find radius of each object
    radii = sqrt([stats(:).Area]./pi);
    
    allDroplets(:,1) = centers(1,:);
    allDroplets(:,2) = centers(2,:);
    allDroplets(:,3) = radii;
    
    %find the ratio of the perimeter to the area for all objects
    circularity = [stats(:).Circularity];
   
    %find good droplets based on circularity being close to 1 based on
        %tolerance setting (reccomended setting >0.8)
    goodDroplets = (circularity > tolerance).';
    
    %filter out droplets not circular enough
    droplets = allDroplets(goodDroplets, :);
    
    %create new mask to be filled in
    newMask = 0.*binary;
    
    %get image properties for new mask
    imSize = size(newMask);
    [columns, rows] = meshgrid(1:imSize(1), 1:imSize(2));
    
    %fill in new mask one by one
    for i = 1:size(droplets,1)
        %set up temporary space to plot droplet
        tempSpace = 0.*binary;
        
        %create the circle in the image
        tempSpace = (rows - droplets(i,2)).^2 ...
            + (columns - droplets(i,1)).^2 <= droplets(i,3).^2;
        
        %add the droplet to the new mask
        newMask = newMask + tempSpace;
    end
    
    %make the new mask a logical array
    newMask = newMask > 0;
end
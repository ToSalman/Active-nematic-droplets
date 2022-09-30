function [filteredCenters, filteredRadii] = remove_edge_objects(centers, radii, imSize)

    %determine the length of the droplets
    nDroplets = length(centers);
    
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
    filteredCenters = centers(filterList==1, :);
    filteredRadii = radii(filterList==1);
end
    
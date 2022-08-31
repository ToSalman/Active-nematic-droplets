function [filteredCenters, filteredRadii] = filter_detection(centers,radii)
nDetections = size(radii,1);

for i = 1:nDetections
        centerSeparation = sqrt(sum((centers - centers(i,:)).^2,2));
        centerSeparation(i) = NaN;
        overlapValues = centerSeparation-(radii+radii(i));

        %find if ith droplet is smaller than the closest droplet center
            %positive means ith is larger than closest droplet, should not
                %filter ith droplet
            %negative means ith is smaller than closest droplet, might 
                %need filtering
        deltaRadius = radii(i) - radii(overlapValues<0);
            
        %overlap happens when separation is less than the radii added 
            %together
        overlapCheck = min(overlapValues)<0;
        
        %calculate whetehr to keep or discard ith droplet detection
        if overlapCheck == 1 && min(deltaRadius < 0) 
            dropletKeepIndex(i) = 0;
        else
            dropletKeepIndex(i) = 1;
        end
        clear centerSeparation
    end
    %make new array of kept droplets
    filteredCenters = centers(dropletKeepIndex>0,:);
    filteredRadii = radii(dropletKeepIndex>0);
    
    %display updated result overlay for user
    viscircles(filteredCenters,filteredRadii,...
        'color', 'b');
    for i = 1:size(filteredRadii,1)
        text(filteredCenters(i,1)-25,filteredCenters(i,2),num2str(i),...
            'color','g')
    end

end
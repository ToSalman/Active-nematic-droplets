
function result = compile_results(data)

    for i = 1:size(data.radii,1)
    
    %get mean and std of flow velocity magnitude
    result.diameter = data.radii*2;
    result.meanVel(i) = mean(data.meanVelMag(i,:),2);
    result.stdVel(i) = std(data.meanVelMag(i,:),[],2);  
    
    end
    %end analysis routine for droplet i
    
end

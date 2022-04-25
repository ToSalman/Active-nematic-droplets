
function result = compile_results(data, persistenceThreshold, ...
    vorticityThreshold)
    count = 1;
    for i = 1:size(data.radii,1)
        
    %get the median persistence magnitude for the droplet
    persistenceValue = median(data.persistenceMag{i});
    
    %get mean and std of flow velocity magnitude
    result.meanVel(i) = mean(data.meanVelMag(i,:),2);
    result.stdVel(i) = std(data.meanVelMag(i,:),[],2);
    
    if persistenceValue > result.meanVel(i) + ...
            persistenceThreshold*result.stdVel(i)
        %droplet passes test, is active in some way
        result.brownian(i) = 0;
    else
        %droplet fails test, and thus categorized as a Brownian droplet
        result.brownian(i) = 1;  
    end
    %end of brownian classification
    
    if mean(data.vorticity(i,:)) < mean(data.vorticity,'all') + ...
            vorticityThreshold*std(data.vorticity,[],'all')
    %droplet passes escessive rotation test
        result.rotation(i) = 0;
    else
    %droplet fails excessive rotation test
        result.rotation(i) = 1;
    end
    %end of rotation classification
    
    %combine rotation and brownian flags to determine droplet validity
    result.flags(i) = result.rotation(i)+result.brownian(i);
    if result.flags(i) == 0
        result.cleanResults(count,:) = ...
            [data.radii(i),result.meanVel(i),result.stdVel(i)];
        count = count+1;
    end 
    %end result conditional
    
    end
    %end analysis routine for droplet i
    
end

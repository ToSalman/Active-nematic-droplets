% get raw results from filtered mask and assign droplets to categories

function data = assign_flows(centers, radii, flows)

lc=3; %%
% create final data structure format
    data.centers = centers;
    data.radii = radii;
    
    %rearrange PIV data for later analysis
    for t = 1:length(flows.fu)
        %place velocity values in a block for easy analysis
        velocityBlockX(:,:,t) = flows.fu{t};
        velocityBlockY(:,:,t) = flows.fv{t};   
        velocityMagnitude(:,:,t) = sqrt(velocityBlockX(:,:,t).^2 +...
            velocityBlockY(:,:,t).^2);
    end

    %sum first lc frame velocities to check for random jittering
    sumFlowsX = sum(velocityBlockX(:,:,1:lc),3);
    sumFlowsY = sum(velocityBlockY(:,:,1:lc),3);
    sumFlows(:,:,t) = sqrt(sumFlowsX.^2 + sumFlowsY.^2);
    
    % get data for each droplet
    nDrops = size(radii,1);
    for i = 1:nDrops

        % get location, radius of the ith droplet
        c = centers(i,:);
        r = radii(i);

        % get which windows are included by the ith droplet
        data.ROI{i} = sqrt((flows.y-c(2)).^2 + (flows.x-c(1)).^2) < r;
        
        % check the flows randomness result (flow persistence) and
        % vorticity
        temp = sumFlows(:,:,t);
        data.brownianMag{i} = temp(data.ROI{i});
        for t = 1:length(flows.fu)
            temp = velocityMagnitude(:,:,t);
            data.meanVelMag(i,t) = mean(temp(data.ROI{i}),'all');
            %temp = flows.vorticity{t};
            %data.vorticity(i,t) = mean(temp(data.ROI{i}),'all');
        end
       
       
    end
end

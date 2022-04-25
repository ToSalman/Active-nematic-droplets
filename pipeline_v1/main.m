% analysis pipeline for active droplets
% readme to be posted on Github
% Jeremy Laprade
% April 2022
% v1
% requires PIVlab v2.55

%dont worry about getting all or even many droplets, just get droplets
% that are strongly visible and not directly bordering others
%image and detected circles are user output
%filter out 'jittering' droplets by summing velocities over frames,
% (roughly 5 frames or so)
%also filter out rotating droplets by vorticity

%%
%specify world parameters
px = 0.65/2;
dt = 10;

% determine filepath ot data stored on drive
dataPath = 'E:\Active Droplet Pipeline\Test Data\';
expFolder = 'Pos1';

%%
% construct complete filepath to data for binarization function
completePath = [dataPath,expFolder];

% create single mask from greyscale image sequence
    % parameter 1: filepath to dataset
    % parameter 2: miss tolerance, effectively a sensitivity parameter
    % parameter 3: minimum allowed object size, recommended ~500px
[binary,overlay] = mask_droplets(completePath, 0.1, 500);

% show overlay of binary image over example data
figure(1)
imshow(overlay,[])
axis equal
title(['Binary result for folder ',expFolder])

% get centers, radii, and quality metric from acceptable droplets
[droplets, newMask] = filter_objects(binary, 0.8);

% at this point, we might want to save masks for individual droplets in
% order to make future calculations simpler and easier

% have a cell array that builds new information as you go rather than
% making new elements

% e.g. start results with array of radii, then array of 2D masks, then
% always store data as an array which assigns the data to a droplet number
% based on the array index

% package flows into a structure element for easy passing to functions
flows.x = x{1};
flows.y = y{1};
flows.fu = u_smoothed;
flows.fv = v_smoothed;
flows.vorticity = vorticity;

% assign flows to droplets based on PIV data in workspace
data = assign_flows(droplets, flows); %needs to be written

%compile results from data, based on a few user specifications
results = compile_results(data, 1, 1);



%%
% plotting section for results and analysis
   
        
figure
errorbar(2.*px.*results.cleanResults(:,1).', (px/dt).*results.cleanResults(:,2), ...
    (px./dt).*results.cleanResults(:,3),'.k','markerSize',30)
xlabel('droplet diameter, d (\mum)')
ylabel('average speed, < v >_{t}')
box off
set(gca,'FontSize',16)
% analysis pipeline for active droplets
% readme to be posted on Github
% Jeremy Laprade
% April 2022
% v2.1
% requires PIVlab v2.55

% notes:

    % still need to tune brownian and vorticity sensitivities for proper
    % filtering
    
    % still want to implement filtering of extra droplets that may be
    % encircled by other droplets (can thus more reliably use higher
    % detection sensitivity)
    
    %will incorporate a more intracate user system to view results of
    %detection and filtering
        %color code circles around droplets for active, passive, brownian,
        %and rotating droplets, and output that to a video
    
%%
%specify world parameters
px = 0.65/2;
dt = 10;

% determine filepath ot data stored on drive
dataPath = 'E:\Active Droplet Pipeline\Test Data\';
expFolder = 'Pos1';

% construct complete filepath to data for binarization function
completePath = [dataPath,expFolder];
resultsPath = [dataPath,'Results\'];
% find droplets from raw image data
    %parameter 1: filepath to dataset
    %parameter 2: droplet minimum radius
    %parameter 3: a sensitivity tuner (any positive number)
        %large number --> less sensitive detection (more filtering)
        %small number --> more sensitive detection (less filtering)
        %0 removes filtering all together, can be used to examine
        % filtering
[centers,radii] = find_droplets(completePath, 25, 1.0);

%filter detection in a seperate function (currently only remove overlaps)
[filteredCenters, filteredRadii] = filter_detection(centers, radii);

% package flows into a structure element for easy passing to functions
flows.x = x{1};
flows.y = y{1};
flows.fu = u_smoothed;
flows.fv = v_smoothed;
flows.vorticity = vorticity;

% assign flows to droplets based on PIV data in workspace
    % parameter 1: centers of all detected droplets
    % parameter 2: radii of all detected dropelts
    % parameter 3: flows data from PIVlab packaged a few lines earlier
data = assign_flows(filteredCenters,filteredRadii,flows);

%compile results from data, based on a few user specifications
    %parameter 1: input of raw data for droplets and flows
    %parameter 2: brownian sensitivity (x), number greater than 0
        %suggest roughly 0.006um/s, 0 disables threshold.  higher number 
        %flags more droplets as brownian, and smaller number flags less
    %parameter 3: vorticity sensitivity, works same way as parameter 2
        %suggest 1 for now, until I get suggested value from inspection of
        %test data
results = compile_results(data, 0.0, 1);

% output: color coded images that you can use to make a video
    % green = good for analysis
    % red = rotating droplet
    % blue = brownian droplet
video_writer(completePath, resultsPath, expFolder, data, results)

% plotting section for results and analysis   
figure
errorbar(2.*px.*results.cleanResults(:,1).', ...
    (60*px/dt).*results.cleanResults(:,2), ...
    (60*px./dt).*results.cleanResults(:,3),...
    '.k','markerSize',25)
xlabel('droplet diameter, d (\mum)')
ylabel('average speed, < v > (\mum/min)')
axis square
box off
set(gca,'FontSize',16)
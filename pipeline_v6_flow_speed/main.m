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
% 
%%%
% place breakpoint at line 63 for troubleshooting
%%$'Pos11_k40' 'Pos12' 'Pos13' 'Pos14' 'Pos15' 'Pos16' 'Pos17' 'Pos19' 'Pos20' 'Pos21' 'Pos22' 'Pos23' 
Vr=[];
tol=10; % tollerance of removing overlap

% determine filepath ot data stored on drive
dataPath = 'E:\Data\droplets_9_2022\Varying_KSA\10_10_2022_fd30_k15_20_30_40_50_NajPM\keck_ham_20x_b1_90sInt_K15_20_30_2\';
expFolders = [{'Pos41_k30' 'Pos42' 'Pos43' 'Pos44' 'Pos45' 'Pos46' 'Pos47' 'Pos48' 'Pos49' 'Pos50' 'Pos51' 'Pos52'}];
PIVpath = [dataPath,'PIV\'];
%specify world parameters

        px = 0.325;
        dt = 1.5;
        t1=501; %where NADH image begins
        t2=t1+60; %NADH images end
        f1=10; %MTs channel begin
        f2=f1+40; %MTs channel end

        %specify analysis parameters
        diameterRange = [60 350]; %in pixels
        detectionSensitivity = 0.7;
        edgethresh=0.99;


        for n = 1:size(expFolders,2)

            % construct complete filepath to data for binarization function
            completePath = [dataPath,expFolders{n}];
            resultsPath = [dataPath,'Results\',expFolders{n}];
            mkdir(resultsPath)
            % find droplets from raw image data
            %parameter 1: filepath to dataset
            %parameter 2: droplet minimum radius
            %parameter 3: a sensitivity tuner (any positive number)
            %large number --> less sensitive detection (more filtering)
            %small number --> more sensitive detection (less filtering)
            %0 removes filtering all together, can be used to examine
            % filtering
            %     [centers,radii] = find_droplets(completePath, ...
            %         diameterRange./2, ...
            %         detectionSensitivity, edgethresh);

            [centers,radii,I,default_edgethreshold] = find_droplets(completePath, ...
                diameterRange./2, ...
                detectionSensitivity,f1,f2);

            if size(centers,1)>1
            %filter detection in a seperate function (currently remove overlaps)
            %[filteredCenters, filteredRadii] = filter_detection(centers, radii);
            [filteredCenters,filteredRadii]=RemoveOverLap(centers,radii,tol,I);
            saveas(gcf,[resultsPath,'\det_sen-',num2str(detectionSensitivity),'_ed-',num2str(edgethresh),'.png'])
            %close
            % load and package flows into a structure element for easy passing to
            % functions
            end

            %slope_radii{n} = NADH_slope(completePath,filteredCenters,filteredRadii,t1,t2);

               load([PIVpath,expFolders{n}])
                 flows.x = x{1};
                 flows.y = y{1};
                 flows.fu = u_smoothed;
                 flows.fv = v_smoothed;
            %     flows.vorticity = vorticity;
            %
            %     % assign flows to droplets based on PIV data in workspace
            %         % parameter 1: centers of all detected droplets
            %         % parameter 2: radii of all detected dropelts
            %         % parameter 3: flows data from PIVlab packaged a few lines earlier
                 data = assign_flows(filteredCenters,filteredRadii,flows);
            %
            %     %compile results from data, based on a few user specifications
            %         %parameter 1: input of raw data for droplets and flows
            %         %parameter 2: brownian sensitivity (x), number greater than 0
            %             %suggest roughly 0.006um/s, 0 disables threshold.  higher
            %             %flags more droplets as brownian, and smaller number flags less
            %         %parameter 3: vorticity sensitivity, works same way as parameter 2
            %             %suggest 1 for now
                 finalResult = compile_results(data);
            %
                save([resultsPath,'\results','finalResult'])
            %     % output: color coded images that you can use to make a video
            %         % green = good for analysis
            %         % red = rotating droplet
            %         % blue = brownian droplet
            %     %video_writer(completePath, resultsPath, expFolders{n}, data)
            %
            %     % plotting section for results and analysis
            n
            figure(1)    
            errorbar(px.*finalResult.diameter.', ...
                (px/dt).*finalResult.meanVel, ...
                (px/dt).*finalResult.stdVel,...
                '.','markerSize',25)
                xlabel('droplet diameter (um)')
                ylabel('Average flow speed (um/min)')
                set(findall(gcf,'-property','FontSize'),'FontSize',16)
                hold on
            
                allresults{n,1}=[px.*finalResult.diameter (px/dt).*finalResult.meanVel' (px/dt).*finalResult.stdVel'];
                Vr=cat(1,Vr, allresults{n});
                continue;
            
        end

% xlabel('droplet diameter, d (\mum)')
% ylabel('average speed, < v > (\mum/min)')
% axis square
% box off
% set(gca,'FontSize',16)

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
%%$
NADH_diameter_grey=[];
tol=10; % tollerance of removing overlap 

% 'Pos3_flick' 'Pos4' 'Pos6' 'Pos7' 'Pos8' 'Pos9' 'Pos10' 'Pos11' 'Pos12' 'Pos13' 'Pos14' 'Pos15' 'Pos16' 'Pos17'
% determine filepath ot data stored on drive
dataPath = 'E:\Data\NADH_drop\10_17_2022_N2.5_fd40_K30_flick_bulk_dropmaker\Ti2_20x_b2_lvl15_exp200_favg4_6minInt_1\';
expFolders = [{'Pos5' }];
%PIVpath = [dataPath,'PIV\'];
%specify world parameters
        NADH=0.75; %NADH concentration in mM
        px = 0.65;
        dt = 6;
        t1=8; %where NADH image begins
        t2=t1+20; %NADH images end
        f1=7; %MTs channel begin
        f2=f1+20; %MTs channel end

        %specify analysis parameters
        diameterRange = [46 136]; %in pixels
        detectionSensitivity = 0.8;
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

            [centers,radii,I,default_edgethreshold] = find_droplets_1_2(completePath, ...
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

            %slope_radii{n} = NADH_slope(completePath,filteredCenters,filteredRadii,t1,t2,dt,px);
            %NADH_diameter_grey = cat(1, NADH_diameter_grey, NADH_drop_cali(completePath,filteredCenters,filteredRadii,t1,t2,dt,px,NADH,dDark,Fs));

            NADH_diameter_grey = cat(1, NADH_diameter_grey, NADH_drop_linearFit(completePath,filteredCenters,filteredRadii,t1,t2,dt,px,fittedmodel));
%                load([PIVpath,expFolders{n}])
%                  flows.x = x{1};
%                  flows.y = y{1};
%                  flows.fu = u_smoothed;
%                  flows.fv = v_smoothed;
            %     flows.vorticity = vorticity;
            %
            %     % assign flows to droplets based on PIV data in workspace
            %         % parameter 1: centers of all detected droplets
            %         % parameter 2: radii of all detected dropelts
            %         % parameter 3: flows data from PIVlab packaged a few lines earlier
            %     data = assign_flows(filteredCenters,filteredRadii,flows);
            %
            %     %compile results from data, based on a few user specifications
            %         %parameter 1: input of raw data for droplets and flows
            %         %parameter 2: brownian sensitivity (x), number greater than 0
            %             %suggest roughly 0.006um/s, 0 disables threshold.  higher
            %             %flags more droplets as brownian, and smaller number flags less
            %         %parameter 3: vorticity sensitivity, works same way as parameter 2
            %             %suggest 1 for now
            %     finalResult = compile_results(data);
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
%             figure(1)    
%             errorbar(px.*finalResult.diameter.', ...
%                 (px/dt).*finalResult.meanVel, ...
%                 (px/dt).*finalResult.stdVel,...
%                 '.','markerSize',25)
%                 xlabel('droplet diameter (um)')
%                 ylabel('Average flow speed (um/min)')
%                 set(findall(gcf,'-property','FontSize'),'FontSize',16)
%                 hold on
%             
%                 allresults{n,1}=[finalResult.diameter finalResult.meanVel' finalResult.stdVel'];
%                 continue;
            
        end

% xlabel('droplet diameter, d (\mum)')
% ylabel('average speed, < v > (\mum/min)')
% axis square
% box off
% set(gca,'FontSize',16)

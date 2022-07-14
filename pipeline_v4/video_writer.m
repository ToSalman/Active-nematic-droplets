function video_writer(completePath, resultsPath, expFolder, data)
    mkdir([resultsPath, expFolder, '\Video\'])
    %get sequence of files to analyze
    sequence = get_files(completePath);
    
    %get data image to find circles, average over all images in sequence
    for t = 1:length(sequence)
        %import image t in the sequence
        image = imread([completePath,'\',sequence(t).name]);
        
        figure
        imshow(image,[])
        axis square
        viscircles(data.centers,...
            data.radii,...
            'color','b');
        for i = 1:size(data.radii,1)
            text(data.centers(i,1)-25,data.centers(i,2),num2str(i),...
                'color','g')
        end
        saveas(gcf,[resultsPath, expFolder, '\Video\t_',num2str(t),'.png'])
        close
    end
    
    
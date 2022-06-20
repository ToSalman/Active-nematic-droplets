function video_writer(completePath, resultsPath, expFolder, data, results)
    mkdir([resultsPath, expFolder, '\Video\'])
    %get sequence of files to analyze
    sequence = get_files(completePath);
    
    %get data image to find circles, average over all images in sequence
    for t = 1:length(sequence)
        %import image t in the sequence
        image = imread([completePath,'\',sequence(t).name]);
        
        figure
        imshow(adapthisteq(image),[])
        axis square
        viscircles(data.centers(results.flags == 0,:),...
            data.radii(results.flags == 0),...
            'color','g');
        viscircles(data.centers(results.brownian == 1,:),...
            data.radii(results.brownian == 1),...
            'color','b');
        viscircles(data.centers(results.rotation == 1,:),...
            data.radii(results.rotation == 1),...
            'color','r');
        saveas(gcf,[resultsPath, expFolder, '\Video\t_',num2str(t),'.png'])
        close
    end
    
    
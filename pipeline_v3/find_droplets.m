% binarization function for active droplets

function [centers,radii] = find_droplets(path, ...
    minRadius, sensitivity)
    
    %get sequence of files to analyze
    sequence = get_files(path);

    %get data image to find circles, average over all images in sequence
    for t = 1:length(sequence)
        %import image t in the sequence
        data(:,:,t) = imread([path,'\',sequence(t).name]);
        
        % average over all frames to blur/smooth inside droplets 
            % this works best with *more* images, recommend > 30
        avgData = mean(data,3);
    end
    
    %find x and y gradient magnitudes, then total gradient magnitude
    [~,~,gx,gy] = edge(avgData,'sobel');
    G = sqrt(gx.^2 + gy.^2);

    %find circles in the gradient data to define droplets
    [c,r,m] = imfindcircles(avgData, [minRadius 512], 'sensitivity', 0.85);
    [cG,rG,mG] = imfindcircles(G, [minRadius 512], 'sensitivity', 0.85);
    %set a metric threshold based on otsu thresholding method
        %metric is supposed to be a 'quality' measure, i think it
        %primarily measures 'circularity' of droplets...
    mThresh = sensitivity*otsuthresh(m);
    mThreshG = sensitivity*otsuthresh(mG);
    %store center, radii data in a cell array (that pass metric test)
    centers = [c(m>mThresh,:);cG(mG>mThreshG,:)];
    radii = [r(m>mThresh);rG(mG>mThreshG)];
    
  %display result overlay for user
    figure
    imshow(avgData,[])
    title(['Detection result, metric threshold = ',...
        num2str(mThresh)])
    hold on
    viscircles(centers,radii);
end

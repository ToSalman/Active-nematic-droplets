% binarization function for active droplets

function [finalMask, overlay] = mask_droplets(path, missTolerance, minSize)
    
    %get sequence of files to analyze
    sequence = get_files(path);

    %create stats structure to evaluate performance, 
    %stats.minSize = minSize;
    %stats.robustness = robustness;

    for t = 1:length(sequence)
        %import image t in the sequence
        data = imread([path,'\',sequence(t).name]);

        %find x and y gradient magnitudes, then total gradient magnitude
        [~,~,gx,gy] = edge(data,'sobel');
        G = sqrt(gx.^2 + gy.^2);

        %define droplet edges via a simple adaptive threshold
        edges = imbinarize(G,'adaptive');

        %remove thin edges/structures with  erosion then dilation
        openEdges = imopen(edges, strel('disk', 1));

        %skeletonize binary to reduce strong edges to true edge location
        skeleton = bwskel(openEdges);

        %fill in holes to create binary droplet structures
        fill = imfill(skeleton,'holes');

        %perform opening on image to remove small objects
        openFill = imopen(fill, strel('disk', 1));

        %remove objects under the minimum size from the image
        cleanFill = bwareaopen(openFill, minSize);

        %store mask in a 3D array
        masks(:,:,t) = cleanFill;
    end

    %determine probability of each pixel being part of a droplet
    maskProb = sum(masks,3)./length(sequence);

    % final mask is every pixel present more than the robustness threshold
    finalMask = bwareaopen(maskProb > 1-missTolerance, minSize);

    % get overlay example to save to directory for inspection
    finalOutline = bwperim(finalMask, 8);
    overlay = imfuse(data,finalOutline);

end

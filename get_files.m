%function to import images from folder, excluding the file path elements

function [sequence,parent] = get_files(path)
    sequence = dir(path);
        %sort data based on date so that it is in chronological order
        [~,sortIndex]=sort(datetime({sequence.date}));
        sequence = sequence(sortIndex);
        %only include the files, not the directory in the sequence
        remove = ismember({sequence.name},{'.','..','metadata.txt'});
        sequence(remove) = [];
    
    parts = strsplit(path, '\');
    parent = parts{1};
    for n = 2:size(parts,2)-1
        parent = [parent,'\',parts{n}];
    end
end
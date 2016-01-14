function [ props ] = caffe_read_solverprototxt( prototxt_filename )
%% Description
% The function reads solver's *.prototxt file and returns the structure
% --- INPUTS:
% prototxt_filename = solver prototxt file name
% --- OUPUTS:
% props = structure with properties
% 
%% Execution
    print_res = 1;

    lines = textread(prototxt_filename, '%s', 'delimiter', '\n');   
    
    fprintf('File loaded = %s \n', prototxt_filename);
    fprintf('lines = %d \n', length(lines));
    
    %Get rid of comments
    cur_line = 0;
    for line_i = 1:length(lines)    
        comment_start = strfind(lines(line_i), '#');
        
        if length(comment_start{1}) > 0
            lines{line_i} = lines{line_i}((comment_start{1}+1):end);
        else
            lines{line_i} = lines{line_i};
        end
            
        if length( lines{line_i} ) > 0 && length( strfind(lines{line_i}, ':')) > 0  
           cur_line = cur_line + 1;
           lines_nocom{cur_line} = lines{line_i};
        end
    end
    
    %Process every property
    for line_i = 1:length(lines_nocom)
       name_val = strsplit(lines_nocom{line_i},':') ;
       val_processed = strtrim(name_val{2});
       val_processed = regexprep(val_processed,'[\"]','');
       props.(name_val{1}) = val_processed;
    end
    
    %After done print the result
    if print_res
        fprintf('Properties: \n');
        propnames = fieldnames(props);
        for prop_i = 1:numel(propnames)
           fprintf('%s = %s \n', propnames{prop_i}  ,props.(propnames{prop_i})) ;
        end
    end
end


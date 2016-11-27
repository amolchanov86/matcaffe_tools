function [ props ] = caffe_read_solverprototxt( filename, varargin )
%% Description
% The function reads solver's *.prototxt file and returns the structure
% --- INPUTS:
% filename = solver prototxt file name
% --- OUPUTS:
% props = structure with properties
% 
%% Execution
% Cut the extension
extension = '.prototxt';
if length(filename ) >= 10
    if strcmp( filename(end-8:end), extension)
        filename = filename(1:end-9);
    end
end
        
var_i = 1;        
print_res = 0;
if length(varargin) >= var_i
    print_res = varargin{var_i};
end

lines = textread([filename extension], '%s', 'delimiter', '\n');   

fprintf('%s : File loaded = %s lines = %d \n', mfilename, [filename extension], length(lines));

%Get rid of comments
cur_line = 0;
for line_i = 1:length(lines)    
    comment_start{line_i} = strfind(lines{line_i}, '#');

    if length(comment_start{line_i}) > 0
        lines{line_i} = lines{line_i}(1:(comment_start{line_i}-1));
%             fprintf('Comment starts = %d Line = %s \n', comment_start{line_i}, lines{line_i});
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
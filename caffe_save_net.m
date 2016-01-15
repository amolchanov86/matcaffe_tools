function [ out ] = caffe_save_net( filename, header, net_descr )
%% Description
% function generates *.prototxt file from structure provided
% --- INPUTS:
% [ out ] = caffe_save_net( filename, header, net_descr )
% filename = file name
% net_descr = net description is a cell array with structures describing
%   particular layers. 
% header = network header structure. It must contain 'name' parameter, the
%   rest (such as inputs for the deployment network) is optional
 
%% Parameters
extension = '.prototxt';
indent = '  ';


%% Execution
% Correct if extension already present
if length(filename ) >= 10
    if strcmp( filename(end-8:end), extension)
        filename = filename(1:end-9);
    end
end

% Open file to write
fileID = fopen( [filename extension], 'w');
indent_cur = '';

% Do the job by calling functions recursively

    function var_type = caffe_var_type(var)
        if isstruct( var )
            var_type = 1;
        else
            if iscell( var )
                var_type = 2;
            else
                var_type = 0;
            end
        end
    end
        
    function caffe_save_net_str( file_id, str_in, str_name, indent, indent_cur)
        parameter_names = fieldnames(str_in);
        fprintf(file_id, '%s%s {\n', indent_cur, str_name);
        for var_i=1:length(parameter_names)             
            var_type = caffe_var_type( str_in.(parameter_names{var_i}) );
            switch var_type
                case 0
                    caffe_save_net_param(file_id, str_in.(parameter_names{var_i}), parameter_names{var_i}, str_name, [indent_cur indent] );
                case 1
                    caffe_save_net_str  (file_id, str_in.(parameter_names{var_i}), parameter_names{var_i}, indent, [indent_cur indent]);
                case 2
                    caffe_save_net_cell (file_id, str_in.(parameter_names{var_i}), parameter_names{var_i}, str_name, indent, indent_cur);
            end            
        end
        fprintf(file_id, '%s}\n', indent_cur);
    end

    function caffe_save_net_cell(file_id, cell_in, cell_name, parent_name, indent, indent_cur)
        for cell_i=1:length(cell_in)
            var_type = caffe_var_type( cell_in{cell_i} );
            switch var_type
                case 0
                    caffe_save_net_param(file_id, cell_in{cell_i}, cell_name, parent_name, [indent_cur indent] );
                case 1
                    caffe_save_net_str  (file_id, cell_in{cell_i}, cell_name, indent, [indent_cur indent]);
            end            
        end
    end

    function caffe_save_net_param(file_id, var_in, var_name, parent_name, indent_cur)
        
        if isinteger(var_in)
            var_str_in = sprintf('%d', var_in);
            num_stat = 1;
        else
            if isnumeric(var_in)
               var_str_in = sprintf('%.10g', var_in);
               num_stat = 1;
            else
               var_str_in = var_in;
               [num, num_stat] = str2num( var_in );
            end
        end    
                   
        no_quot = 0;
        no_quot = no_quot || strcmp( 'pool', var_name )    && strcmp( 'pooling_param', parent_name ); 
        no_quot = no_quot || strcmp( 'phase', var_name )   && strcmp( 'include', parent_name );
        no_quot = no_quot || strcmp( 'mirror', var_name )  && strcmp( 'transform_param', parent_name );
        no_quot = no_quot || strcmp( 'backend', var_name ) && strcmp( 'data_param', parent_name );
        
        if num_stat || no_quot
            fprintf(file_id, '%s%s: %s\n', indent_cur, var_name, var_str_in );
        else
            fprintf(file_id, '%s%s: \"%s\"\n', indent_cur, var_name, var_str_in );
        end
    end


    % Filling in the header
    caffe_save_net_param( fileID, header.name, 'name', '', indent_cur);
    header_rest = rmfield( header, 'name');
    header_names = fieldnames(header_rest);
    for head_i=1:length(header_names)             
        caffe_save_net_param(file_id, header_rest.( header_names{head_i} ), header_names{head_i}, '', indent_cur);
    end
    
    % Iterate through layers writing them into the file
    for layer_i=1:length(net_descr)
       fprintf('Layer %d: name = %s ...\n', layer_i, net_descr{layer_i}.name ); 
       caffe_save_net_str( fileID, net_descr{layer_i}, 'layer', indent, indent_cur); 
    end

    fclose(fileID);
end


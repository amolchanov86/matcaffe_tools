function [ out ] = caffe_save_net( filename, header, net_descr )
%% Description
% Function generates *.prototxt file from structure provided
% Net desctiption is organized as following:
% - header structure (containing the network's name: Ex: header.name = 'MyNet'; )
% - net_descr structure is a cell array. Every cell is interpreted as
%   'layer' structure of the proto file. Every structure of the proto file
%   is represented as matlab structure. Every value field as variable of
%   the structure. If a proto structure contains several variables with the
%   same name then one must create a cell array with the name corresponding
%   to the name of the variable (for example it is often the case for 'bottom'
%   variable since some layers can accept inputs from several different
%   layers. 
%   
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

    function caffe_save_net_head( file_id, str_in, indent, indent_cur)
        %Saving the name as a first parameter (some minor fool-proof)
        caffe_save_net_param( file_id, str_in.name, 'name', '', indent_cur);
        str_in = rmfield( str_in, 'name');
        
        %Saving the rest of parameters
        parameter_names = fieldnames(str_in);
        for var_i=1:length(parameter_names) 
%             fprintf('Field name = %s \n', parameter_names{var_i} );
            var_type = caffe_var_type( str_in.(parameter_names{var_i}) );
            switch var_type
                case 0
                    caffe_save_net_param(file_id, str_in.(parameter_names{var_i}), parameter_names{var_i}, '', indent_cur );
                case 1
                    caffe_save_net_str  (file_id, str_in.(parameter_names{var_i}), parameter_names{var_i}, indent, indent_cur );
                case 2
                    caffe_save_net_cell (file_id, str_in.(parameter_names{var_i}), parameter_names{var_i}, '', indent, indent_cur);
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
                    caffe_save_net_cell (file_id, str_in.(parameter_names{var_i}), parameter_names{var_i}, str_name, indent, [indent_cur indent]);
            end            
        end
        fprintf(file_id, '%s}\n', indent_cur);
    end

    function caffe_save_net_cell(file_id, cell_in, cell_name, parent_name, indent, indent_cur)
        for cell_i=1:length(cell_in)
            var_type = caffe_var_type( cell_in{cell_i} );
            switch var_type
                case 0
                    caffe_save_net_param(file_id, cell_in{cell_i}, cell_name, parent_name, indent_cur );
                case 1
                    caffe_save_net_str  (file_id, cell_in{cell_i}, cell_name, indent, indent_cur);
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
    fprintf('%s : saving header ... \n', mfilename);
    caffe_save_net_head( fileID, header, indent, indent_cur);
    
    % Iterate through layers writing them into the file
    fprintf('%s : saving body and loss ... \n', mfilename);
    for layer_i=1:length(net_descr)
        if isfield(net_descr{layer_i}, 'name')
            fprintf('Layer %d: name = %s ...\n', layer_i, net_descr{layer_i}.name );
        else
            fprintf('Layer %d ... \n', layer_i);
        end
        caffe_save_net_str( fileID, net_descr{layer_i}, 'layer', indent, indent_cur);
    end

    fclose(fileID);
end


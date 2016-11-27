function [ out ] = caffe_write_solverprototxt( filename, solver_descr )
%% Description:
% write prototxt file from 
% caffe_write_solverprototxt( solver_descr )
% --- INPUTS:
% filename = filename to save (*.prototxt will be added automatically if absent)
% solver_descr = structure with properties you want to write
% IMPORTANT: 
% - field "solver_mode" should be 0/1, where 0 = cpu, 1 = gpu
%% Parameters


%% Execution:
% Cut the extension
extension = '.prototxt';
if length(filename ) >= 10
    if strcmp( filename(end-8:end), extension)
        filename = filename(1:end-9);
    end
end
        
fileID = fopen( [filename extension], 'w');

parameter_names = fieldnames(solver_descr);
for var_i=1:length(parameter_names)
   is_solvermode =  strcmp( 'solver_mode', parameter_names{var_i} );
   is_logical = any(strcmp( {'true', 'false'}, solver_descr.(parameter_names{var_i})));
   num = str2double( solver_descr.(parameter_names{var_i}) );
   
   if is_logical || is_solvermode || ~isnan(num)
      fprintf(fileID, '%s : %s\n', parameter_names{var_i}, solver_descr.(parameter_names{var_i}) ); 
   else
      fprintf(fileID, '%s : \"%s\"\n', parameter_names{var_i}, solver_descr.(parameter_names{var_i}) ); 
   end
   
end

fclose(fileID);

% Checking that the file is fine
fprintf('%s : \n', [filename extension] );
fprintf('-------------------\n');
fid = fopen( [filename extension] );
tline = fgets(fid);
while ischar(tline)
    fprintf('%s', tline);
    tline = fgets(fid);
end
fclose(fid);

end


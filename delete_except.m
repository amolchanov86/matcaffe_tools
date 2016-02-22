function [ files_deleted ] = delete_except( pattern, file_exc )
[yourfolder name ext]= fileparts(pattern);
f=dir(pattern);
% f = f_temp;
% f_cur_i = 0;
% for f_i=1:numel(f_temp)
%     if ~(f_temp(f_i).isdir)
%         f_cur_i = f_cur_i + 1;
%         f(f_cur_i) = f_temp(f_i);
%     end
% end
% f = f(1:f_cur_i);
f={f.name};
n=find( strcmp(f, file_exc) );
if ~isempty(n)
    f(n)=[];
end
files_deleted = numel(f);
for k=1:files_deleted;
%     fprintf('%s : fk = %s \n', mfilename, f{k});
    delete([yourfolder '/' f{k}]);
end
end


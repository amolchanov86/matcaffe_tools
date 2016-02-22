function [ train_res, test_res ] = caffe_log_proc( log_filename )
%% Description
% processing log files produced by caffe in the shell
% [ train_res, test_res ] = caffe_log_proc( log_filename )

%% Parameters
lines_prealloc = int32(1000000);
iter_keyword = 'Iteration';
testing_keyword = 'Testing';
loss_keyword='loss';
accuracy_keyword='accuracy';
lr_keyword = 'lr';

%% Execution
%---Read all lines
fid = fopen(log_filename);
lines{lines_prealloc} = '';
line_i = 1;
lines{line_i} = fgets(fid);
while ischar( lines{line_i} )
    line_i = line_i + 1;
    lines{line_i} = fgets(fid);
end
lines_num = line_i - 1;
lines = lines(1:lines_num);
%cause the last one is not a character
%using normal braces to get subarray and not values

fclose(fid);

%---Line analisis
%Preallocate cell arrays
train_res{lines_num} = 0;
test_res{lines_num} = 0;

line_i = 1;
train_i = 1;
test_i = 1;

train_res{train_i}.iter = 0;
test_res{test_i}.iter = 0;


% fprintf('%s : lines_num = %d ...\n', mfilename, lines_num);

while line_i < lines_num
    words = strsplit(lines{line_i}, ' ');
    kw_pos = get_word_pos(words, {iter_keyword, testing_keyword, loss_keyword, lr_keyword} );
   
    if kw_pos{1}(1) > 0
        iter_val_str = words{kw_pos{1}(1) + 1};
        iter_val_str = strrep(iter_val_str, ',' , '');
        iter_val = str2num(iter_val_str);
        if kw_pos{2}(1) > 0
            
            if test_res{test_i}.iter < iter_val && test_res{test_i}.iter > 0
                test_i = test_i+1;
            end
            
            test_res{test_i}.iter = iter_val;
            
            % Exctract accuracy and loss values
            words = strsplit(lines{line_i+1}, ' ');
            accuracy_pos = get_word_pos(words, {accuracy_keyword}); %accuracy should be on the next line
            accuracy_val = str2num(words{accuracy_pos{1}(1) + 2});
            
            words = strsplit(lines{line_i+2}, ' ');
            loss_pos = get_word_pos(words, {loss_keyword}); %loss should be on the 2nd line
            loss_val = str2num(words{loss_pos{1}(1) + 2});
%             fprintf('%s : loss_test_val = %f \n', mfilename, loss_val);
            
            test_res{test_i}.loss = loss_val;
            test_res{test_i}.accuracy = accuracy_val;
%             fprintf('%s : accuracy_test_val = %f \n', mfilename, accuracy_val);
            
            line_i = line_i+2; %Skipping the next 2 lines
        else
            if train_res{train_i}.iter < iter_val && train_res{train_i}.iter > 0
                train_i = train_i+1;
            end
            
            % Exctract loss value
            train_res{train_i}.iter = iter_val;
            
            if kw_pos{3}(1) > 0 %loss
                loss_pos =  kw_pos{3}(1) + 2;
                loss_val = str2num(words{loss_pos});
                train_res{train_i}.loss = loss_val;
%                 fprintf('%s : loss_val = %f \n', mfilename, loss_val);
            elseif kw_pos{4}(1) > 0 %lr
                lr_pos = kw_pos{4}(1) + 2;
                lr_val = str2num(words{lr_pos});
                train_res{train_i}.lr = lr_val;
%                 fprintf('%s : lr_val = %f \n', mfilename, lr_val);
            end
        end
        
    end
    line_i = line_i+1;
    
end

train_res = train_res(1:train_i);
test_res = test_res(1:test_i);

fprintf('%s : file_name = %s , lines_num = %d , train_iter_num = %d , test_iter_num = %d \n', mfilename, log_filename, lines_num, length(train_res), length(test_res) );

end


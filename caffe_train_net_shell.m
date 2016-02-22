function [ best_accuracy, best_iter, stat ] = caffe_train_net_shell( solver_filename, best_snapshot_prefix, varargin )
%% Description:
% training with saving best snapshot using shell (since I have problems
% with matcaffe reporting wrong accuracy)
% WARNING: for now, make sure that testing and saving of snapshots happens
% with the same interval
% [ best_accuracy, best_iter, stat ] = caffe_train_net_shell( solver_filename, best_snapshot_prefix, [log_filename], [clear_other_snapshots = 1] )
% --- INPUT:
% solver_filename = solver to use
% best_snapshot_prefix = all temporary snapshots will be saved with the
%   prefix reported in solver protobuf file, but at the end they all be
%   erased except the one with the best accuracy, which will be moved
%   (renamed) according to the best_snapshot_prefix
% --- OPTIONAL
% log_filename = log with training losses/accuracies reported
% clear_other_snapshots = deletes non best snapshots at the end (warning:
%   be careful. Make sure that the folder where you are saving temporary
%   snapshots does not contain important snapshots)
% --- OUTPUT
% best_accuracy = best accuracy
% best_iter = best iteration
% stat = contains losses reported during training (from parsing the log
% file)

%% Parameters


%% Arguments
var_i = 1;
[snap_p] = fileparts(best_snapshot_prefix);
log_filename = [ snap_p '/training_log.txt' ];
if length(varargin) >= var_i
    log_filename = varargin{var_i};
else
    if ~exist(snap_p, 'dir')
        fprintf('WARNING: %s : Dir = %s didnt exist, so it was created ...\n', ...
            mfilename, ...
            snap_p);
        mkdir(snap_p);
    end
end
fprintf('%s : log filename = %s \n', mfilename, log_filename);

var_i = 2;
clear_other_snapshots = 1;
if length(varargin) >= var_i
    clear_other_snapshots = varargin{var_i};
end

%% Execution
solver_params = caffe_read_solverprototxt(solver_filename);
% solver_params.snapshot_prefix;

% --- Run training
system(['caffe train --solver=' solver_filename ' 2>' log_filename]);

% --- Analyze log file
[stat.train, test_stat] = caffe_log_proc(log_filename);

% --- Pick best iteration
best_iter_i = 0;
best_iter = 0;
best_accuracy = 0;
for i=1:length(test_stat)
    if (test_stat{i}.accuracy > best_accuracy) || (best_iter == 0)
        best_accuracy =  test_stat{i}.accuracy;
        best_iter_i = i;
        best_iter = test_stat{i}.iter;
    end
end

model_ext = '.caffemodel';
solver_ext = '.solverstate';

best_snapshot_temp_name = sprintf('%s_iter_%d', ...
    solver_params.snapshot_prefix, ...
    best_iter );
best_snapshot_name = sprintf('%s__iter_%06d__acc_%5.3f', ...
    best_snapshot_prefix, ...
    best_iter, ...
    best_accuracy );

stat.best_snapshot_name = [best_snapshot_name model_ext];
[best_snapshot_path best_snapshot_name_only best_snapshot_ext_only] = fileparts(best_snapshot_name);
best_snapshot_name_only = [best_snapshot_name_only best_snapshot_ext_only];
%because sometimes snapshot prefix contains '.' and fileparts thinks it is
%an extension

% --- Creating folders if they don't exist
snap_p = fileparts(best_snapshot_name);

if ~exist(snap_p, 'dir')
    fprintf('WARNING: %s : Dir = %s didnt exist, so it was created ...\n', ...
        mfilename, ...
        snap_p);
    mkdir(snap_p);
end

% --- Rename files with the best iteration
fprintf('%s : renaming %s to %s \n', mfilename, [best_snapshot_temp_name model_ext], stat.best_snapshot_name);
movefile( [best_snapshot_temp_name model_ext], ...
    stat.best_snapshot_name );

fprintf('%s : renaming %s to %s \n', mfilename, [best_snapshot_temp_name solver_ext], [best_snapshot_name solver_ext]);
movefile( [best_snapshot_temp_name solver_ext] , ...
    [best_snapshot_name solver_ext]);

% --- Delete non best snapshots
if clear_other_snapshots
%     system( ['rm -rf ' solver_params.snapshot_prefix '*' model_ext ] );
%     system( ['rm -rf ' solver_params.snapshot_prefix '*' solver_ext ] );
    delete_except( [solver_params.snapshot_prefix '*' model_ext],  [ best_snapshot_name_only model_ext] );
    delete_except( [solver_params.snapshot_prefix '*' solver_ext], [ best_snapshot_name_only solver_ext] );
end

% --- Copy data to stat
iterations_num = length(test_stat);
stat.accuracy = zeros(1, iterations_num);
stat.iterations = zeros(1, iterations_num);
stat.loss = zeros(1, iterations_num);

stat.loss_train = zeros(1 , length(length(stat.train)) );
stat.iterations_train = zeros(1 , length(length(stat.train)) );

for iter_i=1:length(stat.train)
    stat.loss_train(iter_i) = stat.train{iter_i}.loss;
    stat.iterations_train(iter_i) = stat.train{iter_i}.iter;
end

for iter_i=1:iterations_num
    stat.accuracy(iter_i) = test_stat{iter_i}.accuracy;
    stat.iterations(iter_i) = test_stat{iter_i}.iter;
    stat.loss_test(iter_i) = test_stat{iter_i}.loss;
    stat.loss(iter_i) = ...
        stat.loss_train( stat.iterations_train == stat.iterations(iter_i) );
end

end


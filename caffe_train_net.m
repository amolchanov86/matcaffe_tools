%% Description
% The training wrapper for caffe
% [ best_accuracy, best_iter, stat ] = caffe_train_net( solver_filename, best_snapshot_prefix, gpu_mode )
% --- INPUTS
% solver_filename = filename of the solver used
% best_snapshot_prefix = prefix (with the full path) for the best snapshots
% gpu_mode = gpu or cpu mode:
%   0 = cpu
%   1 = gpu
% --- OUTPUTS
% accuracy = vector of accuracies observed
% iterations = iterations at which the accuracies were observed
% best_accuracy = best accuracy
% best_iter = iteration at which the best accuracy was observed
% stat = other statistics

%% Remarks:
% if you don't want to save intermediate results set max_iter property of
% the solver to some very high value
%% Execution
function [ best_accuracy, best_iter, stat ] = caffe_train_net( solver_filename, best_snapshot_prefix, gpu_mode )
    caffe.reset_all();
    
    if gpu_mode
        caffe.set_mode_gpu();
    else
        caffe.set_mode_cpu();
    end
    
    solver_props = caffe_read_solverprototxt(solver_filename);
    test_interval = str2num( solver_props.test_interval );
    max_iter = str2num(solver_props.max_iter);
    
    %Load the solver
    solver = caffe.Solver(solver_filename);
    
    %Init vars
    steps_num = int32( max_iter / test_interval);
    stat.accuracy = zeros([1,steps_num]);
    stat.iterations = zeros([1,steps_num]);
    stat.loss = zeros([1,steps_num]);
    
    best_accuracy = solver.test_nets(1).blobs('accuracy').get_data();
    best_iter = 0;
    best_net = solver.net;
    
    %Iterate
    step_i = 0;
    while solver.iter < max_iter
        step_i = step_i + 1;
        solver.step(test_interval);
        stat.accuracy(step_i) = solver.test_nets(1).blobs('accuracy').get_data();
        stat.loss(step_i) = solver.net(1).blobs('loss').get_data();
        stat.iterations(step_i) = solver.iter;
        
        if stat.accuracy(step_i) > best_accuracy
           best_net  = solver.net;
           best_accuracy = stat.accuracy(step_i);
           best_iter = solver.iter;
        end
        
        fprintf('Iter = %d TRAIN: loss = %e VAL: Accuracy: cur = %f best: %f (iter: %d) \n', ...
            solver.iter, stat.loss(step_i), stat.accuracy(step_i), best_accuracy, best_iter );
    end
    
    % Results
    %[best_accuracy, best_indx] = max(accuracy);
    %best_iter = iterations(best_indx);
    
    % Saving the best snapshot
    best_net.save([best_snapshot_prefix sprintf('__iter_%06d__acc_%5.3f.caffemodel', best_iter, best_accuracy) ]);
    
end


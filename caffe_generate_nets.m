function caffe_generate_nets( filename, full_descr )
%% Description:
% The function generates train/val and deploy files from a special
% structure describing train/val and deployment net models
% --- INPUTS:
% caffe_generate_nets( filename, full_descr )
% filename = file name base (IMPORTANT: without extension !)
% full_descr = consists of several structures:
%  - head = header for training/validation
%  - head_deploy = header for deployment
%  - body = body of the net model (without loss layers). It is a cell array
%  - loss = loss layers for traiing/validation. It is a cell array
%  - loss_deploy = loss layers for deployment (usually don't contain
%    labels). It is a cell array
%% Execution:

% Generating training/validation net model
caffe_save_net(filename, full_descr.head, [full_descr.body(:); full_descr.loss(:)] );

% Generating deployment model
caffe_save_net([filename '_deploy'], full_descr.head_deploy, [full_descr.body(:); full_descr.loss_deploy(:)] );


end


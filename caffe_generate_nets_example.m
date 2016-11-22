%% Description:
% Test for caffe_save_net function

%% Parameters:

%% Execution:
clear all;

% --- Building the net
%% --- Headers
net_indx = '01_test';
net_filename = ['net_poke_cnn' net_indx];

% --- Data train/val
net_descr.head.name = net_filename;

head_indx = 0;
head_indx = head_indx + 1;
net_descr.head.layer{head_indx} = caffe_layer_data_def( 'hdf5', 1); %Train
net_descr.head.layer{head_indx}.hdf5_data_param.batch_size = 256;

head_indx = head_indx + 1;
net_descr.head.layer{head_indx} = caffe_layer_data_def( 'hdf5', 0); %Validation
net_descr.head.layer{head_indx}.hdf5_data_param.batch_size = 153;

% --- Data deploy
net_descr.head_deploy.name = net_filename;
net_descr.head_deploy.input = 'data';
net_descr.head_deploy.input_shape.dim{1} = 1;
net_descr.head_deploy.input_shape.dim{2} = 1;
net_descr.head_deploy.input_shape.dim{3} = 57;
net_descr.head_deploy.input_shape.dim{4} = 31;

% input: "data"
% input_shape {
%   dim: 1
%   dim: 1
%   dim: 57
%   dim: 31
% }

%% --- Body
% --- Conv 0
block_indx = 0; %For every block of layers, example: {FC + ReLU + Dropout}  
net_descr.body{1} = caffe_layer_conv_def( block_indx, 'data', -1, 64, true, ...
    'kernel_h', 1, 'kernel_w', 2);

net_descr.body{end+1} = caffe_layer_relu_def( block_indx,  net_descr.body{end}.top );
net_descr.body{end+1} = caffe_layer_pool_def( block_indx, net_descr.body{end}.top, -1, ...
    'kernel_h', 1, 'kernel_w', 2, 'stride_h', 1, 'stride_w', 2);

% --- Conv 1
block_indx = block_indx + 1;
net_descr.body{end+1} = caffe_layer_conv_def( block_indx, net_descr.body{end}.top, -1, 128, true, ...
    'kernel_h', 1, 'kernel_w', 2);
net_descr.body{end+1} = caffe_layer_relu_def( block_indx,  net_descr.body{end}.top );
net_descr.body{end+1} = caffe_layer_pool_def( block_indx,  net_descr.body{end}.top, -1, ...
    'kernel_h', 1, 'kernel_w', 2, 'stride_h', 1, 'stride_w', 2);

% --- Conv 2
block_indx = block_indx + 1;
net_descr.body{end+1} = caffe_layer_conv_def( block_indx, net_descr.body{end}.top, -1, 128, true, ...
    'kernel_h', 1, 'kernel_w', 2);
net_descr.body{end+1} = caffe_layer_relu_def( block_indx, net_descr.body{end}.top );
net_descr.body{end+1} = caffe_layer_pool_def( block_indx, net_descr.body{end}.top , -1, ...
    'kernel_h', 1, 'kernel_w', 2, 'stride_h', 1, 'stride_w', 2);

% --- Conv 3
block_indx = block_indx + 1;
net_descr.body{end+1} = caffe_layer_conv_def( block_indx, net_descr.body{end}.top, -1, 128, true, ...
    'kernel_h', 57, 'kernel_w', 1);
net_descr.body{end+1} = caffe_layer_relu_def( block_indx,  net_descr.body{end}.top );

% --- FC 4
net_descr.body{end+1} = caffe_layer_fc_def( block_indx, net_descr.body{end}.name, 256, true);
net_descr.body{end+1} = caffe_layer_relu_def( block_indx,  net_descr.body{end}.top );
net_descr.body{end+1} = caffe_layer_drop_def( block_indx );

% --- FC 5
block_indx = block_indx + 1;
net_descr.body{end+1} = caffe_layer_fc_def( block_indx , net_descr.body{end}.top, 256, true);

%% --- Footer (losses and accuracies)
% --- Train/Val
net_descr.loss{1} = caffe_layer_accuracy_def( 'accuracy', net_descr.body{end}.top );
net_descr.loss{2} = caffe_layer_loss_def( 'loss', {net_descr.body{end}.top, 'label'} );

% --- Deploy
net_descr.loss_deploy{1} = caffe_layer_loss_def( 'prob', net_descr.body{end}.top );
net_descr.loss_deploy{1}.type = 'Softmax';

%% Saving the whole thing
% caffe_save_net( net_filename, net_header, net_descr.body );
caffe_generate_nets(net_filename, net_descr);
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
lay_indx = 0;%Index of every layer
lay_indx = lay_indx + 1;
block_indx = 0; %For every block of layers, example: {FC + ReLU + Dropout}  
net_descr.body{lay_indx} = caffe_layer_conv_def( block_indx );
net_descr.body{lay_indx}.bottom = 'data';
net_descr.body{lay_indx}.convolution_param.num_output = 64;
net_descr.body{lay_indx}.convolution_param.kernel_h = 1;
net_descr.body{lay_indx}.convolution_param.kernel_w = 2;
net_descr.body{lay_indx}.convolution_param.stride_h = 1;
net_descr.body{lay_indx}.convolution_param.stride_w = 1;

lay_indx = lay_indx + 1;
net_descr.body{lay_indx} = caffe_layer_relu_def( block_indx,  net_descr.body{lay_indx-1}.name );

lay_indx = lay_indx + 1;
net_descr.body{lay_indx} = caffe_layer_pool_def( block_indx );
net_descr.body{lay_indx}.pooling_param.kernel_h = 1;
net_descr.body{lay_indx}.pooling_param.kernel_w = 2;
net_descr.body{lay_indx}.pooling_param.stride_h = 1;
net_descr.body{lay_indx}.pooling_param.stride_w = 2;

% --- Conv 1
lay_indx = lay_indx + 1;
block_indx = block_indx + 1;
net_descr.body{lay_indx} = caffe_layer_conv_def( block_indx );
net_descr.body{lay_indx}.bottom = sprintf('pool%d', block_indx - 1);
net_descr.body{lay_indx}.convolution_param.num_output = 128;
net_descr.body{lay_indx}.convolution_param.kernel_h = 1;
net_descr.body{lay_indx}.convolution_param.kernel_w = 2;
net_descr.body{lay_indx}.convolution_param.stride_h = 1;
net_descr.body{lay_indx}.convolution_param.stride_w = 1;

lay_indx = lay_indx + 1;
net_descr.body{lay_indx} = caffe_layer_relu_def( block_indx,  net_descr.body{lay_indx-1}.name );

lay_indx = lay_indx + 1;
net_descr.body{lay_indx} = caffe_layer_pool_def( block_indx );
net_descr.body{lay_indx}.pooling_param.kernel_h = 1;
net_descr.body{lay_indx}.pooling_param.kernel_w = 2;
net_descr.body{lay_indx}.pooling_param.stride_h = 1;
net_descr.body{lay_indx}.pooling_param.stride_w = 2;

% --- Conv 2
lay_indx = lay_indx + 1;
block_indx = block_indx + 1;
net_descr.body{lay_indx} = caffe_layer_conv_def( block_indx );
net_descr.body{lay_indx}.bottom = sprintf('pool%d', block_indx - 1);
net_descr.body{lay_indx}.convolution_param.num_output = 128;
net_descr.body{lay_indx}.convolution_param.kernel_h = 1;
net_descr.body{lay_indx}.convolution_param.kernel_w = 2;
net_descr.body{lay_indx}.convolution_param.stride_h = 1;
net_descr.body{lay_indx}.convolution_param.stride_w = 1;

lay_indx = lay_indx + 1;
net_descr.body{lay_indx} = caffe_layer_relu_def( block_indx,  net_descr.body{lay_indx-1}.name );

lay_indx = lay_indx + 1;
net_descr.body{lay_indx} = caffe_layer_pool_def( block_indx );
net_descr.body{lay_indx}.pooling_param.kernel_h = 1;
net_descr.body{lay_indx}.pooling_param.kernel_w = 2;
net_descr.body{lay_indx}.pooling_param.stride_h = 1;
net_descr.body{lay_indx}.pooling_param.stride_w = 2;

% --- Conv 3
lay_indx = lay_indx + 1;
block_indx = block_indx + 1;
net_descr.body{lay_indx} = caffe_layer_conv_def( block_indx );
net_descr.body{lay_indx}.bottom = sprintf('pool%d', block_indx - 1);
net_descr.body{lay_indx}.convolution_param.num_output = 128;
net_descr.body{lay_indx}.convolution_param.kernel_h = 57;
net_descr.body{lay_indx}.convolution_param.kernel_w = 1;
net_descr.body{lay_indx}.convolution_param.stride_h = 1;
net_descr.body{lay_indx}.convolution_param.stride_w = 1;

lay_indx = lay_indx + 1;
net_descr.body{lay_indx} = caffe_layer_relu_def( block_indx,  net_descr.body{lay_indx-1}.name );

% --- FC 4
lay_indx = lay_indx + 1;
block_indx = block_indx + 1;
net_descr.body{lay_indx} = caffe_layer_fc_def( block_indx );
net_descr.body{lay_indx}.bottom = sprintf('conv%d', block_indx - 1);
net_descr.body{lay_indx}.inner_product_param.num_output = 256;

lay_indx = lay_indx + 1;
net_descr.body{lay_indx} = caffe_layer_relu_def( block_indx,  net_descr.body{lay_indx-1}.name );

lay_indx = lay_indx + 1;
net_descr.body{lay_indx} = caffe_layer_drop_def( block_indx );

% --- FC 5
lay_indx = lay_indx + 1;
block_indx = block_indx + 1;
net_descr.body{lay_indx} = caffe_layer_fc_def( block_indx );
net_descr.body{lay_indx}.bottom = sprintf('fc%d', block_indx - 1);
net_descr.body{lay_indx}.inner_product_param.num_output = 256;

%% --- Footer (losses and accuracies)
% --- Train/Val
loss_indx = 0;
loss_indx = loss_indx + 1;
net_descr.loss{loss_indx} = caffe_layer_accuracy_def( net_descr.body{end}.top );

loss_indx = loss_indx + 1;
net_descr.loss{loss_indx} = caffe_layer_loss_def( net_descr.body{end}.top );

% --- Deploy
loss_indx = 0;
loss_indx = loss_indx + 1;
net_descr.loss_deploy{loss_indx} = caffe_layer_loss_def( net_descr.body{end}.top );
net_descr.loss_deploy{loss_indx}.name = 'prob';
net_descr.loss_deploy{loss_indx}.type = 'Softmax';
net_descr.loss_deploy{loss_indx}.bottom = net_descr.body{end}.top;

%% Saving the whole thing
% caffe_save_net( net_filename, net_header, net_descr.body );
caffe_generate_nets(net_filename, net_descr);


%% Description:
% Test for caffe_save_net function

%% Parameters:

%% Execution:
clear all;

% --- Building the net
net_filename = 'net_poke_test_auto';
net_header.name = 'TestNet';

% --- Data
lay_indx = 1;
net_descr{lay_indx} = caffe_layer_data_def( 'hdf5', 1); %Train
net_descr{lay_indx}.hdf5_data_param.batch_size = 256;

lay_indx = lay_indx + 1;
net_descr{lay_indx} = caffe_layer_data_def( 'hdf5', 0); %Validation
net_descr{lay_indx}.hdf5_data_param.batch_size = 153;

% --- Conv 0
lay_indx = lay_indx + 1;
block_indx = 0;
net_descr{lay_indx} = caffe_layer_conv_def( block_indx );
net_descr{lay_indx}.bottom = 'data';
net_descr{lay_indx}.convolution_param.num_output = 64;
net_descr{lay_indx}.convolution_param.kernel_h = 1;
net_descr{lay_indx}.convolution_param.kernel_w = 2;
net_descr{lay_indx}.convolution_param.stride_h = 1;
net_descr{lay_indx}.convolution_param.stride_w = 1;

lay_indx = lay_indx + 1;
net_descr{lay_indx} = caffe_layer_relu_def( block_indx,  net_descr{lay_indx-1}.name );

lay_indx = lay_indx + 1;
net_descr{lay_indx} = caffe_layer_pool_def( block_indx );
net_descr{lay_indx}.pooling_param.kernel_h = 1;
net_descr{lay_indx}.pooling_param.kernel_w = 2;
net_descr{lay_indx}.pooling_param.stride_h = 1;
net_descr{lay_indx}.pooling_param.stride_w = 2;

% --- Conv 1
lay_indx = lay_indx + 1;
block_indx = block_indx + 1;
net_descr{lay_indx} = caffe_layer_conv_def( block_indx );
net_descr{lay_indx}.bottom = sprintf('pool%d', block_indx - 1);
net_descr{lay_indx}.convolution_param.num_output = 128;
net_descr{lay_indx}.convolution_param.kernel_h = 1;
net_descr{lay_indx}.convolution_param.kernel_w = 2;
net_descr{lay_indx}.convolution_param.stride_h = 1;
net_descr{lay_indx}.convolution_param.stride_w = 1;

lay_indx = lay_indx + 1;
net_descr{lay_indx} = caffe_layer_relu_def( block_indx,  net_descr{lay_indx-1}.name );

lay_indx = lay_indx + 1;
net_descr{lay_indx} = caffe_layer_pool_def( block_indx );
net_descr{lay_indx}.pooling_param.kernel_h = 1;
net_descr{lay_indx}.pooling_param.kernel_w = 2;
net_descr{lay_indx}.pooling_param.stride_h = 1;
net_descr{lay_indx}.pooling_param.stride_w = 2;

% --- Conv 2
lay_indx = lay_indx + 1;
block_indx = block_indx + 1;
net_descr{lay_indx} = caffe_layer_conv_def( block_indx );
net_descr{lay_indx}.bottom = sprintf('pool%d', block_indx - 1);
net_descr{lay_indx}.convolution_param.num_output = 128;
net_descr{lay_indx}.convolution_param.kernel_h = 1;
net_descr{lay_indx}.convolution_param.kernel_w = 2;
net_descr{lay_indx}.convolution_param.stride_h = 1;
net_descr{lay_indx}.convolution_param.stride_w = 1;

lay_indx = lay_indx + 1;
net_descr{lay_indx} = caffe_layer_relu_def( block_indx,  net_descr{lay_indx-1}.name );

lay_indx = lay_indx + 1;
net_descr{lay_indx} = caffe_layer_pool_def( block_indx );
net_descr{lay_indx}.pooling_param.kernel_h = 1;
net_descr{lay_indx}.pooling_param.kernel_w = 2;
net_descr{lay_indx}.pooling_param.stride_h = 1;
net_descr{lay_indx}.pooling_param.stride_w = 2;

% --- Conv 3
lay_indx = lay_indx + 1;
block_indx = block_indx + 1;
net_descr{lay_indx} = caffe_layer_conv_def( block_indx );
net_descr{lay_indx}.bottom = sprintf('pool%d', block_indx - 1);
net_descr{lay_indx}.convolution_param.num_output = 128;
net_descr{lay_indx}.convolution_param.kernel_h = 57;
net_descr{lay_indx}.convolution_param.kernel_w = 1;
net_descr{lay_indx}.convolution_param.stride_h = 1;
net_descr{lay_indx}.convolution_param.stride_w = 1;

lay_indx = lay_indx + 1;
net_descr{lay_indx} = caffe_layer_relu_def( block_indx,  net_descr{lay_indx-1}.name );

% --- FC 4
lay_indx = lay_indx + 1;
block_indx = block_indx + 1;
net_descr{lay_indx} = caffe_layer_fc_def( block_indx );
net_descr{lay_indx}.bottom = sprintf('conv%d', block_indx - 1);
net_descr{lay_indx}.inner_product_param.num_output = 256;

lay_indx = lay_indx + 1;
net_descr{lay_indx} = caffe_layer_relu_def( block_indx,  net_descr{lay_indx-1}.name );

lay_indx = lay_indx + 1;
net_descr{lay_indx} = caffe_layer_drop_def( block_indx );

% --- FC 5
lay_indx = lay_indx + 1;
block_indx = block_indx + 1;
net_descr{lay_indx} = caffe_layer_fc_def( block_indx );
net_descr{lay_indx}.bottom = sprintf('fc%d', block_indx - 1);
net_descr{lay_indx}.inner_product_param.num_output = 256;

% --- Accuracy & Loss
lay_indx = lay_indx + 1;
net_descr{lay_indx} = caffe_layer_accuracy_def( net_descr{lay_indx - 1}.top );

lay_indx = lay_indx + 1;
net_descr{lay_indx} = caffe_layer_loss_def( net_descr{lay_indx - 2}.top );

%% Saving the whole thing
caffe_save_net( net_filename, net_header, net_descr );


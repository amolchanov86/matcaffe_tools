addpath('/home/yossi/Dev/matcaffe_tools');

imagenet_data_dir = '/home/gpu-admin/data/ImageNet_preprocessed';

%% constants (we use grayscale & resized images with maximal height/width of 128)
net_name = 'SqueezeNet_v1.1_grayscale_128px';
output_dir = net_name;
mkdir(output_dir);
crop_size = 128;

% layer parameters
conv1 = [3 64];
pool_layers = [1 3 5];

% fire modules parameters
E_i = [128 128 192 192 256 256 512 512];
SR = 0.125;
pct_3x3 = 0.5;
E_1x1 = (1 - pct_3x3) * E_i;
E_3x3 = pct_3x3 * E_i;
S_1x1 = SR * E_i;

%% create model SqueezeNet_v1.1 for ImageNet classification task
net_descr = struct('head', struct('name', net_name), 'body', []);
net_descr.head_deploy = net_descr.head;
net_descr.body = {};

% data_layers (ImageNet train & test set)
net_descr.head.layer{1} = caffe_layer_data_def('lmdb', 1); %Train
net_descr.head.layer{1}.data_param.source = fullfile(imagenet_data_dir, 'ilsvrc12_train_lmdb');
net_descr.head.layer{1}.data_param.batch_size = 512;
net_descr.head.layer{1}.transform_param.crop_size = crop_size;
net_descr.head.layer{1}.transform_param.mean_value = 117;
    
net_descr.head.layer{2} = caffe_layer_data_def('lmdb', 0); %Validation
net_descr.head.layer{2}.data_param.source = fullfile(imagenet_data_dir, 'ilsvrc12_val_lmdb');
net_descr.head.layer{2}.data_param.batch_size = 512;
net_descr.head.layer{2}.transform_param.crop_size = crop_size;
net_descr.head.layer{2}.transform_param.mean_value = 117;

% --- Data deploy
net_descr.head_deploy.input = 'data';
net_descr.head_deploy.input_shape.dim = {1, 1, crop_size, crop_size};

% conv1 --> pool1
net_descr.body{end+1} = caffe_layer_conv_def('conv1', 'data', conv1(1), conv1(2), false, 'stride', 2);
net_descr.body{end+1} = caffe_layer_relu_def('relu_conv1', 'conv1');
net_descr.body{end+1} = caffe_layer_pool_def('pool1', 'conv1', 3, 'stride', 2);

% putting all fire modules
fire_layer_num = 1;
last_layer_blob = 'pool1';
while (fire_layer_num <= length(S_1x1))
    layer_index = fire_layer_num + 1;
    net_descr.body{end+1} = caffe_layer_fire_def(sprintf('fire%d', layer_index), last_layer_blob, ...
        S_1x1(fire_layer_num), E_1x1(fire_layer_num), E_3x3(fire_layer_num), false);
    last_layer_blob = net_descr.body{end}{end}.top;
    if ismember(layer_index, pool_layers)
        pool_name = sprintf('pool%d', layer_index);
        net_descr.body{end+1} = caffe_layer_pool_def(pool_name, ...
            last_layer_blob, 3, 'stride', 2);
        last_layer_blob = pool_name;
    end
    fire_layer_num = fire_layer_num + 1;
end

% dropout 
net_descr.body{end+1} = caffe_layer_drop_def('drop9', last_layer_blob);
% classification branch (conv --> average pooling)
net_descr.body{end+1} = caffe_layer_conv_def('conv10', 'fire9/concat', 1, 1000, false);
net_descr.body{end}.convolution_param.weight_filler = ...
    struct('type', 'gaussian', 'mean', 0.0, 'std', 0.01);

net_descr.body{end+1} = caffe_layer_relu_def('relu_conv10', 'conv10');
net_descr.body{end+1} = caffe_layer_pool_def('pool10', 'conv10', 0); 
net_descr.body{end}.pooling_param = struct('pool', 'AVE', 'global_pooling', 'true');

%% --- Footer (losses and accuracies)
% --- Train/Val
net_descr.loss{1} = caffe_layer_loss_def('loss', {'pool10', 'label'});
net_descr.loss{2} = caffe_layer_accuracy_def('accuracy', {'pool10', 'label'});
net_descr.loss{3} = caffe_layer_accuracy_def('accuracy_top5', {'pool10', 'label'});

net_descr.loss{3}.accuracy_param = struct('top_k', 5);
net_descr.loss{2} = rmfield(net_descr.loss{2}, 'include');
net_descr.loss{3} = rmfield(net_descr.loss{3}, 'include');
% --- Deploy
net_descr.loss_deploy{1} = caffe_layer_loss_def('prob', {'pool10'});
net_descr.loss_deploy{1}.type = 'Softmax';

%% Saving the whole thing
% caffe_save_net( net_filename, net_header, net_descr.body );
caffe_generate_nets(net_filename, net_descr);

% Generating training/validation net model
caffe_save_net(fullfile(output_dir, 'train_val.prototxt'), ...
    net_descr.head, [net_descr.body(:); net_descr.loss(:)] );

% Generating deployment model
caffe_save_net(fullfile(output_dir, 'deploy.prototxt'), ...
    net_descr.head_deploy, [net_descr.body(:); net_descr.loss_deploy(:)] );
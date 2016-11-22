function [ layer_cells ] = caffe_layer_fire_def( name, bottom, squeeze, expand1, expand3, add_mult, add_batch_norm )
%% Description
% Generates default Fire module (including several simple layers) given layer name
% The fire module was defined in this paper : 
%   Iandola, F.N., Moskewicz, M.W., Ashraf, K., Han, S., Dally, W.J., Keutzer, K.: 
%   Squeezenet: Alexnet-level accuracy with 50x fewer parameters and¡ 1mb model size. 
%   arXiv preprint arXiv:1602.07360 (2016)
% 
% --- INPUT:
%   name = layer name
%   bottom = bottom layer name
% --- OUTPUT:
%   layer_cells = cell array with the layers
%
%% Execution
layer_cells = {};
names = struct;
names.squeeze1 = [name '/squeeze1x1'];
names.squeeze1_relu = strrep(names.squeeze1, '/', '/relu_');
names.expand1 = [name '/expand1x1'];
names.expand3 = [name '/expand3x3'];
names.expand_relu = [name '/relu_concat'];
names.concat = [name '/concat'];

% squeeze1x1
blob_name = names.squeeze1;
layer_cells{end+1} = caffe_layer_conv_def(blob_name, bottom, 1, squeeze, add_mult);
if add_batch_norm
    % disable bias in previous conv layer
    % TODO : in case add_mult=true we might remove the relevant part for bias term
    layer_cells{end}.convolution_param.bias_term = 'false';
    
    bn_bottom = blob_name;
    blob_name = [blob_name '_bn'];
    layer_cells{end+1} = caffe_layer_batchnorm_def(blob_name, bn_bottom);
end
layer_cells{end+1} = caffe_layer_relu_def(names.squeeze1_relu, blob_name);

% expand1x1 & expand3x3
layer_cells{end+1} = caffe_layer_conv_def(names.expand1, names.squeeze1, 1, expand1, add_mult);
layer_cells{end+1} = caffe_layer_conv_def(names.expand3, names.squeeze1, 3, expand3, add_mult);
layer_cells{end+1} = caffe_layer_concat_def(names.concat, {names.expand1, names.expand3});

blob_name = layer_cells{end}.top;
if add_batch_norm
    % disable bias in previous conv layers
    % TODO : in case add_mult=true we might remove the relevant part for bias term
    layer_cells{end-2}.convolution_param.bias_term = 'false';
    layer_cells{end-1}.convolution_param.bias_term = 'false';
    
    bn_bottom = blob_name;
    blob_name = [bn_bottom '_bn'];
    layer_cells{end+1} = caffe_layer_batchnorm_def(blob_name, bn_bottom);
end
layer_cells{end+1} = caffe_layer_relu_def(names.expand_relu, blob_name);

% convert to flat cell array
layer_cells_ = layer_cells;
layer_cells = {};
for i_layer = 1:length(layer_cells_)
    layer_cells = [layer_cells layer_cells_{i_layer}];
end

end
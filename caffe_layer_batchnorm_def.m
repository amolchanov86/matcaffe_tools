function [ layer_cells ] = caffe_layer_batchnorm_def( name, bottom )
%% Description
% Generates Batch Normalization layer (actually it's composed of 2 caffe layers : BatchNorm & Scale)
% We implement batch normalization as described in :
%   S. Ioffe and C. Szegedy. Batch normalization: Accelerating
%   deep network training by reducing internal covariate shift. 
%   In arXiv:1502.03167, 2015
% 
% --- INPUT:
% indx = index for the layer
% --- OUTPUT:
% layer_cells = cell array with the 2 layers composing the batch normalization
%
%% Execution
% Layer 1 - BatchNorm
if isstr(name)
    layer_str1.name = name;
else
    layer_str1.name = sprintf('bn%d', name);
end
layer_str1.type = 'BatchNorm';
layer_str1.bottom = bottom;
layer_str1.top = layer_str1.name;

% Layer 2 - Scale
layer_str2.name = [layer_str1.name '_scale'];
layer_str2.type = 'Scale';
layer_str2.bottom = layer_str1.top;
layer_str2.top = layer_str1.top;
layer_str2.scale_param = struct('bias_term', 'true');

layer_cells = {layer_str1, layer_str2};

% layer {
%   name: "conv1_bn"
%   type: "BatchNorm"
%   bottom: "conv1"
%   top: "conv1_bn"
% }
% layer {
%   name: "conv1_bn_scale"   
%   type: "Scale"
%   bottom: "conv1_bn"
%   top: "conv1_bn"
%   scale_param {bias_term: true}
% }
end


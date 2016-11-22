function [ layer_str ] = caffe_layer_loss_def( name, bottom_names )
%% Description:
% default initialization of the Loss (SoftmaxWithLoss) layer
% --- INPUT:
% bottom_name = name of the bottom layer
% --- OUTPUT:
% layer_str = structure describing a layer
%
%% Execution:

layer_str.name = name;
layer_str.type = 'SoftmaxWithLoss';
layer_str.bottom = bottom_names;
layer_str.top = layer_str.name;

% layer {
%   name: "loss"
%   type: "SoftmaxWithLoss"
%   bottom: "fc7"
%   bottom: "label"
%   top: "loss"
% }

end


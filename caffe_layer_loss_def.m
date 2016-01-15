function [ layer_str ] = caffe_layer_loss_def( bottom_name )
%% Description:
% default initialization of the Loss (SoftmaxWithLoss) layer
% --- INPUT:
% bottom_name = name of the bottom layer
% --- OUTPUT:
% layer_str = structure describing a layer
%
%% Execution:

layer_str.name = 'loss';
layer_str.type = 'SoftmaxWithLoss';
layer_str.bottom{1} = bottom_name;
layer_str.bottom{2} = 'label';
layer_str.top = layer_str.name;

% layer {
%   name: "loss"
%   type: "SoftmaxWithLoss"
%   bottom: "fc7"
%   bottom: "label"
%   top: "loss"
% }

end


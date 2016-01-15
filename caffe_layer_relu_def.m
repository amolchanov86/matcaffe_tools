function [ layer_str ] = caffe_layer_relu_def( indx, bottom )
%% Description:
% default initialization of the ReLU layer
% --- INPUT:
% bottom = bottom layer
% --- OUTPUT:
% layer_str = structure describing a layer
%
%% Execution
layer_str.name = sprintf('relu%d', indx);
layer_str.type = 'ReLU';
layer_str.bottom = bottom;
layer_str.top = layer_str.bottom;

% layer {
%   name: "relu0"
%   type: "ReLU"
%   bottom: "conv0"
%   top: "conv0"
% }

end


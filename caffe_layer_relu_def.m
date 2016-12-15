function [ layer_str ] = caffe_layer_relu_def( name, bottom )
%% Description:
% default initialization of the ReLU layer
% --- INPUT:
% bottom = bottom layer
% --- OUTPUT:
% layer_str = structure describing a layer
%
%% Execution
if isstr(name)
    layer_str.name = name;
else
    layer_str.name = sprintf('relu%d', name);
end

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


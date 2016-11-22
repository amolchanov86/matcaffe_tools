function [ layer_str ] = caffe_layer_concat_def( name, bottoms )
%% Description:
% default initialization of the Concat layer
% --- INPUT:
% bottoms = cell array of bottom layers names
% --- OUTPUT:
% layer_str = structure describing a layer
%
%% Execution
if isstr(name)
    layer_str.name = name;
else
    layer_str.name = sprintf('concat%d', name);
end

layer_str.type = 'Concat';
layer_str.bottom = bottoms;
layer_str.top = layer_str.name;

% layer {
%   name: "relu0"
%   type: "ReLU"
%   bottom: "conv0"
%   top: "conv0"
% }

end


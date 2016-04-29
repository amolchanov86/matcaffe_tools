function [ layer_str ] = caffe_layer_drop_def( name, varargin )
%% Description:
% default initialization of the pool layer
% --- INPUT:
% indx = index for the layer
% --- OUTPUT:
% layer_str = structure describing a layer
%
%% Execution:

if isstr(name)
    layer_str.name = name;
else
    layer_str.name = sprintf('drop%d', name);
end

layer_str.type = 'Dropout';

var_i = 1;
if length(varargin) >= var_i
    layer_str.bottom = varargin{var_i};
else
    layer_str.bottom = sprintf('fc%d', name);
end

layer_str.top = layer_str.bottom;

layer_str.dropout_param.dropout_ratio = 0.5;


% layer {
%   name: "drop4"
%   type: "Dropout"
%   bottom: "fc4"
%   top: "fc4"
%   dropout_param {
%     dropout_ratio: 0.5
%   }
% }

end


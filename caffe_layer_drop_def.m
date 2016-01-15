function [ layer_str ] = caffe_layer_drop_def( indx )
%% Description:
% default initialization of the pool layer
% --- INPUT:
% indx = index for the layer
% --- OUTPUT:
% layer_str = structure describing a layer
%
%% Execution:

layer_str.name = sprintf('drop%d', indx);
layer_str.type = 'Dropout';
layer_str.bottom = sprintf('fc%d', indx);
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


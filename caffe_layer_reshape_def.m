function [ layer_str ] = caffe_layer_reshape_def( indx )
%% Description:
% default initialization of the Reshape layer
% --- INPUT:
% indx = index for the layer
% --- OUTPUT:
% layer_str = structure describing a layer
%
%% Execution:

layer_str.name = sprintf('reshp%d', indx);
layer_str.type = 'Reshape';
layer_str.bottom = sprintf('conv%d', max(indx - 1, 0 ) );
layer_str.top = layer_str.name;

layer_str.reshape_param.shape.dim{1} =  0;  % copy the dimension from below
layer_str.reshape_param.shape.dim{2} =  1;
layer_str.reshape_param.shape.dim{3} =  1;
layer_str.reshape_param.shape.dim{4} = -1; % infer it from the other dimensions

% layer {
%   name: "reshp0"
%   type: "Reshape"
%   bottom: "conv0"
%   top: "reshp0"
%   reshape_param {
%     shape {
%       dim: 0  # copy the dimension from below
%       dim: 1
%       dim: 300
%       dim: -1 # infer it from the other dimensions
%     }
%   }
% }
end


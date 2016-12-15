function [ layer_str ] = caffe_layer_pool_def( name, bottom, kernel_size, varargin )
%% Description:
% default initialization of the Pooling layer
% --- INPUT:
% indx = index for the layer
% --- OUTPUT:
% layer_str = structure describing a layer
%
%% Execution:
%Name
if isstr(name)
    layer_str.name = name;
else
    layer_str.name = sprintf('pool%d', name);
end
layer_str.type = 'Pooling';

%Bottom
layer_str.bottom = bottom;
layer_str.top = layer_str.name;

layer_str.pooling_param.pool = 'MAX';
layer_str.pooling_param.kernel_size = kernel_size;
layer_str.pooling_param.stride = 1; % default stride

for i_param = 1:2:length(varargin)
    param_name = varargin{i_param};
    param_value = varargin{i_param+1};
    layer_str.pooling_param.(param_name) = param_value;
    if isfield(layer_str.pooling_param, 'kernel_size') && ...
            (strcmp(param_name, 'kernel_h') || strcmp(param_name, 'kernel_w'))
        % remove kernel field
        layer_str.pooling_param = rmfield(...
            layer_str.pooling_param, 'kernel_size');
    end
    if isfield(layer_str.pooling_param, 'stride') && ...
            (strcmp(param_name, 'stride_h') || strcmp(param_name, 'stride_w'))
        % remove kernel field
        layer_str.pooling_param = rmfield(...
            layer_str.pooling_param, 'stride');
    end
end

% layer {
%   name: "pool0"
%   type: "Pooling"
%   bottom: "conv0"
%   top: "pool0"
%   pooling_param {
%     pool: MAX
%     kernel_h: 1
%     kernel_w: 2
%     stride_h: 1
%     stride_w: 2
%   }
% }

end


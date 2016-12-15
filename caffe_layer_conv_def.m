function [ layer_str ] = caffe_layer_conv_def( name, bottom, kernel_size, num_output, add_mult, varargin)
%% Description
% Generates default Convolution layer values given layer name
% --- INPUT:
% indx = index for the layer
% --- OUTPUT:
% layer_str = structure describing a layer
%
%% Execution
%Name
if ischar(name)
    layer_str.name = name;
else
    layer_str.name = sprintf('conv%d', name);
end
conv_name = 'Convolution';
layer_str.type = conv_name;

% Bottom layer
layer_str.bottom = bottom;
layer_str.top = layer_str.name;

if add_mult
    layer_str.param{1}.lr_mult = 1;
    layer_str.param{1}.decay_mult = 1;
    layer_str.param{2}.lr_mult = 2;
    layer_str.param{2}.decay_mult = 0;
end

layer_str.convolution_param.num_output = num_output;
layer_str.convolution_param.kernel_size = kernel_size;

for i_param = 1:2:length(varargin)
    param_name = varargin{i_param};
    param_value = varargin{i_param+1};
    layer_str.convolution_param.(param_name) = param_value;
    if isfield(layer_str.convolution_param, 'kernel_size') && ...
            (strcmp(param_name, 'kernel_h') || strcmp(param_name, 'kernel_w'))
        % remove kernel field
        layer_str.convolution_param = rmfield(...
            layer_str.convolution_param, 'kernel_size');
    end
end

layer_str.convolution_param.weight_filler.type = 'xavier';
layer_str.convolution_param.bias_filler.type   = 'constant';
layer_str.convolution_param.bias_filler.value   = 0;

% layer {
%   name: "conv2"
%   type: "Convolution"
%   bottom: "pool1"
%   top: "conv2"
%   param {
%     lr_mult: 1
%     decay_mult: 1
%   }
%   param {
%     lr_mult: 2
%     decay_mult: 0
%   }
%   convolution_param {
%     num_output: 128
%     kernel_h: 1
%     kernel_w: 2
%     stride_h: 1
%     stride_w: 1
%     weight_filler {
%       type: "xavier"
%     }
%     bias_filler {
%       type: "constant"
%       value: 1
%     }
%   }
% }
end


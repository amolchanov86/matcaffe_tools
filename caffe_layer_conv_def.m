function [ layer_str ] = caffe_layer_conv_def( name, varargin )
%% Description
% Generates default Convolution layer values given layer name
% --- INPUT:
% indx = index for the layer
% --- OUTPUT:
% layer_str = structure describing a layer
%
%% Execution
%Name
if isstr(name)
    layer_str.name = name;
else
    layer_str.name = sprintf('conv%d', name);
end
conv_name = 'Convolution';
layer_str.type = conv_name;

% Bottom layer
var_i = 1;
if length(varargin) >= var_i
    layer_str.bottom = varargin{var_i};
else
    layer_str.bottom = 'data';
end

layer_str.top = layer_str.name;

layer_str.param{1}.lr_mult = 1;
layer_str.param{1}.decay_mult = 1;
layer_str.param{2}.lr_mult = 2;
layer_str.param{2}.decay_mult = 0;

layer_str.convolution_param.num_output = int32(128);
layer_str.convolution_param.kernel_h = int32(3);
layer_str.convolution_param.kernel_w = int32(3);
layer_str.convolution_param.stride_h = int32(2);
layer_str.convolution_param.stride_w = int32(2);

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
%     #pad: 0
%     #kernel_size: 2
%     #stride: 1
%     #group: 2
%     weight_filler {
%       type: "xavier"
%       #std: 0.01
%     }
%     bias_filler {
%       type: "constant"
%       value: 1
%     }
%   }
% }
end


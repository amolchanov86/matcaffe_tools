function [ layer_str ] = caffe_layer_fc_def( name, varargin )
%% Description:
% default initialization of the InnerProduct (fully connected) layer
% --- INPUT:
% indx = index for the layer
% --- OUTPUT:
% layer_str = structure describing a layer
%
if isstr(name)
    layer_str.name = name;
else
    layer_str.name = sprintf('fc%d', name);
end
layer_str.type = 'InnerProduct';

var_i = 1;
if length(varargin) >= var_i
    layer_str.bottom = varargin{var_i};
else
    layer_str.bottom = sprintf('conv%d', max(name - 1, 0 ) );
end
    
layer_str.top = layer_str.name;

layer_str.param{1}.lr_mult = 1;
layer_str.param{1}.decay_mult = 1;
layer_str.param{2}.lr_mult = 2;
layer_str.param{2}.decay_mult = 0;

layer_str.inner_product_param.num_output = 256;

layer_str.inner_product_param.weight_filler.type = 'xavier';

layer_str.inner_product_param.bias_filler.type   = 'constant';
layer_str.inner_product_param.bias_filler.value   = 0;

% layer {
%   name: "fc6"
%   type: "InnerProduct"
%   bottom: "conv3"
%   top: "fc6"
%   param {
%     lr_mult: 1
%     decay_mult: 1
%   }
%   param {
%     lr_mult: 2
%     decay_mult: 0
%   }
%   inner_product_param {
%     num_output: 256
%     weight_filler {
%       type: "xavier"
%       #std: 0.005
%     }
%     bias_filler {
%       type: "constant"
%       value: 0
%     }
%   }
% }

end


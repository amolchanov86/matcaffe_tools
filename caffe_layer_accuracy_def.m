function [ layer_str ] = caffe_layer_accuracy_def( name, bottom_name )
%% Description:
% default initialization of the Accuracy layer
% --- INPUT:
% bottom_name = name of the bottom layer
% --- OUTPUT:
% layer_str = structure describing a layer
%
%% Execution:

layer_str.name = name;
layer_str.type = 'Accuracy';
layer_str.bottom{1} = bottom_name;
layer_str.bottom{2} = 'label';
layer_str.top = layer_str.name;

layer_str.include.phase = 'TEST';

% layer {
%   name: "accuracy"
%   type: "Accuracy"
%   bottom: "fc7"
%   bottom: "label"
%   top: "accuracy"
%   include {
%     phase: TEST
%   }
% }

end


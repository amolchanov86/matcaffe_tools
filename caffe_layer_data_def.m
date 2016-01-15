function [ layer_str ] = caffe_layer_data_def( backend, train_flag, varargin )
%% Description:
% default initialization of the Data layer
% [ layer_str ] =  caffe_layer_data_def( backend, train_flag, [include_transf] )
% --- INPUT:
% backend = backend used:
%   - 'lmdb'
%   - 'hdf5'
% train_flag = training or validation:
%   0 = validation
%   1 = training
%   other = include in both
% --- INPUT OPTIONAL:
% include_transf = should we include mean file ?
% --- OUTPUT:
% layer_str = structure describing a layer
%
%% Parameters
batch_size_def = 128;

%% Execution
var_num = 1;
if length(varargin) > var_num - 1
    include_transf = varargin{var_num};
else
    include_transf = 0;
end

layer_str.name = 'data';

if strcmp('hdf5', backend)
    layer_str.type = 'HDF5Data';   
end
if strcmp('lmdb', backend)
    layer_str.type = 'Data';   
end


layer_str.top{1} = 'data';
layer_str.top{2} = 'label';

switch train_flag
    case 0
        layer_str.include.phase = 'TEST';  
        train_str = 'val';
    case 1
        layer_str.include.phase = 'TRAIN';
        train_str = 'train';
end

if include_transf
    layer_str.transform_param.mirror = 'false';
    layer_str.transform_param.mean_file = 'data/mean.binaryproto';
end

if strcmp('hdf5', backend)
    layer_str.hdf5_data_param.source = sprintf('data_%s.txt', train_str);
    layer_str.hdf5_data_param.batch_size = batch_size_def;
end
if strcmp('lmdb', backend)
    layer_str.data_param.source = sprintf('data/%s_lmdb', train_str);
    layer_str.data_param.batch_size = batch_size_def;
    layer_str.data_param.backend = 'LMDB';
end

% layer {
%   name: "data"
%   type: "HDF5Data"
%   top: "data"
%   top: "label"
%   include {
%     phase: TRAIN
%   }
%  # transform_param {
%  #   mirror: false
%  #   mean_file: "data/mean.binaryproto"
%  #}
%   hdf5_data_param {
%     source: "data_train.txt"
%     batch_size: 256
%   }
% }

% layer {
%   name: "data"
%   type: "Data"
%   top: "data"
%   top: "label"
%   include {
%     phase: TRAIN
%   }
%   transform_param {
%     mirror: false
%     mean_file: "data/mean.binaryproto"
%   }
%   data_param {
%     source: "data/train_lmdb"
%     batch_size: 20
%     backend: LMDB
%   }
% }

end


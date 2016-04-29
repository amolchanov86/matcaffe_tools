function [ softlabels, h5_label_val, h5_data_val, ff_time ] = caffe_getsoftlabel( net_model, net_weigths, h5_datafile )
%% Description:
% the function generates soft labels from neural network output for
% knowledge distillation
% [ softlabels, h5_label_val, h5_data_val, ff_time ] = caffe_getsoftlabel( net_model, net_weigths, h5_datafile)
%
% --- INPUT:
% net_model   = prototxt file with model description
% net_weigths = weights for the models
% h5_datafile = HDF5 data file
%
% --- OUTPUT:
% softlabels   = soft labels generated (samp_num x out_dim_num)
% h5_label_val = labels read from the data file
% h5_data_val  = data read
% ff_time      = computation time

%% Parameters
phase = 'test'; % run with phase test (so that dropout isn't applied)

%% Arguments
% varar_id = 1;
% pack_4d = 0;
% if length(varargin) > (varar_id - 1)
%    pack_4d = varargin{varar_id}; 
% end

%% Initialize results
% fprintf('%s : Deploy model = %s Snapshot = %s \n', ...
%     mfilename, ...
%     net_model, ...
%     net_weigths);

% --- Loading data
% HDF5
h5_data_val  = h5read(h5_datafile, '/data');
h5_label_val = h5read(h5_datafile, '/label');
samples_num = size(h5_data_val, 4);
ff_time = zeros([samples_num, 1]);

% Initialize a network
% IMPORTANT:
% If matlab crashes, there might be a problem with reading net description prototxt file
% In order to see the problem I recommend executing matlab from command
% line, since all matcaffe problems are reported only there.
% Some examples of problems:
% - the name of the network is set up twice 
% - loss layer is kept for the deployment network, although data layer with
%   labels has been removed
caffe.set_mode_gpu();
caffe.set_device(0);

net = caffe.Net(net_model, net_weigths, phase);

%First run to define number of outputs and preallocate space
out = net.forward( {h5_data_val(:, :, :, 1)} );
out_num = numel(out{1});
softlabels = zeros([ samples_num, out_num]);
softlabels(1, :) = out{1}(:)';
zero_out = zeros(1,out_num);

%The rest of runs
for samp_i=2:samples_num
    tic
    out = net.forward( {h5_data_val(:,:,:,samp_i)} );
    ff_time(samp_i) = toc; 
%     fprintf('Classes num = %d out_dim = %d \n', classes_num, size(out{1}(:)',2))
%     softlabels(samp_i, :) = out{1}(:)';
    
    % Sanity checking 
    softlabels(samp_i, :) =  zero_out;
    softlabels(samp_i, h5_label_val(samp_i) + 1) = 1;
end

%% Close everything
caffe.reset_all();

end


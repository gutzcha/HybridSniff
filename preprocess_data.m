function [...
    train_data_labels,...
    train_data,...
    cwt_out] = preprocess_data( ...
    train_data,...
    win_duration,...
    overlap_duration,...
    sampling_rate)


% if isstruct(train_data)
%     train_ds_signal = train_data.DatastoreSignal;
%     train_data = train_ds_signal.readall;
% end

if isstruct(train_data)
    train_data_vector = train_data.train_data_vector;
    train_data_labels = train_data.train_data_labels;
end

if iscell(train_data)
    train_data_vector = [];
    train_data_labels = [];
   for j = 1:size(train_data,1)
       temp_tab = train_data{j};
       train_data_vector = [train_data_vector;temp_tab.vector{:}]; %#ok
       train_data_labels = [train_data_labels;temp_tab.labels{:}]; %#ok
   end
end

if istable(train_data)
    train_data_vector = vertcat(train_data.vector{:});
    train_data_labels = vertcat(train_data.labels{:});
end

if isvector(train_data)
    train_data_vector = train_data;
    train_data_labels = [];
end

% fold the data
if ~exist('win_duration','var')||isempty(win_duration)
win_duration = 0.100; %sec
end

if ~exist('overlap_duration','var')||isempty(overlap_duration)
overlap_duration = 0.050; %sec
end

if ~exist('sampling_rate','var')||isempty(sampling_rate)
sampling_rate = 1000; %samples per sec
end


win_length = max(round(win_duration*sampling_rate),1);
overlap_length = round(sampling_rate*overlap_duration);

% process labels
train_data_labels = process_labels(train_data_labels, win_length, overlap_length);


train_data_vector_folded = reshape_vector(train_data_vector, win_length, overlap_length);

batch_size = 128;
train_data_vector_folded = train_data_vector_folded';
[n_samples, ~] =  size(train_data_vector_folded);
fb = cwtfilterbank(SignalLength=win_length,SamplingFrequency=sampling_rate);
a = train_data_vector_folded(1,:);
% a = detrend(a);
b = normalize(a,'center');
c = cwt(b,FilterBank=fb);
d = abs(c);
cwt_out = zeros(size(d,1),size(d,2),1,n_samples);
cwt_out(:,:,1,1) = d;

for i1 = 2:n_samples
   a = train_data_vector_folded(i1,:);
%    a = detrend(a);
   b = normalize(a,'center');
   c = cwt(b,FilterBank=fb);
   d = abs(c);
   cwt_out(:,:,1,i1) = d;
end

function train_data_labels_ret = process_labels(train_data_labels, win_length, overlap_length)
if isempty(train_data_labels)
    train_data_labels_ret = [];
   return  
end
train_data_labels_folded = reshape_vector(train_data_labels, win_length, overlap_length);

% set 1 label for each segment


% option 1 - if there is one bin within the window, mark it as true
% train_data_labels_folded_one = categorical(1+double((any(train_data_labels_folded==1,1))));
% option 2 - set label to be 1 only if the the usv is in the middle of the
% vector
[~,n_samples, n_labels] =  size(train_data_labels_folded);

mid_ind_range = ceil(win_length*0.5); % number of bins concidered middle - x percent of win length
mid_inds = max(round((win_length/2-mid_ind_range/2)),1):min(round((win_length/2+mid_ind_range/2)),win_length);

%convert labels to categorical, assuming that there are no overlapings
% 
if n_labels==1
    train_data_labels_folded_one= categorical(1+double((any(train_data_labels_folded(mid_inds,:)==1,1))));
else
        train_data_labels_folded_one_temp = categorical(zeros(size(train_data_labels_folded,1),size(train_data_labels_folded,2)),[0,1,2]);

        for j = 1:n_labels-1
            train_data_labels_folded_one_temp(logical(squeeze(train_data_labels_folded(:,:,j)))) = categorical(j);
        end
        
        % train_data_labels_folded_one_temp = categorical(train_data_labels_folded_one_temp,[0,1,2]);
        train_data_labels_folded_one = categorical(zeros(1,size(train_data_labels_folded_one_temp,2)),[0,1,2]);
        for j = 1:n_samples
            seg =  train_data_labels_folded_one_temp(mid_inds,j);
            seg(seg=='0') = [];
            seg = [seg;categorical(0)]; %#ok
            seg = mode(seg);
            train_data_labels_folded_one(j) = seg;
        end
end
train_data_labels_ret = train_data_labels_folded_one';






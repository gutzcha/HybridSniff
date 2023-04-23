function obj = convert_to_obj(obj_in,predictions,responses,config)
obj = copyobj(obj_in);
if ~exist('config','var')
    config = struct();
end
if isfield(config,'th')
    th = config.th;
else
    th = 0.35;
end
if isfield(config,'gaussian')
    gaussian = config.gaussian;
else
    gaussian = 0.1;
end
if isfield(config,'gt_label')
    gt_label = config.gt_label;
else
    gt_label = '1';
end
if isfield(config,'timeshift')
    timeshift = config.timeshift;
else
    timeshift = -0.02;
end
if iscell(predictions)
    predictions = [predictions{:}]';
end




logical_vector = imgaussfilt(predictions(:,2),gaussian)>th;

logical_vector = reshape(logical_vector,1,[]);
original_len_sec = obj.audioLen;
min_syllable_length_milisec = 2;
fs_in = numel(logical_vector)/original_len_sec;
[tab, ~]= create_table_from_logical_array(...
    logical_vector,original_len_sec,min_syllable_length_milisec,fs_in);
tab.Label = repmat("sniffUSV",[size(tab,1),1]);
tab_long = short_table_to_roiTable(obj,tab,timeshift);

if ~isempty(responses)
    if iscell(responses)
        responses = [responses{:}]';
    end
gt = responses==gt_label;
logical_vector = gt';
original_len_sec = obj.audioLen;
min_syllable_length_milisec = 5;
fs_in = round(numel(logical_vector)/original_len_sec);
[tab, ~]= create_table_from_logical_array(...
    logical_vector,original_len_sec,min_syllable_length_milisec,fs_in);
tab.Label = repmat("GT",[size(tab,1),1]);
tab_long_gt = short_table_to_roiTable(obj,tab,timeshift,10000);
else
   tab_long_gt = []; 
end
tab_orig = obj.roiTableTemplate;
combtab = [tab_orig;tab_long_gt;tab_long];
combtab = sortrows(combtab,{'TimeStart','Label'});

obj.roiTable = combtab;
added_types = {...
    "FP_low_as_USV"   ,	[1 1 0],"";...
    "FP_noise_as_USV" , [0.9290 0.6940 0.1250],"";...
    "TP_new_USV"      ,	[0 1 1],"";...
    "GT"      ,[1,0,0],"";...
    "sniffUSV",[0,1,0],""};
obj.addedTypeList = [obj.addedTypeList;added_types];
%
obj.window = 512*2;
obj.overlap = 512;
obj.fft =  512*2;
obj.ylims = [50,80000];
obj.times_ = [0 1];

end
function new_vec = downsample_audio(input_vec,input_fs,output_fs,output_shape)
%Determine a rational approximation to the ratio of the new sample rate


if isa(input_vec,'logical')
    %downsample logical array
    new_vec = imresize(input_vec,output_shape);
   
else
    [P,Q] = rat(output_fs/input_fs); 
    %Resample while applying FIR Antialiasing Lowpass Filter
    new_vec = resample(input_vec,P,Q);
    padval = 0;


if exist('output_shape','var') % ensure the output has a desired shape
    new_vec = CropAndPadMatrix(new_vec,output_shape(2),output_shape(1),padval);     

end
end
end
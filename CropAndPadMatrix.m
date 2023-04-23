function x = CropAndPadMatrix(mat, outWidth, outHeight,padWithVal)
% CROPANDPADMATRIX pads or crops a matrix into desierd width and height
%   X = CROPANDPADMATRIX(MAT,OUTWIDTH, OUTHEIGHT) pads MAT, with zeros or crops the matrix,
%   while keeping the matrix in the middle and outputs a new matrix x with dimention
%   [outHeightxoutWidth]. MAT may be a cell array of matrecies, in which case,
%   X will be [h,w,c] array where h is the height, w is width and c is the
%   number of matrecies in the MAT. If the matrix is empry CropAndPadMatrix(MAT,WIDTH ,HEIGHT)
%   returns and zero matrix with size [HEIGHT,WIDTH].
%   Examples
%       CropAndPadMatrix(rand(5,10), 100, 10)
%       CropAndPadMatrix(rand(5,50), 10, 10)
%       CropAndPadMatrix([], 10, 10)
%       CropAndPadMatrix({rand(5,10),rand(51,12)}, 10, 10)
% 
% Yizhaq Goussha (2021)


%Input validation and default values
if ~exist('outWidth','var')||isempty(outWidth)
    outWidth = 51; %default value
end

if ~exist('padWith','var')||isempty(padWith)
    padWithVal = 0; %default value
elseif isstring(padWith)||ischar(padWith)
    switch lower(padWith)
        case 'min'
            if ~iscell(mat)
                padWithVal = min(mat,[],"all");
            end
        case 'max'
            if ~iscell(mat)
                padWithVal = max(mat,[],"all");
            end
            
        otherwise
            warning('Unidetified padWith, must be min, padding with zeros ')
            padWithVal = 0;
    end
end


if ~exist('outHeight','var')||isempty(outHeight)
    outHeight = 124; %default value
end

%outHeight and outWidth must be positive integers


%If mat is empty, return x with size [outHeight,outWidth]
if isempty(mat)
    x = repmat(padWithVal,[outHeight,outWidth]) ;
    warning ('Input was emptry, returning zero matrix')
    return
end

checkInput = @(x)isfinite(x) & x==floor(x) & x>0 & isnumeric(x);

if ~checkInput(outHeight)
    error('outHeight must be integer number greater than 0')
end
if ~checkInput(outWidth)
    error('outWidth must be integer number greater than 0')
end

%if mat is cell, run function recursivly
if iscell(mat)
    sz = size(mat);
    x = cellfun(@CropAndPadMatrix,...
        mat,...
        repmat({outWidth},sz),...
        repmat({outHeight},sz),...
        repmat({padWith},sz),...
        'UniformOutput',false);
    x = cat(3,x{:});
    return
end

%Get mat dimentions
[inHeight,inWidth] = size(mat);


%If the matrix is too wide or high, crop it
if inHeight>outHeight||inWidth>outWidth
    [mat,inHeight,inWidth] = cropMat(mat,outWidth,outHeight,inWidth,inHeight,padWithVal);
end

%if the matrix has equal or smaller dimentions than [height,width], pad it
if ~(inHeight==outHeight   && inWidth==outWidth)
    mat = padMat(mat,outWidth,outHeight,inWidth,inHeight,padWithVal);
end
x = mat;

function [x,outHeight,outWidth] = cropMat(mat,outWidth,outHeight,inWidth,inHeight,~)
% if ~exist('padWith','var')||isempty(padWith)
%     padWith = 0;    
% end

xMask = zeros(inHeight,inWidth);


%Make sure that r and c are smaller than height and width
outHeight = min(outHeight,inHeight);
outWidth = min(outWidth,inWidth);

%Create a mask
xMask(1:outHeight,1:outWidth) = 1;

%Translate mask to the middle
Tx = floor(abs(inWidth-outWidth)/2);
Ty = floor(abs(inHeight-outHeight)/2);

xMask = (logical(imtranslate(xMask,[Tx, Ty])));

%Crop matrix
x = zeros(outHeight,outWidth);
x(:) = mat(xMask(:));


function x = padMat(mat,outWidth,outHeight,inWidth,inHeight,padWith)

if ~exist('padWith','var')||isempty(padWith)
    padWith = 0;    
end

%Create output matrix
x = ones(outHeight,outWidth).*padWith;
x(1:inHeight,1:inWidth) = mat;

%Shift (translate) image to the middle
Tx = floor((outWidth-inWidth)/2);
Ty = floor((outHeight-inHeight)/2);

x = imtranslate(x,[Tx, Ty],'FillValues',padWith);

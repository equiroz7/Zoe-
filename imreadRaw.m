function [output]=imreadRaw(input_img,m,n,type)
% This function mimics the matlab imread(), but reads raw format images.  To
% read a raw image, the image dimensions must be specified (m-by-n) as well
% as the bit depth of each pixel.  For example an 8 bit 5Mpa image would be
% imreadRaw(image_file_name, 1944, 2592, *uchar)
%
% M Griffin

if (nargin == 1)   %no image size set, use 5MP
       m = 1944;
       n = 2592;
end

if (nargin < 4)
    type = '*uchar';
end    

    id = fopen(input_img, 'r');
    %img = fread(id, [n,m], '*uchar')';
    %img = fread(id, [n,m], '*uint16')';
    
    img = fread(id, [n,m], type)';
   
    fclose(id);
    
output = img;
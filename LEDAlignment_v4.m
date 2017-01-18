% GALILEO: LED Alignment and Uniformity

% Author: Emmanuel Quiroz
% Date: 2014_08_02
% Company: Bio-Rad
% Division: LSG, GXD, Optics

% Date: 2014_08_02
% Added line of code to check if corners in the 6 x 8 grid are at 0.85%
% (line 113 145)

%% Versions

% v2.2 08/02/2014 - Check for average corner intesities 

% v3   10/01/2014 - Round 'zoneMap' to nearest 100th and change comparison
%                   values.
% v4   10/26/2015 - Lower requirement for ch3 corners to be >/=0.83 instead
%                    of >/=0.85 (line 68)


function LEDAlignment_v4()
% LEDAlignment(): Reads in a .raw image file from the LED Alignment fixture
% and outputs a struct containing the uniformity results of the image. 

%% Ask user to open file
cd('C:\Users\galileo\desktop\LED Alignment_IN') ;
[file, dir] = uigetfile({'*.raw;*.tif'}, 'OPEN IMAGE TO RUN LED ALIGNMENT') ;
orig_filename = strcat(dir, file) ;


%% Prompt User to label unit serial number
prompt1 = {'Enter Unit Serial Number:', 'Channel #'};
dlg_title = 'Input';
num_lines = 1;
def = {'', ''};
input = inputdlg(prompt1,dlg_title,num_lines,def);
unit_SN = input{1} ;
channel = input{2} ; 


%% Read image data from 
img = imreadRaw(orig_filename) ;


%% Calculate Uniformity & zoneMap
[imgOut, fail, imgErr] = flatnessErrorMap_fixture(img, 'gray', 0) ;
[zoneMap] = errMapFun(img) ;

% Round 'zoneMap' to the nearest 100ths decimal place
[m, n] = size(zoneMap) ; 
zoneMap_round = ones(m, n) ;

for i = 1:m
    for j = 1:n
        zoneMap_round(i, j) = str2double(sprintf('%0.2f',zoneMap(i,j))) ;
    end
end

%% Determine if corners are failing spec ( >=.83 for Ch 3 and >= .82 for Ch 1 & Ch 2. 'SpecCh[#]' below is -0.1 because I am rounding up)

cornerFailCh1 = 0 ; 
cornerFailCh2 = 0 ; 
cornerFailCh3 = 0 ; 

SpecCh1 = 0.81 ;
SpecCh2 = 0.81 ;
SpecCh3 = 0.82 ;

if channel == '1'
   cornerFailCh1 = (zoneMap_round(1,1) <= SpecCh1 || zoneMap_round(6,1) <= SpecCh1 ||...
       zoneMap_round(1,8) <= SpecCh1 || zoneMap_round(6,8) <= SpecCh1) ; 
elseif channel == '2'
   cornerFailCh2 = (zoneMap_round(1,1) <= SpecCh2 || zoneMap_round(6,1) <= SpecCh2 ||...
       zoneMap_round(1,8) <= SpecCh2 || zoneMap_round(6,8) <= SpecCh2) ; 
elseif channel == '3'
   cornerFailCh3 = (zoneMap_round(1,1) <= SpecCh3 || zoneMap_round(6,1) <= SpecCh3 ||...
       zoneMap_round(1,8) <= SpecCh3 || zoneMap_round(6,8) <= SpecCh3) ; 
else
    error('LEDAlignment:ChannelInputError', 'Channel number input must be either 1, 2, or 3')
end


%% Determine whether measurement is passing/failing spec
result = fail < 0.015 ;

% Set limit for saturated images
pixels_sat_map = (img > 250) ; 
pixels_sat_sum = sum(sum(pixels_sat_map)) ; % calcultates number of pixels defined as 'saturated' (saturated > 250 counts)
img_rgb = zeros(1944, 2592, 3) ; 


img_red = double(img)/255 ; img_red(pixels_sat_map) = 1 ;
img_green = double(img)/255 ; img_green(pixels_sat_map) = 0 ;
img_blue = double(img)/255 ; img_blue(pixels_sat_map) = 0 ;
img_rgb(:, :, 1) = img_red ; img_rgb(:, :, 2) = img_green ; img_rgb(:, :, 3) = img_blue ; 

saturated = (5000 < pixels_sat_sum) ; % returns 'true' if greater than 50 pixels are saturated

% Set limit for dim images
pixels_ok_map = (img > 100) ; 
pixels_ok_sum = sum(sum(pixels_ok_map)) ; % calcultates number of pixels defined as 'ok' (ok = pixels > 100)
dimmed = (pixels_ok_sum < 5e5) ; % returns 'true' if less than 500,000 pixels are greater than 100 counts 


% Convert fail from decimal units to percentage units
fail_perc = fail * 100 ;
figure()
h = heatmap(zoneMap,'', '', '%0.2f', 'TextColor', [.6 .6 .6],'Colormap','jet' );

date = strcat(datestr(clock,'yyyy-mm-dd-HHMM'),'m',datestr(clock,'ss'),'s') ; %Date & time stamp
if saturated % if 'true' 
    close all
    
    h = figure() ;
    imshow(img_rgb)
    title(strcat(unit_SN, ' Ch ', num2str(channel), ...
        ' ERROR: Image saturated. Turn down LED brightness') , 'FontSize', 15) ; pbaspect([4 3 1])
    % Save original .RAW image file as a .TIF
    filename_orig = strcat(dir,'FAIL\',unit_SN, '_LED Alignment_', 'Orig Img_',...
        'Ch ', num2str(channel), sprintf('_%0.2f', sum(sum(img > 250))), ...
        ' pixels_SATURATED_', date) ;
    
    % Save figure results
    filename_fig = strcat(dir,'FAIL\', unit_SN, '_LED Alignment_','SATURATED_', ...
        'Ch ', num2str(channel), sprintf('_%0.2f', sum(sum(img > 250))), ...
        ' pixels_', date,'.png') ;
    
elseif dimmed
    title(strcat(unit_SN, ' Ch ', num2str(channel), ...
        ' ERROR: Image too dim. Turn up LED brightness'), 'FontSize', 15) ; pbaspect([4 3 1])
    
    % Save original .RAW image file as a .TIF
    filename_orig = strcat(dir,'FAIL\',unit_SN, '_LED Alignment_', 'Orig Img_',...
        'Ch ', num2str(channel), ' TOO DIM_', date) ;
    
    % Save figure results
    filename_fig = strcat(dir,'FAIL\', unit_SN, '_LED Alignment_','Result_',...
        'Ch ', num2str(channel), ' TOO DIM_', date,'.png') ;
    
elseif cornerFailCh3
    title(strcat(unit_SN, ' Ch ', num2str(channel), ...
        ' ERROR: Corners must be >/= 0.83 for Ch 3'), 'FontSize', 15) ; pbaspect([4 3 1])
    % Save original .RAW image file as a .TIF
    filename_orig = strcat(dir,'FAIL\',unit_SN, '_LED Alignment_', 'Orig Img_',...
        'Ch ', num2str(channel), ' CornerFail_', date) ;
    
    % Save figure results
    filename_fig = strcat(dir,'FAIL\', unit_SN, '_LED Alignment_','Result_',...
        'Ch ', num2str(channel), ' CornerFail_', date,'.png') ;
    
elseif cornerFailCh1 || cornerFailCh2
    title(strcat(unit_SN, ' Ch ', num2str(channel), ...
        ' ERROR: Corners must be >/= 0.82 for Ch 1 or 2'), 'FontSize', 15) ; pbaspect([4 3 1])
    % Save original .RAW image file as a .TIF
    filename_orig = strcat(dir,'FAIL\',unit_SN, '_LED Alignment_', 'Orig Img_',...
        'Ch ', num2str(channel), ' CornerFail_', date) ;
    
    % Save figure results
    filename_fig = strcat(dir,'FAIL\', unit_SN, '_LED Alignment_','Result_',...
        'Ch ', num2str(channel), ' CornerFail_', date,'.png') ;

elseif result
    title(strcat(unit_SN, ' Ch ', num2str(channel), ...
        sprintf(' PASS: %0.2f %%', fail_perc)), 'FontSize', 15) ; pbaspect([4 3 1])
    
    % Save original .RAW image file as a .TIF
    filename_orig = strcat(dir,'PASS\',unit_SN, '_LED Alignment_', 'Orig Img_',...
        'Ch ', num2str(channel), sprintf('_%0.2f %%', fail_perc), ...
        ' pixels_PASS_', date) ;
    
    % Save figure results
    filename_fig = strcat(dir,'PASS\', unit_SN, '_LED Alignment_','Result_',...
        'Ch ', num2str(channel), sprintf('_%0.2f %%', fail_perc), ...
        ' pixels_PASS_', date,'.png') ;
    
else
    title(strcat(unit_SN, ' Ch ', num2str(channel), ...
        sprintf(' FAIL: %0.2f %%', fail_perc)), 'FontSize', 15) ; pbaspect([4 3 1])
    
    % Save original .RAW image file as a .TIF
    filename_orig = strcat(dir,'FAIL\',unit_SN, '_LED Alignment_', 'Orig Img_',...
        'Ch ', num2str(channel), sprintf('_%0.2f %%', fail_perc), ...
        ' pixels_FAIL_', date) ;

    % Save figure results
    filename_fig = strcat(dir,'FAIL\', unit_SN, '_LED Alignment_','Result_', ...
        'Ch ', num2str(channel), sprintf('_%0.2f %%', fail_perc), ...
        ' pixels_FAIL_', date,'.png') ;
end

%% Write original image, save figure, and move .raw file
imwrite(img, [filename_orig '.tif']) ;
saveas(h, filename_fig, 'png');
movefile([dir file], [filename_orig '.raw']) ;

end




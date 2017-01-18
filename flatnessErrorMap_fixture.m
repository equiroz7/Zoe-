function [imgOut, failPercent, imgErr] = flatnessErrorMap_fixture(img_input, mapSelector, noOutput)
%  function takes in an image and map selection and makes a heatmap
%  the heatmap is a representation of % error from average
%  'RGB Error', 'R Error', 'G Error', 'B Error', 'gray' produce 5 level map
%  'RGB P/F', 'R P/F', 'G P/F', 'B P/F' produce 2 level map
%   if the input image is grayscale, I force it to 'gray'
% errorMap is the map of levels, uncolored, use imagesc() to color it
% Optionally, a second return is the % of map above the pass limit
% Third arg supresses output
%
% requires IPT
% Mike Griffin 6/26/2012
% v2 6/28/2012 - made the output graphics conditional upon 'noOutput'
% v3 6/17/2014 - changed the range of region 4 from +/- 20% 
%                to {-20% .. +20%}
% v4 8/02/2014 - Fixed bug in range finding, it now uses the 'region'
%                values to prevent issues in the future 
% v4_fixture   - reverted back to +/- 20% for the use in a fixture. Renamed
% the function to 'flatnessErrorMap_fixture'

%% deal with inputs
[M, N, ch] = size(img_input);

if(ch == 1)
    mapSelector = 'gray';
end
%% build the right map
% I could make this slightly cleaner by making a subfunction, but each
% option is slightly different, so I'd need to pass several arguments to it
% and it would be a lot harder to read than this case statement

bigColorMap = [0 0 1; 0 .5 1; 0 1 1; 0 .75 .25; 0 .85 0;.25 .75 0;1 1 0;1 .5 0;1 0 0];
smallColorMap = [0 0 1; 0 .85 0; 1 0 0];

halfSizeOfColorMap = round((size(bigColorMap,1)+1)/2);
halfSizeOfSmallColorMap = round((size(smallColorMap,1)+1)/2);

imgIn = imresize(img_input, [M, N]);

region1Max = 1.05;
region1Min = 0.95;
region2Max = 1.10;
region2Min = 0.90;
region3Max = 1.15;
region3Min = 0.85;
region4Max = 1.20;
region4Min = 0.80;


switch mapSelector
    case 'RGB Error'
        imgErr = ones(M, N*3);
        imgErr(:, 1:N) = double(imgIn(:,:,1)) ./ mean2((imgIn(:,:,1)));
        imgErr(:, N+1:N*2) = double(imgIn(:,:,2)) ./ mean2((imgIn(:,:,2)));
        imgErr(:, (N*2)+1:N*3) = double(imgIn(:,:,3)) ./ mean2((imgIn(:,:,3)));
        
        errorMap = - double(imgErr < region1Min) - double(imgErr < region2Min) - double(imgErr < region3Min) - double(imgErr <region4Min) +  double(imgErr > region1Max) + double(imgErr > region2Max) + double(imgErr > region3Max) + double(imgErr > region4Max);
        imgOut = ind2rgb(errorMap+halfSizeOfColorMap, bigColorMap);
    case 'R Error'
        imgErr = ones(M, N);
        imgErr = double(imgIn(:,:,1)) ./ mean2((imgIn(:,:,1)));
        
        errorMap = - double(imgErr < region1Min) - double(imgErr < region2Min) - double(imgErr < region3Min) - double(imgErr <region4Min) +  double(imgErr > region1Max) + double(imgErr > region2Max) + double(imgErr > region3Max) + double(imgErr > region4Max);
        imgOut = ind2rgb(errorMap+halfSizeOfColorMap, bigColorMap);
    case 'G Error'
        imgErr = ones(M, N);
        imgErr = double(imgIn(:,:,2)) ./ mean2((imgIn(:,:,2)));
        
       errorMap = - double(imgErr < region1Min) - double(imgErr < region2Min) - double(imgErr < region3Min) - double(imgErr <region4Min) +  double(imgErr > region1Max) + double(imgErr > region2Max) + double(imgErr > region3Max) + double(imgErr > region4Max);
       imgOut = ind2rgb(errorMap+halfSizeOfColorMap, bigColorMap);
    case 'B Error'
        imgErr = ones(M, N);
        imgErr = double(imgIn(:,:,3)) ./ mean2((imgIn(:,:,3)));
        
        errorMap = - double(imgErr < region1Min) - double(imgErr < region2Min) - double(imgErr < region3Min) - double(imgErr <region4Min) +  double(imgErr > region1Max) + double(imgErr > region2Max) + double(imgErr > region3Max) + double(imgErr > region4Max);
        imgOut = ind2rgb(errorMap+halfSizeOfColorMap, bigColorMap);
    case 'RGB P/F'
        imgErr = ones(M, N*3);
        imgErr(:, 1:N) = double(imgIn(:,:,1)) ./ mean2((imgIn(:,:,1)));
        imgErr(:, N+1:N*2) = double(imgIn(:,:,2)) ./ mean2((imgIn(:,:,2)));
        imgErr(:, (N*2)+1:N*3) = double(imgIn(:,:,3)) ./ mean2((imgIn(:,:,3)));
        

        errorMap = - double(imgErr <region4Min)  + double(imgErr > region4Max);
        imgOut = ind2rgb(errorMap+halfSizeOfSmallColorMap, smallColorMap);
    case 'R P/F'
        imgErr = ones(M, N);
        imgErr = double(imgIn(:,:,1)) ./ mean2((imgIn(:,:,1)));
        
        errorMap = - double(imgErr <region4Min)  + double(imgErr > region4Max);
        imgOut = ind2rgb(errorMap+halfSizeOfSmallColorMap, smallColorMap);
    case 'G P/F'
        imgErr = ones(M, N);
        imgErr = double(imgIn(:,:,2)) ./ mean2((imgIn(:,:,2)));
        
        errorMap = - double(imgErr <region4Min)  + double(imgErr > region4Max);
        imgOut = ind2rgb(errorMap+halfSizeOfSmallColorMap, smallColorMap);
    case 'B P/F'
        imgErr = ones(M, N);
        imgErr = double(imgIn(:,:,3)) ./ mean2((imgIn(:,:,3)));
        
         errorMap = - double(imgErr <region4Min)  + double(imgErr > region4Max);
         imgOut = ind2rgb(errorMap+halfSizeOfSmallColorMap, smallColorMap);
    case 'gray'
        imgErr = ones(M, N);
        imgErr = double(imgIn(:,:)) ./ mean2((imgIn(:,:)));
        
        errorMap = - double(imgErr < region1Min) - double(imgErr < region2Min) - double(imgErr < region3Min) - double(imgErr <region4Min) +  double(imgErr > region1Max) + double(imgErr > region2Max) + double(imgErr > region3Max) + double(imgErr > region4Max);
        imgOut = ind2rgb(errorMap+halfSizeOfColorMap, bigColorMap);
    otherwise
        imgErr = ones(M, N*3);
        imgErr(:, 1:N) = double(imgIn(:,:,1)) ./ mean2((imgIn(:,:,1)));
        imgErr(:, N+1:N*2) = double(imgIn(:,:,2)) ./ mean2((imgIn(:,:,2)));
        imgErr(:, (N*2)+1:N*3) = double(imgIn(:,:,3)) ./ mean2((imgIn(:,:,3)));

        errorMap = - double(imgErr < region1Min) - double(imgErr < region2Min) - double(imgErr < region3Min) - double(imgErr <region4Min) +  double(imgErr > region1Max) + double(imgErr > region2Max) + double(imgErr > region3Max) + double(imgErr > region4Max);
        imgOut = ind2rgb(errorMap+halfSizeOfColorMap, bigColorMap);
end
%% Output



[MErrorMap, NErrorMap, chErrorMap] = size(imgOut);

if nargin <  3
    %EQ graphs:
    figure
    imshow(imgOut)
end

errorMap = double(imgErr > (region4Max) | imgErr < (region4Min));

failPercent = sum(errorMap(errorMap == max(errorMap(:))))/(MErrorMap*NErrorMap*max(errorMap(:)));

if isnan(failPercent)
    failPercent = 0;
end

end
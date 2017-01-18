function [errMap] = errMapFun(img)
%% Image size
[m, n, ch] = size(img);

%% Process the Image
mapSelector = 'gray';   % All Galileo Images should be grayscale
noOutput = 1;           % Supress the graphing within flatnessErrorMap.m

[imgout, fail, imgErr] = flatnessErrorMap_fixture(img, mapSelector, noOutput) ;
mZones = 6;
nZones = 8;

zoneSize = [m n]./[mZones nZones];

mZoneStart = 1:m/mZones:m;
nZoneStart = 1:n/nZones:n;

%% Create error map with 6 x 8 zones
errMap = zeros(mZones, nZones);

for i = 1:mZones
    for j = 1:nZones
        errMap(i,j) = mean2(imgErr(mZoneStart(i):mZoneStart(i)+zoneSize(1)-1,nZoneStart(j):nZoneStart(j)+zoneSize(2)-1));
    end
end
end
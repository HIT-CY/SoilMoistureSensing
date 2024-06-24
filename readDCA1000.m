
%%% This script is used to read the binary file produced by the DCA1000
%%% and Mmwave Studio
%%% Command to run in Matlab GUI -readDCA1000('<ADC capture bin file>')
function [retVal] = readDCA1000(fileName)  %新建一个函数名为readDCA1000 的函数，输入fileName，输出retVal 表格
%% global variables
% change based on sensor config
numADCSamples = 256; % number of ADC samples per chirp  采样点数是256个
numADCBits = 16; % number of ADC bits per sample  ADC的采样位数
numRX = 4; % number of receivers 接收器数量
numLanes = 2; % do not change. number of lanes is always 2  LVDS的平台数
isReal = 0; % set to 1 if real only data, 0 if complex data0  0 是包含虚部
%% read file
% read .bin file
fid = fopen(fileName,'r');%获取二进制文件由文件标识符 fileID   
adcData = fread(fid, 'int16'); %返回一个列向量，每个元素以int16 形式格式
%disp(size(adcData))
% if 12 or 14 bits ADC per sample compensate for sign extension
if numADCBits ~= 16
    l_max = 2^(numADCBits-1)-1;
    adcData(adcData > l_max) = adcData(adcData > l_max) - 2^numADCBits;
end
fclose(fid);
fileSize = size(adcData, 1);  %读取数据长度
% real data reshape, filesize = numADCSamples*numChirps
if isReal
    numChirps = fileSize/numADCSamples/numRX; %n_chirps*n_TX
    LVDS = zeros(1, fileSize);
    %create column for each chirp
    LVDS = reshape(adcData, numADCSamples*numRX, numChirps);
    %each row is data from one chirp
    LVDS = LVDS.';
else
% for complex data
% filesize = 2 * numADCSamples*numChirps
numChirps = fileSize/2/numADCSamples/numRX;
LVDS = zeros(1, fileSize/2);
%combine real and imaginary part into complex data
%read in file: 2I is followed by 2Q
counter = 1;
for i=1:4:fileSize-1
    LVDS(1,counter) = adcData(i) + sqrt(-1)*adcData(i+2);
    LVDS(1,counter+1) = adcData(i+1)+sqrt(-1)*adcData(i+3); 
    counter = counter + 2;
end
% create column for each chirp
LVDS = reshape(LVDS, numADCSamples*numRX, numChirps);
%each row is data from one chirp
LVDS = LVDS.';
end
%organize data per RX
adcData = zeros(numRX,numChirps*numADCSamples);
for row = 1:numRX
    for i = 1: numChirps
        adcData(row, (i-1)*numADCSamples+1:i*numADCSamples) = LVDS(i, (row-1)*numADCSamples+1:row*numADCSamples);
    end
end
% return receiver data
%disp(size(adcData))
retVal = adcData;
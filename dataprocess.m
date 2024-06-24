clear all
clc
%%雷达参数%%
n_TX = 3;
n_RX = 4;
n_chirps = 64 * n_TX;
n_samples = 256;
n_frames = 128;
Slope_Hz = 29.982e12; %斜率29.982Mhz /us
Sample_Rate_Hz = 10e6;  %采样率，10MHZ
lightSpeed = 3.0e8; %光速

%%读取bin文件%%
data=readDCA1000('E:\Matlab\AAA\SoilMoisture\data\adc_data.bin');   %size(data) = (n_RX, n_chirps*n_sample*n_TX*n)
%data=readDCA1000('adc_data.bin');

%%处理数据%%
fftSize1D = n_samples;  %大概意思同采样点数
range_step = ((Sample_Rate_Hz/n_samples)/Slope_Hz) *(lightSpeed/2) * n_samples / fftSize1D;%简化一下 距离分辨率dres= c/2B
range_axis = (0:fftSize1D-1)*range_step;  %每一个采样点对应的距离刻度
time_axis = (0:fftSize1D-1)/Sample_Rate_Hz;%每一个采样点对应时间刻度
 
for i =1:size(data,2)/n_samples           % 遍历M个chrip
    %将第一个天线的数据，重新排列成按列排布的数据，n_samples行*M列。行代表n_samples次采样，列代表天线1接受的所有chirps
    recv1_data(1:n_samples,i) = data(1,(i-1)*n_samples+1:i*n_samples); 
end
 
window_1D = hann(n_samples);
radar_data_1dFFT = fft(recv1_data(:,1).*window_1D, fftSize1D);

% %时间维度上，显示实部和虚部
% figure(1);clf                                                    
% plot(time_axis,real(recv1_data(:,1)),'b'); 
% grid on
% hold on
% plot(time_axis,imag(recv1_data(:,1)),'r')
% xlim([0 2.6e-5]);

%距离维度上，显示数据值，20log10，转换成分贝单位，abs（）转成成模的形式，/2^22 可视化调整
xlabel('time (seconds)');ylabel('amplitude');
title('Time domain plot')
figure(2);clf                                                    
plot(range_axis,20*log10(abs(radar_data_1dFFT)/2^22),'LineWidth',1.5);
grid on
xlim([0 49]);
ylim([-120 0]);
xlabel('Distance (meters)');ylabel('FFT Output(dBFS)');
title('1-D FFT amplitude profile(per chirp)')

clear all
clc
%%雷达参数%%
n_TX = 1;
n_RX = 4;
n_chirps = 64 * n_TX;
n_samples = 256;    %采样点数/脉冲
n_frames = 128;
c = 3.0e8; %光速
f0=60.25e9;       %初始频率
lambda=c/f0;   %雷达信号波长
d=lambda/2;    %天线阵列间距
Tc=160e-6;     %chirp总周期
Slope_Hz = 29.982e12; %斜率29.982Mhz /us
Fs = 10e6;  %采样率，10MHZ
frame_ind = 1;        %第frame_ind帧
Q = 180; %角度FFT

%%读取bin文件%%
fname = 'E:\Matlab\AAA\SoilMoisture\data\adc_data.bin';
fid = fopen(fname,'rb');
%16bits，复数形式(I/Q两路)，4RX,1TX,有符号16bit，小端模式
frame_data = fread(fid,frame_ind*n_chirps*n_samples*n_RX*2,'int16');
frame_data = frame_data((frame_ind-1)*n_chirps*n_samples*n_RX*2+1:frame_ind*n_chirps*n_samples*n_RX*2);
filesize = size(frame_data, 1);

%合并IQ两路为复数形式
lvds_data = zeros(1, filesize/2);
count = 1;
for i=1:4:filesize-1
   lvds_data(1,count) = frame_data(i) + 1i*frame_data(i+2); 
   lvds_data(1,count+1) = frame_data(i+1)+1i*frame_data(i+3); 
   count = count + 2;
end
lvds_data = reshape(lvds_data, n_samples*n_RX, n_chirps);
lvds_data = lvds_data.';

%将lvds_data按接收天线分类，生成n_samoles*n_chirps矩阵
cdata = zeros(n_RX,n_chirps*n_samples);
for row = 1:n_RX
  for i = 1: n_chirps
      cdata(row,(i-1)*n_samples+1:i*n_samples) = lvds_data(i,(row-1)*n_samples+1:row*n_samples);
  end
end
fclose(fid);
recv1_data = reshape(cdata(1,:),n_samples,n_chirps);   %RX1
recv2_data = reshape(cdata(2,:),n_samples,n_chirps);   %RX2
recv3_data = reshape(cdata(3,:),n_samples,n_chirps);   %RX3
recv4_data = reshape(cdata(4,:),n_samples,n_chirps);   %RX4

%{
%只处理一帧

%距离FFT
range_win = hamming(n_samples);  %加汉明窗
radar_data_1DFFT = fft(recv1_data(:,1).*range_win, n_samples);

index = 1:1:n_samples;  
freq_bin = (index - 1) * Fs / n_samples;    %频域坐标
range_bin = freq_bin * c / 2 / Slope_Hz;
%%画图
figure
%plot(freq_bin,abs(radar_data_1DFFT));title('中频信号IF');
plot(range_bin,abs(radar_data_1DFFT));title('rangefft');

%}

%三维雷达回波数据（n_samples, n_chirps, n_RX）
data_radar=[];            
data_radar(:,:,1)=recv1_data;     
data_radar(:,:,2)=recv2_data;
data_radar(:,:,3)=recv3_data;
data_radar(:,:,4)=recv4_data;

%距离FFT
range_win = hamming(n_samples);  %加汉明窗
range_profile = [];
for k=1:n_RX
   for m=1:n_chirps
      temp=data_radar(:,m,k).*range_win;
      temp_fft=fft(temp,n_samples);    %对每个chirp做n_samples点FFT
      range_profile(:,m,k)=temp_fft;
   end
end

%多普勒FFT
doppler_win = hamming(n_chirps);  %加汉明窗
speed_profile = [];
for k=1:n_RX
    for n=1:n_samples
      temp=range_profile(n,:,k).*(doppler_win)';    
      temp_fft=fftshift(fft(temp,n_chirps));    %对rangeFFT结果进行n_chirps点FFT
      speed_profile(n,:,k)=temp_fft;  
    end
end

%角度FFT
angle_profile = [];
for n=1:n_samples   %range
    for m=1:n_chirps   %chirp
      temp=speed_profile(n,m,:);    
      temp_fft=fftshift(fft(temp,Q));    %对2D FFT结果进行Q点FFT
      angle_profile(n,m,:)=temp_fft;  
    end
end

%% 绘制2维FFT处理三维视图
figure;
speed_profile_temp = reshape(speed_profile(:,:,1),n_samples,n_chirps);  %处理第一个接收天线 
speed_profile_Temp = speed_profile_temp';   %(n_chirps,n_samples)
[X,Y]=meshgrid((0:n_samples-1)*Fs*c/n_samples/2/Slope_Hz,(-n_chirps/2:n_chirps/2-1)*lambda/Tc/n_chirps/2);
mesh(X,Y,(abs(speed_profile_Temp))); 
xlabel('距离(m)');ylabel('速度(m/s)');zlabel('信号幅值');
title('2维FFT处理三维视图');
xlim([0 (n_samples-1)*Fs*c/n_samples/2/Slope_Hz]); ylim([(-n_chirps/2)*lambda/Tc/n_chirps/2 (n_chirps/2-1)*lambda/Tc/n_chirps/2]);

% %% plot 1D FFT in three-dimensional view
figure;
range_profile_temp = reshape(range_profile(:,:,1),n_samples,n_chirps);
range_profile_Temp = range_profile_temp';
[X,Y]=meshgrid((0:n_samples-1)*Fs*c/n_samples/2/Slope_Hz,(1:n_chirps));
mesh(X,Y,(abs(range_profile_Temp)));
xlabel('Range(m)');ylabel('Chirps');zlabel('Signal amplitude');
title('1D FFT in three-dimensional view');
xlim([0 (n_samples-1)*Fs*c/n_samples/2/Slope_Hz]); ylim([0 n_chirps]);

%% 计算峰值位置
angle_profile=abs(angle_profile);
pink=max(angle_profile(:));
disp(pink)
[row,col,pag]=ind2sub(size(angle_profile),find(angle_profile==pink));
%% 计算目标距离、速度、角度
fb = ((row-1)*Fs)/n_samples;         %差拍频率
fd = ((col-n_chirps/2-1)*Fs)/(n_samples*n_chirps); %多普勒频率
fw = (pag-Q/2-1)/Q;          %空间频率
R = c*(fb-fd)/2/Slope_Hz;          %距离公式
v = lambda*fd/2;            %速度公式
theta = asin(fw*lambda/d);  %角度公式
angle = theta*180/pi;
fprintf('目标距离： %f m\n',R);
fprintf('目标速度： %f m/s\n',v);
fprintf('目标角度： %f°\n',angle);


# SoilMoistureSensing

本实验旨在用FMCW雷达信号来对土壤的湿度信息进行测量。

## Device Info
本实验采用IWR6843isk开发板和DCA1000EVM采集卡，在mmWaveStudio平台上收集雷达数据。<br>
IWR6843isk的工作频率为60GHz到64GHz，最多可以设置3发4收，实验里使用1发4收。<br>

## FMCW Radar Configuration Setting
**使用方法**<br>
设备的使用方法可以参考[使用方法](https://blog.csdn.net/touchwith/article/details/130871174?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522171809826516800184152622%2522%252C%2522scm%2522%253A%252220140713.130102334..%2522%257D&request_id=171809826516800184152622&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~top_positive~default-1-130871174-null-null.142^v100^pc_search_result_base4&utm_term=mmWave%20Studio&spm=1018.2226.3001.4187)<br>

**脚本文件**<br>
使用mmwave_studio_02_01_01_00\mmWaveStudio\Scripts文件夹下的DataCaptureDemo_xWR脚本文件，一键进行配置和采集。<br>
脚本文件中有几个关键的函数，可以在Lua shell下输入help 函数名查看对应参数信息，来修改雷达的配置信息，例如：<br>
```
help ar1.ChanNAdcConfig
```
ar1.ChanNAdcConfig函数用于设置tx0、tx1、tx2、rx0、rx1、rx2、rx3 enable。<br>
ar1.ProfileConfig函数用于设置Start_Freq、Slope、采样点、采样率、天线增益等信息。<br>
ar1.ChirpConfig函数用于设置各个tx对应的chirp参数，最后三个参数分别表示tx0、tx1、tx2，例如(0,1,0)表示tx1。<br>
ar1.FrameConfig函数用于设置雷达帧的参数，例如帧的数目、一个雷达帧所含chirp的数目等。<br>

**参数设置过程碰到的问题**<br>
问题1：shell中显示adc_bin被占用<br>
分析：导致此问题的原因是对adc_bin文件同时进行读写的冲突<br>
解决方法：修改lua脚本中ar1.StartFrame()后面RSTD.Sleep()休眠的时间，使其长于雷达采集数据的时间，以实现采集完数据再执行ar1.StartMatlabPostProc函数，避免读写冲突<br>

## Experiment

**将反射板（不锈钢板10cm*10cm*1mm）埋在离桶底部10cm处，如图所示**<br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/%E5%8F%8D%E5%B0%84%E6%9D%BF1.jpg" width="300px">
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/%E5%8F%8D%E5%B0%84%E6%9D%BF2.jpg" width="300px">
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/%E5%8F%8D%E5%B0%84%E6%9D%BF%E4%BF%AF%E8%A7%86.jpg" width="300px"><br>

**往不锈钢板上埋土，使土壤表明距不锈钢10cm，土壤总深度为20cm，如图所示**<br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/%E5%9C%9F%E5%A3%A41.jpg" width="300px"><br>

**利用支架将雷达开发板和采集卡固定在土壤表面正上方50cm处，并保持雷达开发板水平垂直朝下，如图所示**<br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/%E6%80%BB%E8%A7%881.jpg" width="300px">
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/%E6%80%BB%E8%A7%884.jpg" width="300px"><br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/%E6%80%BB%E8%A7%882.jpg" width="300px">
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/%E6%80%BB%E8%A7%883.jpg" width="300px"><br>


**俯视图如下**<br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/%E4%BF%AF%E8%A7%861.jpg" width="300px">
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/%E4%BF%AF%E8%A7%862.jpg" width="300px"><br>

**采集设备布置如下**<br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/%E8%AE%BE%E5%A4%871.jpg" width="300px"><br>

土壤湿度采用谷物水分测定仪LDS-1G进行测量，测量误差在0.5%以内，湿度信息为25.8%。<br>

## Data Processing
### 2024.6.23
**adc_data1**<br>
Slope为29.982MHz/us，离土壤表面高度为50cm。<br>
对adc_data1进行rangeFFT后，发现信号最强的地方是在6.64m附近，峰值为3.16e6，其他地方的信号峰值均小于1.6e4，远小于峰值。<br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/adc_data1_range.png" width="600px"><br>

**adc_data4**<br>
Slope为59.997MHz/us，离土壤表面高度为50cm。<br>
对adc_data4进行rangeFFT后，与adc_data1结果类似。<br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/adc_data4_range.png" width="600px"><br>

**adc_data8**<br>
Slope为59.997MHz/us，离土壤表面高度为24cm。<br>
对adc_data8进行rangeFFT后，与adc_data1、4结果类似。<br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/adc_data8_range.png" width="600px"><br>

**问题**<br>
为什么在6.64m附近会有一个远高于其他地方的峰值存在。<br>
实验验证：在实验室环境下进行采集，得到的结果图如下所示，仍没有发生变化，排除环境因素的干扰。<br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/adc_data11_range.png" width="600px"><br>

### 2024.7.5
用mmwave_demo_visualizer直接处理雷达板上的数据(不需要连接DCA1000EVM)，结果如下。<br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/mmwave_demo_visualizer.png" width="600px"><br>
雷达板能正常读取数据，问题只可能出现在DCA1000EVM和mmwave studio的使用上。<br>

### 2024.7.8
查看官方提供的Lua脚本，发现ar1.EnableTestSource(1)函数会启动雷达生成仿真数据的功能，会影响数据采集的结果，关闭后即可正常采集数据。<br>

重新采集数据，雷达板距离土壤表面50cm处，离地面70cm处。<br>
**adc_data50_1_环境**<br>
不放置土壤，采集环境信息。从图中可以看到，峰值最高点为78cm，第二高点为68cm，而实际上雷达距地面为70cm。距离为0m和1.46m附近也存在一个较小的峰值。<br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/2024_7_7/adc_data50_1_%E7%8E%AF%E5%A2%83.png" width="600px"><br>

**adc_data50_8**
放置土壤，采集信息。从图中可以看到，峰值最高点仍然为78cm，但信号发生衰弱，且在48cm附近出现了一个新的峰值，对应土壤表面，58cm对应土壤里的不锈钢板。<br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/2024_7_7/adc_data50_8.png" width="600px"><br>

雷达板距离土壤表面30cm处，离地面50cm处。<br>
**adc_data30_1_环境**<br>
从图中可以看到，峰值最高点为58cm，而实际雷达距离地面为50cm，与前面的结果类似。<br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/2024_7_7/adc_data30_1_%E7%8E%AF%E5%A2%83.png" width="600px"><br>

**adc_data30_7**<br>
放置土壤，从图中可以看到，在29cm处有个波峰，对应土壤表面，在39cm处有个波峰，对应土壤中的铝板。68cm处有个波峰，这个波峰在环境采集中就存在，但峰值出现衰弱。<br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/2024_7_7/adc_data30_7.png" width="600px"><br>

**问题**<br>
数据的距离分辨率不够，影响对雷达数据的分析，需要调整雷达参数。<br>

**DOA估计算法**<br>
常见的DOA估计算法有3DFFT、DBF（CBF）、capon（MVDR，最小方差无畸变算法）、MUSIC、ESPRIT、DML(最大似然法)、OMP(Orthogonal Matching Pursuit，正交匹配追踪算法)、IAA(Iterative Adaptive Approach，迭代自适应法)。[DOA算法综述](https://blog.csdn.net/xhblair/article/details/128893343?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522171957480616800225585374%2522%252C%2522scm%2522%253A%252220140713.130102334.pc%255Fall.%2522%257D&request_id=171957480616800225585374&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~first_rank_ecpm_v1~hot_rank-12-128893343-null-null.142^v100^pc_search_result_base4&utm_term=%E9%9B%B7%E8%BE%BEDBF%E6%B5%8B%E8%A7%92&spm=1018.2226.3001.4187)<br>

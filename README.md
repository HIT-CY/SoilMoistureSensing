# SoilMoistureSensing

本实验旨在用FMCW雷达信号来对土壤的湿度信息进行测量。

## Device Info
本实验采用IWR6843isk开发板和DCA1000EVM采集卡，在mmWaveStudio平台上收集雷达数据。<br>
IWR6843isk的工作频率为60GHz到64GHz，最多可以设置3发4收，实验里使用1发4收。<br>

## FMCW Radar Configuration Setting
**使用方法**<br>
设备的使用方法可以参考[使用方法](https://blog.csdn.net/touchwith/article/details/130871174?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522171809826516800184152622%2522%252C%2522scm%2522%253A%252220140713.130102334..%2522%257D&request_id=171809826516800184152622&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~top_positive~default-1-130871174-null-null.142^v100^pc_search_result_base4&utm_term=mmWave%20Studio&spm=1018.2226.3001.4187)<br>

**脚本文件**<br>
也可以使用mmwave_studio_02_01_01_00\mmWaveStudio\Scripts文件夹下的DataCaptureDemo_xWR脚本文件，一键进行配置和采集。<br>
脚本文件中有几个关键的函数，可以在Lua shell下输入help 函数名查看对应参数信息，来修改雷达的配置信息。<br>
ar1.ChanNAdcConfig函数用于设置tx0、tx1、tx2、rx0、rx1、rx2、rx3 enable。<br>
ar1.ProfileConfig函数用于设置Start_Freq、Slope、采样点、采样率、天线增益等信息。<br>
ar1.ChirpConfig函数用于设置各个tx对应的chirp参数，最后三个参数分别表示tx0、tx1、tx2，例如(0,1,0)表示tx1。<br>
ar1.FrameConfig函数用于设置雷达帧的参数，例如帧的数目、一个雷达帧所含chirp的数目等。<br>

**参数设置过程碰到的问题**<br>
问题1：shell中显示adc_bin被占用<br>
导致此问题的原因是对adc_bin文件同时进行读写的冲突<br>
解决方法：修改lua脚本中ar1.StartFrame()后面RSTD.Sleep()休眠的时间，以实现采集完数据再执行ar1.StartMatlabPostProc函数<br>

## Experiment

**将反射板（不锈钢板10cm*10cm*1mm）埋在离桶底部10cm处，如图所示**<br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/%E5%8F%8D%E5%B0%84%E6%9D%BF1.jpg" width="300px"><br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/%E5%8F%8D%E5%B0%84%E6%9D%BF2.jpg" width="300px"><br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/%E5%8F%8D%E5%B0%84%E6%9D%BF%E4%BF%AF%E8%A7%86.jpg" width="300px"><br>

**往不锈钢板上埋土，使土壤表明距不锈钢10cm，土壤总深度为20cm，如图所示**<br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/%E5%9C%9F%E5%A3%A41.jpg" width="300px"><br>

**利用支架将雷达开发板和采集卡固定在土壤表面正上方50cm处，并保持雷达开发板水平垂直朝下，如图所示**<br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/%E6%80%BB%E8%A7%881.jpg" width="300px"><br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/%E6%80%BB%E8%A7%882.jpg" width="300px"><br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/%E6%80%BB%E8%A7%883.jpg" width="300px"><br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/%E6%80%BB%E8%A7%884.jpg" width="300px"><br>

**俯视图如下**<br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/%E4%BF%AF%E8%A7%861.jpg" width="300px"><br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/%E4%BF%AF%E8%A7%862.jpg" width="300px"><br>

**采集设备布置如下**<br>
<img src="https://github.com/HIT-CY/SoilMoistureSensing/blob/master/Imag/%E8%AE%BE%E5%A4%871.jpg" width="300px"><br>

土壤湿度为25.8%。

## Data Processing

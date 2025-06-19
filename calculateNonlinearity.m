% 文件夹路径
= 'D:\优化策略\优化不含短周期\';

% 文件名模式
filePatternfilePattern = fullfile(folderPath, 'S_box_with_short_cycle_trial_*.txt');fullfile(folderPath, 'S_box_with_short_cycle_trial_*.txt');

获取所有符合模式的文件
sboxFiles = dir(filePattern);dir(filePattern);

% 存储非线性值
非线性值 = 零值(1, 长度(查找表文件));零值(1, 长度(查找表文件));

% 遍历所有文件并计算非线性值
对于对于 k = 1:长度(sboxFiles)k = 1:长度(sboxFiles)
    % 读取文件
    基础文件名 = sbox文件(k).名称;基础文件名 = sbox文件(k).名称;
    fullFileName = fullfile(folderPath, baseFileName);fullFileName = fullfile(folderPath, baseFileName);
    sbox = 加载(fullFileName);sbox = 加载(fullFileName);
    
    % 调用非线性计算函数
    非线性值(k) = 非线性(置换盒);非线性值(k) = 非线性(置换盒);
结束

计算平均非线性值
平均非线性 = 平均值(非线性值);平均(非线性值);
最小非线性度最小非线性度 = 最小(非线性度值);最小(非线性度值);
最大非线性最大非线性 = 最大(非线性值);最大(非线性值);

% 打印平均非线性值
fprintf(fprintf('平均非线性值: %f\n'， 平均非线性);非线性\n'， 平均非线性);
fprintf(fprintf('最小非线性值: %f'\n'， minNonlinearity);f'\n''， minNonlinearity);
fprintf(fprintf('最大非线性值: %f\n', maxNonlinearity);f\n', maxNonlinearity);

% 绘制非线性值点状图
figure图形;
scatter(1scatter(1:length(nonlinearityValues), nonlinearityValues, 'filled');length(nonlinearityValues), nonlinearityValues, 'filled');
xlabel(xlabel('S盒');S-box');
ylabel(ylabel('Nonlinearity');Nonlinearity');
grid网格开启;on;

% 非线性计算函数的定义 (根据已有的nonlinearity.m文件)(根据已有的nonlinearity.m文件)
% 函数 nl = nonlinearity(sbox)function nl = nonlinearity(sbox)
%     % 此处应为nonlinearity.m文件中的代码nonlinearity.m文件中的代码
% 结束结束

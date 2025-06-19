% 文件夹路径
folderPath = 'D:\MATLAB仿真程序\论文2\S盒构造\S盒测试\混合策略\';

% 文件名模式
filePattern = fullfile(folderPath, 'S_box_with_short_cycle_trial_*.txt');

% 获取所有符合模式的文件
sboxFiles = dir(filePattern);

% 存储非线性值
nonlinearityValues = zeros(1, length(sboxFiles));

% 遍历所有文件并计算非线性值
for k = 1:length(sboxFiles)
    % 读取文件
    baseFileName = sboxFiles(k).name;
    fullFileName = fullfile(folderPath, baseFileName);
    sbox = load(fullFileName);
    
    % 调用非线性计算函数
    nonlinearityValues(k) = nonlinearity(sbox);
end

% 计算平均非线性值
averageNonlinearity = mean(nonlinearityValues);
minNonlinearity = min(nonlinearityValues);
maxNonlinearity = max(nonlinearityValues);

% 打印平均非线性值
fprintf('平均非线性值: %f\n', averageNonlinearity);
fprintf('最小非线性值: %f\n', minNonlinearity);
fprintf('最大非线性值: %f\n', maxNonlinearity);

% 绘制非线性值点状图
figure;
scatter(1:length(nonlinearityValues), nonlinearityValues, 'filled');
xlabel('S-box');
ylabel('Nonlinearity');
grid on;

% 非线性计算函数的定义 (根据已有的nonlinearity.m文件)
% function nl = nonlinearity(sbox)
%     % 此处应为nonlinearity.m文件中的代码
% end

% 文件夹路径
folderPath = 'D:\MATLAB仿真程序\优化';
%folderPath = 'D:\MATLAB仿真程序\筛选';
%folderPath = 'D:\MATLAB仿真程序\混合';
% 文件名模式
filePattern = fullfile(folderPath, 'S_box_*.txt');

% 获取所有符合模式的文件
sboxFiles = dir(filePattern);

% 存储非线性值和对应的文件名
nonlinearityValues = zeros(1, length(sboxFiles));
fileNames = cell(1, length(sboxFiles));

% 初始化最大非线性值和对应的索引
maxNLValue = -inf;
maxNLIndex = 0;

% 遍历所有文件并计算非线性值
for k = 1:length(sboxFiles)
    % 读取文件
    baseFileName = sboxFiles(k).name;
    fullFileName = fullfile(folderPath, baseFileName);
    sbox = load(fullFileName);
    
    % 调用非线性计算函数
    nonlinearityValues(k) = nonlinearity(sbox);
    fileNames{k} = baseFileName;
    
    % 跟踪最大非线性值及其索引
    if nonlinearityValues(k) > maxNLValue
        maxNLValue = nonlinearityValues(k);
        maxNLIndex = k;
    end
end

% 计算统计数据
averageNonlinearity = mean(nonlinearityValues);
minNonlinearity = min(nonlinearityValues);
maxNonlinearity = max(nonlinearityValues);

% 打印统计结果
fprintf('平均非线性值: %f\n', averageNonlinearity);
fprintf('最小非线性值: %f\n', minNonlinearity);
fprintf('最大非线性值: %f\n', maxNonlinearity);
fprintf('最大非线性S盒文件: %s\n', fileNames{maxNLIndex});

% 保存最大非线性S盒到单独文件
if maxNLIndex > 0
    % 创建保存目录（如果不存在）
    outputDir = fullfile(folderPath, 'Max_Nonlinearity_Sbox');
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    % 构建输出文件名
    [~, nameWithoutExt, ~] = fileparts(fileNames{maxNLIndex});
    outputFileName = fullfile(outputDir, [nameWithoutExt '_MAX_NL.txt']);
    
    % 读取最大非线性S盒的数据
    maxNLSbox = load(fullfile(folderPath, fileNames{maxNLIndex}));
    
    % 保存到新文件
    fileID = fopen(outputFileName, 'w');
    if fileID == -1
        error('无法创建文件: %s', outputFileName);
    end
    
    % 写入S盒数据
    for i = 1:size(maxNLSbox, 1)
        for j = 1:size(maxNLSbox, 2)
            fprintf(fileID, '%d ', maxNLSbox(i, j));
        end
        fprintf(fileID, '\n');
    end
    
    fclose(fileID);
    fprintf('最大非线性S盒已保存到: %s\n', outputFileName);
else
    fprintf('未找到有效的S盒文件\n');
end

% 绘制非线性值点状图
figure;
scatter(1:length(nonlinearityValues), nonlinearityValues, 'filled');
hold on;
% 标记最大值点
plot(maxNLIndex, maxNLValue, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
hold off;
xlabel('S-box');
ylabel('Nonlinearity');
title('S盒非线性值分布');
grid on;
legend('非线性值', '最大值');
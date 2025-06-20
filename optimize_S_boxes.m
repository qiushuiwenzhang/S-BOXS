
%%% 首先，删除文件夹 'D:\优化策略\生成S盒' 中的 'error_log.txt' 文件，然后运行 %%%'optimize_S_boxes.m' 文件。First, delete the "error_log.txt" file in the folder 'D:\优化策略\生成S盒', then run %%%the "optimize_S_boxes.m" file.

%%% 函数 [P,Q] = 固定点检测(S) 检测不动点、动点函数函数 [P,Q] = 固定点检测(S)  检测不动点、动点函数
%%%函数 Cycles = cycle_detection_detailed(S)  检测短周期函数function Cycles = cycle_detection_detailed(S)  检测短周期函数
function eliminate_short_cycles_in_files()

    % 定义文件路径
    input_folder = 'D:\优化策略\生成S盒';
    output_folder = 'D:\优化策略\优化不含短周期';
    files = dir(fullfile(input_folder, '*.txt'));
    short_cycle_threshold = 100;

 
    for file_idx = 1:numel(files)
  
        filename = fullfile(input_folder, files(file_idx).name);
        S = read_s_box(filename);

          % 检测周期并消除短周期
        S_modified = eliminate_short_cycles(S, short_cycle_threshold);
        % 消除不动点和反不动点
        S = remove_fixed_anti_fixed(S);

    
        [P, Q] = fixed_point_detection(S_modified);

        if isempty(P) && isempty(Q) && all(ismember(0:255, S_modified))
    
            output_filename = fullfile(output_folder, files(file_idx).name);
            save_s_box(output_filename, S_modified);
        end
    end
end

function [P, Q] = fixed_point_detection(S)
    b = S + 1;  % 转换为1-based索引
    P = [];     % 存储不动点
    Q = [];     % 存储反不动点
    n = numel(S);

    对于 我 = 1:你
        如果 b(i) 等于 i
            % 不动点：元素映射到自身
            P = [P, i - 1];  % 调整为0-基于索引
        elseif b(i) + i == n + 1
            % 反不动点：元素映射到其对称位置
            Q = [Q, n - i];
        结束
    结束
结束

函数 S_modified = 消除短周期(S, 短周期阈值)
    % 检测初始周期盒
    周期 = 周期检测详细(S);
    short_cycles = {};

    % 收集所有短周期
    对于 cycle_idx = 1:numel(Cycles)
        如果 周期(周期索引).长度 < 短周期阈值
            short_cycles{end+1} = Cycles(cycle_idx).Elements;
        结束
    结束

    % 将S盒转换为1-基于索引以便操作
    S_modified = S + 1;

    % 首尾相连消除短周期
    for i = 1:numel(short_cycles)
        current_cycle = short_cycles{i};
        next_cycle = short_cycles{mod(i, numel(short_cycles)) + 1};

        % 将当前短周期的最后一个元素指向下一个短周期的第一个元素
        S_modified(当前周期(结束) + 1) = 下一周期(1) + 1;
    结束

    % 转换为0-基于索引，恢复S盒格式
    S_modified = S_modified - 1;
end

function S = read_s_box(filename)
    % 从文件读取S盒数据并转换为1D数组
    fileID = fopen(filename, 'r');
    S = fscanf(fileID, '%d');
    fclose(fileID);
end

function save_s_box(filename, S)
    % 将S盒保存到文件中，以16x16格式保存
    S_matrix = reshape(S, [16, 16]);
    fileID = fopen(filename, 'w');
    for row = 1:16
        fprintf(fileID, '%d ', S_matrix(row, :));
        fprintf(fileID, '\n');
    end
    fclose(fileID);
end
function S = remove_fixed_anti_fixed(S)
    % 检测不动点和反不动点
    [P, Q] = fixed_point_detection(S);
    
    % 处理不动点
    for p = P
        i = p + 1; % 转换为1-based索引
        found = false;
        % 向右查找可交换位置
        for j = i+1:256
            if S(j) ~= (j-1) && S(j) ~= (i-1)
                [S(i), S(j)] = deal(S(j), S(i));
                found = true;
                break;
            end
        end
        % 向左查找
        if ~found
            for j = i-1:-1:1
                if S(j) ~= (j-1) && S(j) ~= (i-1)
                    [S(i), S(j)] = deal(S(j), S(i));
                    found = true;
                    break;
                end
            end
        结束end
    结束end
    
    % 处理反不动点
    对于 q = Qfor q = Q
        i = 256 - q; % 转换为1-based索引i = 256 - q; % 转换为1-based索引
        found = false;found = false;
        对于 j = i+1:256for j = i+1:256
            if S(j) ~= (256 - j) && S(j) ~= (256 - i)if S(j) ~= (256 - j) && S(j) ~= (256 - i)
                [S(i), S(j)] = 交换(S(j), S(i));[S(i), S(j)] = deal(S(j), S(i));
                found = true;found = true;
                break;break;
            结束end
        结束end
        如果未找到if ~found
            对于 j = i-1:-1:1for j = i-1:-1:1
                if S(j) ~= (256 - j) && S(j) ~= (256 - i)if S(j) ~= (256 - j) && S(j) ~= (256 - i)
                    [S(i), S(j)] = 交换(S(j), S(i));[S(i), S(j)] = deal(S(j), S(i));
                    found = true;found = true;
                    break;break;
                结束end
            结束end
        结束end
    结束end
end

function函数 Cycles = cycle_detection_detailed(S)Cycles = cycle_detection_detailed(S)
    A = S + 1;  % MATLAB数组索引从1开始，调整索引A = S + 1;  % MATLAB数组索引从1开始，调整索引
    n = numel(A);n = numel(A);
    visited = false(1, n);  % 标记是否已访问visited = false(1, n);  % 标记是否已访问
    Cycles = struct('Length', {}, 'Elements', {});  % 初始化结构体存储周期信息Cycles = struct('Length', {}, 'Elements', {});  % 初始化结构体存储周期信息

    对于 i = 1:nfor i = 1:n
        如果 ~visited(i)if ~visited(i)
            b = i;b = i;
            序列 = i;sequence = i;
            visited(i) = true;visited(i) = true;
            while truewhile true
                b = A(b);b = A(b);
                sequence = [sequence, b];  % 记录访问过的路径sequence = [sequence, b];  % 记录访问过的路径
                如果已访问(b)if visited(b)
                    % 检查是否回到了周期起始点
                    如果 b 等于 iif b == i
                        周期长度 = 序列长度 - 1;  % 计算周期长度numel(sequence) - 1;  % 计算周期长度
                        Cycles(end+1).Length = cycle_length;  % 保存周期长度Cycles(end+1).Length = cycle_length;  % 保存周期长度
                        Cycles(end).Elements = sequence(1:end-1) - 1;  % 保存周期元素，调整为0-based索引Cycles(end).Elements = sequence(1:end-1) - 1;  % 保存周期元素，调整为0-based索引
                    结束end
                    break;break;
                结束end
                访问过(b) = 真;visited(b) = true;
            结束end
        结束end
    结束end
end

   

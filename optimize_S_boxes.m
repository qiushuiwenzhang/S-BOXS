function eliminate_short_cycles_in_files()

    % 定义文件路径
    input_folder = 'D:\MATLAB仿真程序\原始S盒';
    output_folder = 'D:\MATLAB仿真程序\优化';
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

    for i = 1:n
        if b(i) == i
            % 不动点：元素映射到自身
            P = [P, i - 1];  % 调整为0-based索引
        elseif b(i) + i == n + 1
            % 反不动点：元素映射到其对称位置
            Q = [Q, n - i];
        end
    end
end

function S_modified = eliminate_short_cycles(S, short_cycle_threshold)
    % 检测初始S盒的周期
    Cycles = cycle_detection_detailed(S);
    short_cycles = {};

    % 收集所有短周期
    for cycle_idx = 1:numel(Cycles)
        if Cycles(cycle_idx).Length < short_cycle_threshold
            short_cycles{end+1} = Cycles(cycle_idx).Elements;
        end
    end

    % 将S盒转换为1-based索引以便操作
    S_modified = S + 1;

    % 首尾相连消除短周期
    for i = 1:numel(short_cycles)
        current_cycle = short_cycles{i};
        next_cycle = short_cycles{mod(i, numel(short_cycles)) + 1};

        % 将当前短周期的最后一个元素指向下一个短周期的第一个元素
        S_modified(current_cycle(end) + 1) = next_cycle(1) + 1;
    end

    % 转换为0-based索引，恢复S盒格式
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
        end
    end
    
    % 处理反不动点
    for q = Q
        i = 256 - q; % 转换为1-based索引
        found = false;
        for j = i+1:256
            if S(j) ~= (256 - j) && S(j) ~= (256 - i)
                [S(i), S(j)] = deal(S(j), S(i));
                found = true;
                break;
            end
        end
        if ~found
            for j = i-1:-1:1
                if S(j) ~= (256 - j) && S(j) ~= (256 - i)
                    [S(i), S(j)] = deal(S(j), S(i));
                    found = true;
                    break;
                end
            end
        end
    end
end

function Cycles = cycle_detection_detailed(S)
    A = S + 1;  % MATLAB数组索引从1开始，调整索引
    n = numel(A);
    visited = false(1, n);  % 标记是否已访问
    Cycles = struct('Length', {}, 'Elements', {});  % 初始化结构体存储周期信息

    for i = 1:n
        if ~visited(i)
            b = i;
            sequence = i;
            visited(i) = true;
            while true
                b = A(b);
                sequence = [sequence, b];  % 记录访问过的路径
                if visited(b)
                    % 检查是否回到了周期起始点
                    if b == i
                        cycle_length = numel(sequence) - 1;  % 计算周期长度
                        Cycles(end+1).Length = cycle_length;  % 保存周期长度
                        Cycles(end).Elements = sequence(1:end-1) - 1;  % 保存周期元素，调整为0-based索引
                    end
                    break;
                end
                visited(b) = true;
            end
        end
    end
end

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

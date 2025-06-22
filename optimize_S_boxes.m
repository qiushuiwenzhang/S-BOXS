function eliminate_short_cycles_in_files()

    % �����ļ�·��
    input_folder = 'D:\MATLAB�������\ԭʼS��';
    output_folder = 'D:\MATLAB�������\�Ż�';
    files = dir(fullfile(input_folder, '*.txt'));
    short_cycle_threshold = 100;

 
    for file_idx = 1:numel(files)
  
        filename = fullfile(input_folder, files(file_idx).name);
        S = read_s_box(filename);

          % ������ڲ�����������
        S_modified = eliminate_short_cycles(S, short_cycle_threshold);
        % ����������ͷ�������
        S = remove_fixed_anti_fixed(S);

    
        [P, Q] = fixed_point_detection(S_modified);

        if isempty(P) && isempty(Q) && all(ismember(0:255, S_modified))
    
            output_filename = fullfile(output_folder, files(file_idx).name);
            save_s_box(output_filename, S_modified);
        end
    end
end

function [P, Q] = fixed_point_detection(S)
    b = S + 1;  % ת��Ϊ1-based����
    P = [];     % �洢������
    Q = [];     % �洢��������
    n = numel(S);

    for i = 1:n
        if b(i) == i
            % �����㣺Ԫ��ӳ�䵽����
            P = [P, i - 1];  % ����Ϊ0-based����
        elseif b(i) + i == n + 1
            % �������㣺Ԫ��ӳ�䵽��Գ�λ��
            Q = [Q, n - i];
        end
    end
end

function S_modified = eliminate_short_cycles(S, short_cycle_threshold)
    % ����ʼS�е�����
    Cycles = cycle_detection_detailed(S);
    short_cycles = {};

    % �ռ����ж�����
    for cycle_idx = 1:numel(Cycles)
        if Cycles(cycle_idx).Length < short_cycle_threshold
            short_cycles{end+1} = Cycles(cycle_idx).Elements;
        end
    end

    % ��S��ת��Ϊ1-based�����Ա����
    S_modified = S + 1;

    % ��β��������������
    for i = 1:numel(short_cycles)
        current_cycle = short_cycles{i};
        next_cycle = short_cycles{mod(i, numel(short_cycles)) + 1};

        % ����ǰ�����ڵ����һ��Ԫ��ָ����һ�������ڵĵ�һ��Ԫ��
        S_modified(current_cycle(end) + 1) = next_cycle(1) + 1;
    end

    % ת��Ϊ0-based�������ָ�S�и�ʽ
    S_modified = S_modified - 1;
end

function S = read_s_box(filename)
    % ���ļ���ȡS�����ݲ�ת��Ϊ1D����
    fileID = fopen(filename, 'r');
    S = fscanf(fileID, '%d');
    fclose(fileID);
end

function save_s_box(filename, S)
    % ��S�б��浽�ļ��У���16x16��ʽ����
    S_matrix = reshape(S, [16, 16]);
    fileID = fopen(filename, 'w');
    for row = 1:16
        fprintf(fileID, '%d ', S_matrix(row, :));
        fprintf(fileID, '\n');
    end
    fclose(fileID);
end
function S = remove_fixed_anti_fixed(S)
    % ��ⲻ����ͷ�������
    [P, Q] = fixed_point_detection(S);
    
    % ��������
    for p = P
        i = p + 1; % ת��Ϊ1-based����
        found = false;
        % ���Ҳ��ҿɽ���λ��
        for j = i+1:256
            if S(j) ~= (j-1) && S(j) ~= (i-1)
                [S(i), S(j)] = deal(S(j), S(i));
                found = true;
                break;
            end
        end
        % �������
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
    
    % ����������
    for q = Q
        i = 256 - q; % ת��Ϊ1-based����
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
    A = S + 1;  % MATLAB����������1��ʼ����������
    n = numel(A);
    visited = false(1, n);  % ����Ƿ��ѷ���
    Cycles = struct('Length', {}, 'Elements', {});  % ��ʼ���ṹ��洢������Ϣ

    for i = 1:n
        if ~visited(i)
            b = i;
            sequence = i;
            visited(i) = true;
            while true
                b = A(b);
                sequence = [sequence, b];  % ��¼���ʹ���·��
                if visited(b)
                    % ����Ƿ�ص���������ʼ��
                    if b == i
                        cycle_length = numel(sequence) - 1;  % �������ڳ���
                        Cycles(end+1).Length = cycle_length;  % �������ڳ���
                        Cycles(end).Elements = sequence(1:end-1) - 1;  % ��������Ԫ�أ�����Ϊ0-based����
                    end
                    break;
                end
                visited(b) = true;
            end
        end
    end
end

function main_generate_sboxes()
    % 创建目标文件夹
    target_dir = 'D:\MATLAB仿真程序\原始S盒';
    if ~exist(target_dir, 'dir')
        mkdir(target_dir);
    end

    % 生成4000个S盒 根据不同策略选择。
    for i = 1:4000
        try
            fprintf('正在生成第 %d 个S盒...\n', i);
            S_box = generate_sbox();
            
            filename = sprintf('S_box_%03d.txt', i);
            full_path = fullfile(target_dir, filename);
            
            dlmwrite(full_path, S_box, 'delimiter', ' ', 'precision', '%3d');
            fprintf('成功保存到 %s\n', full_path);
            
        catch ME
         
            fprintf('生成第 %d 个S盒时发生错误: %s\n', i, ME.message);
            log_error(target_dir, i, ME.message);
        end
    end
end

function log_error(target_dir, index, msg)
  
    error_log = fullfile(target_dir, 'error_log.txt');
    fid = fopen(error_log, 'a');
    if fid == -1
        error('无法打开错误日志文件');
    end
    fprintf(fid, 'S盒 %03d 错误: %s\n', index, msg);
    fclose(fid);
end

function S_box = generate_sbox()
 
    u = 100;
    v = 100;
    max_attempts = 1000;
    B = [];
    success = false;
    
   
    for attempt = 1:max_attempts
        x0 = rand();
        y0 = rand();
        
        % 迭代混沌映射
        [x_seq, y_seq] = iterate_2desm(x0, y0, u, v, 200 + 64);
        x_seq = x_seq(201:end);
        y_seq = y_seq(201:end);
        
        % 生成矩阵B
       
         B_data = mod(floor((mod(exp(x_seq), 1)) * 1e6), 2);
        B = reshape(B_data, 8, 8)';
      
        if gfrank(B, 2) == 8
            success = true;
            break;
        else
             x0 = mod(x_seq(end) + mod(sum(x_seq), 1), 1);
            y0 = mod(y_seq(end) + mod(sum(y_seq), 1), 1);
        end
    end
    
    if ~success
        error('无法生成可逆矩阵B（最大尝试次数%d次）', max_attempts);
    end
    
    % 生成初始S盒
    irr_poly = 283;
    S0 = zeros(256, 8);
    for i = 0:255
        if i == 0
            inv_byte = 0;
        else
            element = gf(i, 8, irr_poly);
            inv_element = inv(element);
            inv_byte = double(inv_element.x);
        end
        S0(i+1, :) = de2bi(inv_byte, 8, 'left-msb');
    end
    
    
    sum_y = sum(y_seq);
   sum_x = sum(x_seq);
    c_decimal = mod(floor(mod(sum_y+ sum_x, 1) * 1e16), 256) + 1;
    C = de2bi(c_decimal, 8, 'left-msb')';
    
 
    S1 = mod(B * S0' + repmat(C, 1, 256), 2);
    
    S_box = bi2de(S1', 'left-msb');
    S_box = reshape(S_box, 16, 16);
end

function [x_seq, y_seq] = iterate_2desm(x0, y0, u, v, iterations)
    x_seq = zeros(1, iterations);
    y_seq = zeros(1, iterations);
    x = x0;
    y = y0;
    for i = 1:iterations
        x_new = sin(u * cos(v / y));
        y_new = cos(u * sin(v * x^2));
        x_seq(i) = x_new;
        y_seq(i) = y_new;
        x = x_new;
        y = y_new;
    end
end
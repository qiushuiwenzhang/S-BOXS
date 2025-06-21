函数 main_generate_sboxes()
    % 创建目标文件夹
    target_dir = 'D:\优化策略\生成S盒'
    如果 ~存在(目标目录, '目录')
        创建目录(目标目录);
    结束

    % 生成2000个S盒 根据不同策略选择少
    对于 我 = 1:2000
        尝试
            fprintf('正在生成第 %d 个S盒...\n'', i);
            S_box = 生成S盒();
            
            filename = sprintf('S_box_%03d.txt', i);
            full_path = fullfile(target_dir, filename);
            
            dlmwrite(full_path, S_box, 'delimiter', ' ', 'precision', '%3d');
            fprintf('成功保存到 %s\\n'， full_path);
            
        抓住 我
         
            fprintf('生成第 %d 个S盒时发生错误: %s\\n'， i, ME.message);
            log_error(目标目录, i, ME.消息);
        结束
    结束
结束

函数 记录错误(目标目录, 索引, 消息)
  
    error_log = fullfile(target_dir, 'error_log.'txt');
    fid = 打开文件(错误日志, 'a');
    如果 文件描述符 == -1
        错误('无法打开错误日志文件');
    结束
    fprintf(fid, 'S盒 %03d 错误: %s\n', index, msg);
    关闭文件(文件描述符);
结束

函数 S_box = 生成S盒()
 
    u = 100;
    速度 = 100;
    最大尝试次数 = 1000;
    B = [];
    成功 = 假;
    
   
    尝试 次数 = 1：最大尝试次数
        x0 = 随机数();
        随机数y0 = 生成的随机数();
        
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

函数 [x_seq, y_seq] = iterate_2desm(x0, y0, u, v, iterations)
    x_seq = zeros(1, iterations);
    y_seq = zeros(1, iterations);
    x = x0;
    y =  y0 ;
    对于 我 = 1:迭代次数
        x_new = sin(u * cos(v / y));
        y_new = cos(u * sin(v * x^2));
        x_seq(i) = x_new;
        y_seq(i) = y_new;
        x = x_new;
        y = y_新;
    结束
结束

a_values = 1:0.5:100;
b_values = 1:0.5:100;
lyapunov_exponents = zeros(length(a_values), length(b_values), 2);

for i = 1:length(a_values)
    for j = 1:length(b_values)
        a_val = a_values(i);
        b_val = b_values(j);
        x_vals = [0.1; 0.1]; % 初始条件
        lambda = zeros(2, 1);
        
        for k = 1:100 % 迭代时间步数
            x = x_vals(1);
            y = x_vals(2);
            
        
%             x_next = sin(a_val*cos(b_val*y));
%             y_next = cos(a_val*sin(b_val/x));
              x_next = sin(a_val*cos(b_val/y));
              y_next = cos(a_val*sin(b_val*x^2));
            
         
%             J =[0, -a_val*b_val*sin(b_val*y)*cos(a_val*cos(b_val*y));
%                 (a_val*b_val*sin(a_val*sin(b_val/x))*cos(b_val/x))/x^2, 0];
              J = [ 0, (a_val*b_val*sin(b_val/y)*cos(a_val*cos(b_val/y)))/y^2;
                    -2*a_val*b_val*x*sin(a_val*sin(b_val*x^2))*cos(b_val*x^2), 0];
    
            if isinf(x_next) || isnan(x_next) || isinf(y_next) || isnan(y_next)
                break;
            end
            
            % 计算Lyapunov指数
            [~, R] = qr(J);
            lambda = lambda + log(abs(diag(R)));
            
            % 更新x和y值
            x_vals = [x_next; y_next];
        end
        
        lyapunov_exponents(i, j, :) = lambda/100;
    end
end

% 绘制 Lyapunov 指数随参数 a、b 的变化的图像
[a_grid, b_grid] = meshgrid(a_values, b_values);
lambda1 = lyapunov_exponents(:, :, 1);
lambda2 = lyapunov_exponents(:, :, 2);

% 设置绘图参数
figure('Color', 'white'); % 设置图形背景为白色
colormap(parula); % 使用parula调色板，可以根据喜好更改

% 绘制第一个图
figure; % 创建一个新的窗口
surf(a_grid, b_grid, lambda1, 'EdgeColor', 'none');
xlabel('u');
ylabel('v');
zlabel('LE1');
shading interp; % 平滑绘制的曲面

% 绘制第二个图
figure; % 创建另一个新的窗口
surf(a_grid, b_grid, lambda2, 'EdgeColor', 'none');
xlabel('u');
ylabel('v');
zlabel('LE2');
shading interp; % 平滑绘制的曲面

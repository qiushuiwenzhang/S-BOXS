syms x y a_val b_val
 x_next = sin(a_val*pi*cos(b_val/y));
 y_next = cos(a_val*sin(b_val*x^2));

J = jacobian([x_next; y_next], [x y])
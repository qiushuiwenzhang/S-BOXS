 function [P,Q] = fixed_point_detection(S)
b=S+1;
P=[];
Q=[];
for i=1:size(S,2)
    
    if b(i)==i
        p=i-1;
        P=[P,p];
    elseif b(i)+i==size(S,2)+1
        q=256-i;
        Q=[Q,q];
    end
end
disp('P里是不动点');
P
disp('Q里是反不动点');
Q


function [f,R,df] = Structure_Analysis(T,N,W,E)
format long g
T = round(T);
N = round(N);
W = round(W);
M = 2*N-3;

%Tower
if T == 1
    %Forces f and R
    a = atan(3*sqrt(3)/2); %alpha
    B = atan(sqrt(3)/2);   %beta
    t = pi/3;              %theta
    b = zeros(16,1);
    b(16,1) = W;
    A = [cos(a) cos(B) 0 0 0 0 0 0 0 0 0 0 0 1 0 0;
        sin(a) sin(B) 0 0 0 0 0 0 0 0 0 0 0 0 1 0;
        0 0 -cos(B) -cos(a) 0 0 0 0 0 0 0 0 0 0 0 0;
        0 0 sin(B) sin(a) 0 0 0 0 0 0 0 0 0 0 0 1;
        -cos(a) 0 0 0 1 0 cos(t) 0 0 0 0 0 0 0 0 0;
        -sin(a) 0 0 0 0 0 sin(t) 0 0 0 0 0 0 0 0 0;
        0 -cos(B) cos(B) 0 -1 1 0 -cos(t) cos(t) 0 0 0 0 0 0 0;
        0 -sin(B) -sin(B) 0 0 0 0 sin(t) sin(t) 0 0 0 0 0 0 0;
        0 0 0 cos(a) 0 -1 0 0 0 -cos(t) 0 0 0 0 0 0;
        0 0 0 -sin(a) 0 0 0 0 0 sin(t) 0 0 0 0 0 0;
        0 0 0 0 0 0 -cos(t) cos(t) 0 0 1 cos(a) 0 0 0 0;
        0 0 0 0 0 0 -sin(t) -sin(t) 0 0 0 sin(a) 0 0 0 0;
        0 0 0 0 0 0 0 0 -cos(t) cos(t) -1 0 -cos(a) 0 0 0;
        0 0 0 0 0 0 0 0 -sin(t) -sin(t) 0 0 sin(a) 0 0 0;
        0 0 0 0 0 0 0 0 0 0 0 -cos(a) cos(a) 0 0 0;
        0 0 0 0 0 0 0 0 0 0 0 -sin(a) -sin(a) 0 0 0];
    X = pinv(A)*b;
    f = X(1:13,1);
    R = X(14:16,1);
end

%Crane
if T == 2
    %Forces f and R
    g = atan(sqrt(3)/2);  %gamma
    t = pi/3;             %theta
    b = [0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; W];
    A = [1 cos(t) 0 0 0 0 0 0 0 1 0 0;
        0 sin(t) 0 0 0 0 0 0 0 0 1 0;
        -1 -cos(t) cos(t) 0 0 0 0 0 0 0 0 0;
        0 0 sin(t) sin(t) 0 0 0 0 0 0 0 1;
        0 -cos(t) cos(t) 0 1 cos(t) 0 0 0 0 0 0;
        0 -sin(t) 0 0 0 0 0 0 0 0 0 0;
        0 0 0 -cos(t) -1 0 -cos(t) 0 cos(t) 0 0 0;
        0 0 0 -sin(t) 0 0 sin(t) 0 sin(t) 0 0 0;
        0 0 0 0 0 -cos(t) cos(t) cos(g) 0 0 0 0;
        0 0 0 0 0 -sin(t) -sin(t) sin(g) 0 0 0 0;
        0 0 0 0 0 0 0 -cos(g) -cos(g) 0 0 0;
        0 0 0 0 0 0 0 -sin(g) -sin(g) 0 0 0];
    format long g
    X = pinv(A)*b;
    f = X(1:9,1);
    R = X(10:12,1);
end

%Bridge
if T == 3
    %Forces f and R
    t = pi/3;           %theta
    b = zeros(2*N,1);
    b(N+1,1) = W;
    A = zeros(2*N,2*N);
    A(1,8) = 1; A(1,1) = cos(t); A(1,2) = 1;
    A(2,9) = 1; A(2,1) = sin(t);
    A(3,1) = -cos(t); A(3,3) = cos(t); A(3,4) = 1;
    A(4,1) = -sin(t); A(4,3) = -sin(t);
    for n = 3:N-2
        if rem(n,2) == 0
            A(2*n-1,2*n-4) = -1; A(2*n-1,2*n-3) = -cos(t); A(2*n-1,2*n-1) = cos(t); A(2*n-1,2*n) = 1;
            A(2*n,2*n-3) = sin(t); A(2*n,2*n-1) = sin(t);
        end
        if rem(n,2) ~= 0
            A(2*n-1,2*n-4) = -1; A(2*n-1,2*n-3) = -cos(t); A(2*n-1,2*n-1) = cos(t); A(2*n-1,2*n) = 1;
            A(2*n,2*n-3) = sin(t); A(2*n,2*n-1) = sin(t);
            %if n ~= (N + 1)/2
            %    b(2*n,1) = 0;
            %end
            %if n == (N + 1)/2
            %    b(2*n,1) = W;
        end
    end
    for n = N - 1
        A(2*N-3,2*n-4) = -1; A(2*N-3,2*n-3) = -cos(t); A(2*N-3,2*n-1) = cos(t);
        A(2*N-2,2*n-3) = -sin(t); A(2*N-2,2*n-1) = -sin(t);
    end
    for n = N
        A(2*N-1,2*n-4) = -1; A(2*N-1,2*n-3) = -cos(t);
        A(2*N,2*n-3) = sin(t); A(2*N,N) = 1;
    end
    X = pinv(A)*b;
    f = X(1:2*N-3,1);
    R = X(2*N-2:2*N,1);
end

%Deformations df
if T == 1 || T == 2
    M = 2*N-3;
end
for m = 1:M
    dff = (f(m)/((E)*10^-4))*100;
    df(m,1) = dff;
end
end







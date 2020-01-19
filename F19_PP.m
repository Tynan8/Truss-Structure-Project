%Programming Project
clear
clc

%Structure Type
fprintf('****************\n 1 - Tower\n 2 - Crane\n 3 - Bridge\n');
T = input('Enter Structure Type: ');
switch T        %Load Data File and Set Axis
    case 1
        load('geomtopo1.mat');
    case 2
        load('geomtopo2.mat');
    case 3
        load('geomtopo3.mat');
        set(gcf, 'Position',  [400 500 750 250]);
end

invalid = 1;
if T == 1 || T == 2 || T == 3   %Input Validation
    invalid = 0;
    
    %Member Length d
    for M = 1 : length(memnod)
        p1 = memnod(M,1);
        p2 = memnod(M,2);
        d = sqrt((x(p2) - x(p1))^2 + (y(p2) - y(p1))^2);
        D(M) = d;
    end
    
    while invalid == 1        %User Input Validation
        fprintf('\nInvalid Entry. Please Enter 1, 2 or 3.\n\n');
        T = input('Enter Structure Type: ');
    end
end

%Plot
for M = 1 : length(memnod)  %members (lines)
    hold on
    axis off
    p1 = memnod(M,1);
    p2 = memnod(M,2);
    figure(1)
    line([x(p1) x(p2)], [y(p1) y(p2)],'linewidth',2,'color','k')
    mx = 0.5*x(p1)+0.5*x(p2);
    my = 0.5*y(p1)+0.5*y(p2);
    text(mx,my,num2str(M),'color','b')
    hold off;
end
for N = 1 : length(nodmem) %nodes (points)
    hold on
    figure(1)
    plot(x,y,'.','MarkerSize',20,'color','k')
    x1 = x(N);
    y1 = y(N);
    text(x1-0.035,y1+0.175,num2str(N),'color','r')
    hold off
end

%Material
load('materials.dat');
load('pricing.dat');
fprintf('\n 1 - Aluminum\n 2 - Steel\n 3 - Titanium\n');
material = input('\nEnter Material Type: ');


%Wmax
sf = 2;
a = 10^-4;
W = 0;

%Tower
if T == 1
    
    %Working Load
    syM = materials(material,3);
    sy = syM*10^6;
    Wmax = (a*sy)/sf;
    su = materials(material,4);
    Wf = ((su*10^-4)/sf)*10^6;
    W = Wmax;
    
    %Size Input
    fprintf('\n1 - Small (3.3 Feet)\n2 - Medium (6.6 Feet)\n3 - Large (16.4 Feet)\n\n');
    d1 = input('Enter Desired Tower Size: ');
    invalid = 1;
    if d1 == 1 || d1 == 2 || d3 == 3 %User Input Validation
        invalid = 0;
    end
    while invalid == 1
        fprintf('\nInvalid Input. Please Enter 1, 2 or 3');
        d1 = input('\n\nEnter Desired Tower Size: ');
    end
    
    switch d1
        case 1
            d2 = 1;
        case 2
            d2 = 2;
        case 3
            d2 = 5;
    end
    
    %Clearance and Footprint
    h = sqrt(3)*d2/2;
    H = 4*h;
    L = (sqrt((x(2)*d2)^2));
    Dt = sum(D,'all')*d2;
end

%Crane
if T == 2
    %Clearance and Footprint
    h = sqrt(3)*d/2;
    H = 4*h;
    L = 3*d;
    Dt = sum(D,'all');
    
    %Working Load Input
    syM = materials(material,3);
    sy = syM*10^6;
    Wmax = (a*sy)/sf;
    su = materials(material,4);
    Wf = ((su*10^-4)/sf)*10^6;
    W = input('Enter Desired Working Load For Crane (0 < W < 8203 Lbf): ');
    while W > Wmax    %User Input Validation
        fprintf('\nInvalid Input. Please Enter a Value Between 0 and 8203 Lbf.');
        W = input('\n\nEnter Desired Working Load For Crane (0 < W < 8203 Lbf): ');
    end
    W = W*4.448;    %lbs to N
end

%Bridge
if T == 3
    %Clearance
    h = sqrt(3)*d/2;
    H = h;
    Dt = sum(D,'all');
    
    %Work Loads
    sy = (materials(material,3))*10^6;
    Wmax = (sy*10^-4)/sf;
    su = (materials(material,4))*10^6;
    Wf = ((su*10^-4)/sf)*10^6;
    W = Wmax;
    
    %Span Length Input (Footprint)
    L = input('Enter Desired Length of Bridge (0 < L < 150 Feet): ');
    while L > 150 || L <= 0     %User Input Validation
        fprintf('\n\nInvalid Entry. Please Enter a Value Between 0 and 150')
        L = input('\n\nEnter Desired Length of Bridge (0 < L < 150 Feet): ');
    end
    L = L/3.281;    %ft to m
    u = round(0.5*(1.1*L));
    N = 4*u + 1;
    M = 8*u - 1;
    Ti = u - 1;
end

%Pricing
mP = pricing(material,2);
Pm = mP*Dt;
switch T
    case 1
        if d1 == 1
            Pf = 50;
        end
        if d1 == 2
            Pf = 100;
        end
        if d1 == 3
            Pf = 250;
        end
    case 2
        Pf = 50;
    case 3
        Pf = 52 + 2*(u - 1);
end

Pt = .08*Pm;
PT = Pm + Pf + Pt;

%Forces and Deformations
E = materials(material,2);
E = E*10^9;     # Young's modulus
dfm = Wmax/(E*10^-4)*100;
[f,R,df] = Structure_Analysis(T,N,W,E);

%Conversions
Wmax = Wmax/4.45;
Wf = Wf/4.45;
W = W/4.45;
L = L*3.28;
H = H*3.28;


%Outputs
Ts = ["Tower","Crane","Bridge"];
Tm = ["Aluminum","Steel","Titanium"];
fprintf('\n***************************\n\n');
fprintf('You Chose: %s %s\n',Tm(T),Ts(T));
fprintf(' Clearance: %.2g ft\n Footprint: %.2g ft\n Expected Load: %.4g lb',H,L,W);
fprintf('\n Max Rec''d Load: %.4g lb\n Max Deformation: %.4f %%\n Failure Load: %.4g lb\n',Wmax,dfm,Wf);
fprintf('\n***************************\n\n');
fprintf(' Cost\n Materials: $%.2f\n Fees: $%.2f\n Tax: $%.2f\n-------------\nTotal: $%.2f\n',Pm,Pf,Pt,PT);
fprintf('\n***************************\n\n');
fprintf('Forces, Reactions and Deformations\n\nMember     Force (N)      Deformation (%%)\n');
for i = 1:M
    fprintf('%i          %.5g         %7.6f\n',i,f(i,1),df(i,1));
end
fprintf('\nReaction (N)\n');
for i = 1:3
    fprintf('%6.1f\n',R(i));
end





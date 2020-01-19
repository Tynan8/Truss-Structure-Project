
for M = 1 : length(memnod)
    hold on
    p1 = memnod(M,1);
    p2 = memnod(M,2);
    line([x(p1) x(p2)], [y(p1) y(p2)])
    mx = 0.5*x(p1)+0.5*x(p2);
    my = 0.5*y(p1)+0.5*y(p2);
    text(mx,my,num2str(M),'color','b')
    axis([-0.25 3.25, -0.25 3.75])
    hold off;
end

for N = 1 : length(nodmem)
    hold on
    plot(x,y,'.','MarkerSize',15)
    x1 = x(N);
    y1 = y(N);
    text(x1-0.035,y1+0.15,num2str(N),'color','r')
    hold off
end
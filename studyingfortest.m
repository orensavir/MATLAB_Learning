x = linspace(0,2*pi,100);
subplot(1,2,1);
y1=-x.^2-2*x;
plot(x,y1,'*')
title('y1');
grid on

subplot(1,2,2)
y2=x.*sin(5*x);
plot(x,y2,'--')
title('y2');

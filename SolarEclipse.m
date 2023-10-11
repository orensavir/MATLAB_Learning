a=716;
v=255;
X=linspace(-10,10,a);
[~,r]=cart2pol(X,X');
colormap(gray.*[1 .78 .3]);
[t,g]=cart2pol(X+2.6,X'+1.4);
image(rescale(-1*(2*sin(t*10)+60*g.^.2),0,v))
hold on
h=exp(-(r-3)).*abs(ifft2(r.^-1.8.*cos(7*rand(a))));
h(r<3)=0;
image(v*ones(a),'AlphaData',rescale(h,0,1))
camva(3.8)

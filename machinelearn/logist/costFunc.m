function  [J,gradient] = costFunc(theat)
x = [0,0.1,0.2,0.3,4.5,5.6]';
y = [0,0,0,0,1,1]';

temp = theat(1) + theat(2).*x;
e = exp(-temp);
h = 1./(1+e);

m = size(x,1);

delta = log(h).*y+(1-y).*log(1-h);
J = -sum(delta)./m;

gradient(1) = sum(h-y)/m;
gradient(2) = sum((h-y).*x)/m;

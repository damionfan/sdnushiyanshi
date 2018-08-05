function [J,gradient] = costFunc(theta)
x = [1;2;3;4];
y = [1.1;2.2;2.7;3.8];

m = size(x,1);
hypothesis = theta(1) + theta(2)*x;

delta = hypothesis - y;
J = sum(delta.^2)/(2*m);
gradient(1) = sum(delta.*1)/m;
gradient(2) = sum(delta.*x)/m;

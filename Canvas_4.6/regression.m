% X, independent variable (such as signal areas)
% Y, dependent variable (such as concentrations)
% y = kx + b, simple linear regession model
% r2, coefficient of determination (R squared)
function [k,b,r2] = regression(X,Y)
    n = length(X); 
    xy_mean = dot(X,Y)/n;
    x_mean = mean(X);
    y_mean = mean(Y);

    k = (xy_mean - x_mean*y_mean)/(mean(X.^2)-x_mean*x_mean);
    b = y_mean - k*x_mean;
    
    r2 = k*(xy_mean - x_mean*y_mean)/(mean(Y.^2)-y_mean*y_mean);
       
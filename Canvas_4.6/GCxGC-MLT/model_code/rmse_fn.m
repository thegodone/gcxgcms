function rmse = rmse_fn(X,x,m)
model = X(X(:,x)==X(:,x),m);
expt = X(X(:,x)==X(:,x),x);
rmse = sqrt(mean((model-expt).^2));


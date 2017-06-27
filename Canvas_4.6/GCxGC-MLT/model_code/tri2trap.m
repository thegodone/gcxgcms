function [cellmapPtrap, cellmapCtrap] = tri2trap(cellmapPtri, cellmapCtri)

trapweight = 2;   % for trapezoids with base = 3*height

V = mod(cellmapPtri,1);
V1 = trapweight*(V - 0.5);
V1(V1>1)=1;
V1(V1<0)=0;
cellmapPtrap = floor(cellmapPtri) + V1;

W = mod(cellmapCtri,1);
W1 = trapweight*(W - 0.5);
W1(W1>1)=1;
W1(W1<0)=0;
cellmapCtrap = floor(cellmapCtri) + W1;


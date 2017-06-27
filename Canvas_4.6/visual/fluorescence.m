function map = fluorescence

c1 = [linspace(16,54,128),linspace(54,230,64),linspace(230,255,64)]/255;
c2 = [linspace(16,168,128),linspace(168,252,128)]/255;
c3 = [linspace(16,65,128),linspace(65,20,64),linspace(20,255,64)]/255;

map = [c1',c2',c3'];
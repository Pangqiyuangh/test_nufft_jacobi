function M = JTM1d(rs,cs,n,da,db,ts,nu,wghts)
rs = rs*1.000;
cs = cs*1.000;
nt = zeros(n,1);
M = extrjac1(nt,rs,cs,1,da,db,ts,nu,wghts);
end
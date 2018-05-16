nts=2^15-26;
jacobi1=zeros(nts,nts);
jacobi2=zeros(nts,nts);
jocabi1=textread('jacobi1.txt');
jocabi2=textread('jacobi2.txt');
size(jacobi1)
size(jacobi2)
tol=1e-12;
tR=500;
mR=500;
[U1,V1]=lowrank(jacobi1,tol,tR,mR);
[U2,V2]=lowrank(jacobi2,tol,tR,mR);
rank1=size(U1,2)
rank2=size(U2,2)

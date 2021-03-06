function [fun,rank,ts,wghts] = invJPT1D(nts,da,db,tR,mR,tol,opt,R_or_N)
%  Return:fun(c)(a function handle computing 1D inverse uniform Jacobi
%  polynomial transform) such that
%    J*fun(c) = c, 
%    where W = diag(wghts);
%      if R_or_N > 0, J(j,k) = M^(da,db)_(ts(j),k-1)*exp(1i*(psi^(da,db)_(t(j),k-1)-2*pi/nts*[ts(j)*nts/2/pi]*(k-1))), 1=<j,k<=nts;               
%      if R_or_N > 0, J(j,k) = M^(da,db)_(ts(j),k-1)*exp(1i*(psi^(da,db)_(t(j),k-1)-t(j)*(k-1))), 1=<j,k<=nts;
%
%  ts    - specific samples for users
%  mR    - maximum rank    
%  tR    - p*mR, where p>5 sould be a oversampling parameter
%  tol   - accuracy
%  opt   - an option decides which lowrank approximation to use
%          opt >= 1, use Randomized sampling SVD
%          0 <= opt < 1, use lowrank approximation based on applying chebyshev grids interpolation for sample dimension                    
%          opt <= 0, use lowrank approximation based on applying chebyshev grids interpolation for both sample and degree dimensions
%         
%  Copyright reserved by Qiyuan Pang, 22/11/2018 


    if nts < 2^12
       it = 10;
    else
       it = 28;
    end
nt = zeros(nts,1);
[ts,wghts] = getts(nt,da,db);
nu = [it:nts-1]';
xs = mod(floor(ts*nts/2/pi),nts)+1;
cs = zeros(nts,1);
Y = [1:nts]';
X = zeros(nts,1);
S = ones(nts,1);
for i = 1:nts
    X(i) = xs(i);   
end
P = sparse(X,Y,S,nts,nts,nts);
if  opt >= 1
    JTM = @(ts,nu)interpjac1(nt,ts,nu,da,db,R_or_N);
    %JTM = @(rs,cs,n,da,db,ts,nu,wghts)JTM1d(rs,cs,n,da,db,ts,nu,wghts,R_or_N);
    [U,V] = lowrank(nts,JTM,ts,nu,tol,tR,mR);
    U = repmat(sqrt(wghts),1,size(U,2)).*U;
    V = conj(V);
elseif 0 <= opt && opt<1
    %JTM = @(rs,cs,ts,nu)JTM1d(rs,cs,nts,da,db,ts,nu,wghts);
    %grid = cos(((2*[nts:-1:1]'-1)*pi/2/nts)+1)*pi/2;
    [U,V] = ID_Cheby(nts,ts,nu,da,db,tol,1,R_or_N,tR,mR);
    U = repmat(sqrt(wghts),1,size(U,2)).*U;
    %U = diag(sqrt(wghts))*U;
elseif opt < 0
    [U,V] = ID_Cheby(nts,ts,nu,da,db,tol,-1,R_or_N,tR,mR);
    U = repmat(sqrt(wghts),1,size(U,2)).*U;
    %U = diag(sqrt(wghts))*U;
end
rank = size(U,2);
V = [zeros(it,rank);V];

vals = jacrecur(nts,ts,it-1,da,db);

if  R_or_N > 0
    fun = @(c)invJacPT1d1(c);
else
    %%%% to be updated
    fun = @(c)invJacPT1d2(2);
end

    function y = invJacPT1d1(c)
        ncol = size(c,2);
        c = c.*repmat(sqrt(wghts),1,ncol);
        d = repmat(U,1,ncol).*reshape(repmat(c,rank,1),nts,rank*ncol);
	%d = repmat(sqrt(wghts),1,ncol*rank).*d;
        d = P*d;
        fftc = conj(fft(conj(d)));
        y = squeeze(sum(reshape(repmat(V,1,ncol).*fftc,nts,rank,ncol),2));
        y = real(y);
        y(1:it,:) = y(1:it,:) + vals.'*(c.*sqrt(wghts));
    end
    
    function y = invJacPT1d2(c)
        %%%to be updated
    end
end

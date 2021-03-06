function [fun,rank] = NJPT1D(nts,ts,da,db,tR,mR,tol,opt,R_or_N)
%  Return:(a function handle computing 1D nonuniform Jacobi polynomial transform)
%    fun(c) = J*c, 
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
nu = [it:nts-1]';
xs = mod(floor(ts*nts/2/pi),nts)+1;
wghts = ones(nts,1);
nt = zeros(nts,1);

if  opt > 0
    JTM = @(ts,nu)interpjac1(nt,ts,nu,da,db,R_or_N);
    [U,V] = lowrank(nts,JTM,ts,nu,tol,tR,mR);
     V = conj(V);
elseif 0 <= opt && opt<1
    [U,V] = ID_Cheby(nts,ts,nu,da,db,tol,1,R_or_N,tR,mR);
elseif opt < 0
    [U,V] = ID_Cheby(nts,ts,nu,da,db,tol,-1,R_or_N,tR,mR);
end
rank = size(U,2);
V = [zeros(it,rank);V];

vals = jacrecur(nts,ts,it-1,da,db);

if  R_or_N > 0
    fun = @(c)NJacPT1d1(c);
else
    ex = exp(1i*nts/2*ts);
    U = U.*repmat(ex,1,rank);
    fun = @(c)NJacPT1d2(c);
end

    function y = NJacPT1d1(c)
        ncol = size(c,2);
        d = repmat(V,1,ncol).*reshape(repmat(c,rank,1),nts,rank*ncol);
        fftc = ifft(d);
        fftc = fftc(xs,:);
        y = nts*squeeze(sum(reshape(repmat(U,1,ncol).*fftc,nts,rank,ncol),2));
        y = real(y);
        y = y + vals*c(1:it,:);
    end
    
    function y = NJacPT1d2(c)
        y = zeros(nts,1);
        for i=1:rank
            cj = nufft1dIInyumex(ts,1,tol,V(:,i).*c);
            y = y + U(:,i).*cj;
        end
	    y = real(y);
        y = y + vals*c(1:it,:);
    end
end

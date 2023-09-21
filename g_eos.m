function [Z_vap,Z_liq]=g_eos(Tr,Pr,w,method)
%Calculates the the liquid and vapor roots of the generalized EOS in the form:
% Z=beta+(Z+eta*beta)(Z+sigma*beta)*((1+beta-Z)/(q*beta))
% Usage: [Z_vap,Z_liq]=g_eos(Tr,Pr,w,method) where Z_vap and Z_liq are the roots of the
% compressibility factor returned, Tr, Pr and w are the reduced 
%temperature, pressure and accentric factor of the fluid respectively.
%Method is a string with values %vdw’ (van der Waals [Default]), or ‘rk’
%(Redlich Kwong), or ‘srk’ (Soave RK), or ‘pr’ (Peng Robinson) Default
%value for method is 'vdw'

%Written by J. Rockman 20 Mar 2021

if nargin<3
    error('Too few inputs, need to enter Tr, Pr and w at least!')
elseif nargin<4
    method='vdw';
end

if strcmp(method,'vdw')
    alpha=1;
    sigma=0;eps=0;Omega=1/8;Psi=27/64;
elseif strcmp(method,'rk')
    alpha=Tr.^(-0.5);
    sigma=1;eps=0;Omega=0.086640349964958;Psi=0.427480233540342;
elseif strcmp(method,'srk')
    alpha=(1+(0.48 + 1.574*w - 0.176*w.^2)*(1-sqrt(Tr))).^2;
    sigma=1;eps=0;Omega=0.086640349964958;Psi=0.427480233540342;
elseif strcmp(method,'pr')
    alpha=(1+(0.37464 + 1.54226*w - 0.26993*w.^2)*(1-sqrt(Tr))).^2;
    sigma=1+sqrt(2);eps=1-sqrt(2);
    Omega=0.077796073903888;
    Psi=0.457235528921382;
    % Need double precision to obtain correct Zc answer of 0.3074
else 
    error('Wrong name for method, use either "vdw", "rk", "srk" or "pr" in lowercase!')
end

beta=Omega*Pr/Tr;
q=Psi*alpha/Omega/Tr;


a=(eps+sigma)*beta-(1+beta);
b=beta*(q+eps*sigma*beta-(eps+sigma)*(1+beta));
c=-((1+beta)*sigma*eps+q)*beta^2;
Z=sort(roots([1 a b c]));
if ~isreal(Z(1))
    Z_liq=Z(3);
    Z_vap=Z_liq;
    'There is only one real root, Z=Zv';
elseif ~isreal(Z(3))
    Z_liq=Z(1);
    Z_vap=Z_liq;
    'There is only one real root, Z=Zl';
else
    Z_vap=Z(3);
    Z_liq=Z(1);
end
% Checked by Matlab's symbolic toolbox (expand and simplify):
% z^3 + (beta*eps - beta + beta*sigma - 1)*z^2 + (beta*q - (beta*eps + beta*sigma)*(beta + 1) + beta^2*eps*sigma)*z - beta^2*q - beta^2*eps*sigma*(beta + 1)

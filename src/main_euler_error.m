warning('off','all')
clc
clear all 
close all

%----------------------------------------------------------%
%-- PRG MAIN_EULER_ERROR --%
%
% Compute the convergence rate of the method
%
%	Author : 
% 	- Timothée Schmoderer
%
%   
%		INSA de Rouen Normandie 2017	
% 		Universität zu Köln 2017
%		
%----------------------------------------------------------% 

% Initialsation
N = [100 200 300 400 600 800 1200 1600 2400 3200 4000 6400 9600 12800];
Nb = 5;
a = 0;
b = 1;

niter = 100;
error = 'error_1';
nodes = 'nuniform';
tmp = zeros(1,length(N));

i = 1;
for n=N
	tic;
	data = initial(n,Nb,a,b,error,nodes);
	dx = data.dx;
	theta = data.theta;
	gamma = data.gamma;
	U = data.U;
	cfl = data.cfl;
	x = data.x;
	bound = data.bound;

	% U at the next time step
	U1 = zeros(size(U));
	% Reserve memory space for the RK method
	U1_1 = zeros(size(U));
	U1_2 = zeros(size(U));

	t = 0;
	dt = min(dx)/275;

	while t/dt < niter
		% SSP RK order 3
		q = qf(U,gamma,theta,dx,cfl) - source(U,gamma,error);
		U1_1(:,3:end-2) = U(:,3:end-2) - dt*q;
		U1_1 = boundary(U1_1,bound);

		q1 = qf(U1_1,gamma,theta,dx,cfl) - source(U,gamma,error);
		U1_2(:,3:end-2) = 0.75*U(:,3:end-2) + 0.25*U1_1(:,3:end-2) - 0.25*dt*q1;
		U1_2 = boundary(U1_2,bound);

		q2 = qf(U1_2,gamma,theta,dx,cfl) - source(U,gamma,error);
		U1(:,3:end-2) = (1/3)*U(:,3:end-2) + (2/3)*U1_2(:,3:end-2) - (2/3)*dt*q2;
		U1 = boundary(U1,bound);

		% Loop
		U = U1;
		t = t + dt;
	end
	eval('time(i) = toc;');
	rho = U(1,3:end-2);
	genvarname(['rho',num2str(n)]);
	genvarname(['rhoEx',num2str(n)]);
	genvarname(['e',num2str(n)]);
	eval(['rho' num2str(n) '= rho;']);
	eval(['rhoEx' num2str(n) '= rhoEx(x,t,error);']);
	eval(['e1_', num2str(n), '= norm(rho',num2str(n),' - rhoEx',num2str(n),',1);']);
	eval(['taberr1(i) = e1_' num2str(n) ';']);
	eval(['e2_', num2str(n), '= norm(rho',num2str(n),' - rhoEx',num2str(n),',2);']);
	eval(['taberr2(i) = e2_' num2str(n) ';']);
	eval(['eInf_', num2str(n), '= norm(rho',num2str(n),' - rhoEx',num2str(n),',inf);']);
	eval(['taberrInf(i) = eInf_' num2str(n) ';']);
	i = i+1;
end

f1 = figure;
plot(log(N),log(taberr1),'*');
p=polyfit(log(N),log(taberr1),1);
x = linspace(4,11,1000);
y = polyval(p,x);
hold on 
plot(x,y,'r');
plot(x,-2*x,'g');
hold off
legend('Error',['log(err) = ',num2str(p(1)),' * log(N) + ',num2str(p(2))],'Theoric : log(err) = -2*log(N)');
title(['Error analysis of case 1 for the L1 norm on a non uniform mesh with ',num2str(Nb),' block']);

f2 = figure;
plot(log(N),log(taberr2),'*');
p=polyfit(log(N),log(taberr2),1);
x = linspace(4,11,1000);
y = polyval(p,x);
hold on 
plot(x,y,'r');
plot(x,-2*x,'g');
hold off
legend('Error',['log(err) = ',num2str(p(1)),' * log(N) + ',num2str(p(2))],'Theoric : log(err) = -2*log(N)');
title(['Error analysis of case 1 for the L2 norm on a non uniform mesh with ',num2str(Nb),' block']);

fInf = figure;
plot(log(N),log(taberrInf),'*');
p=polyfit(log(N),log(taberrInf),1);
x = linspace(4,11,1000);
y = polyval(p,x);
hold on 
plot(x,y,'r');
plot(x,-2*x,'g');
hold off
legend('Error',['log(err) = ',num2str(p(1)),' * log(N) + ',num2str(p(2))],'Theoric : log(err) = -2*log(N)');
title(['Error analysis of case 1 for the LInf norm on a non uniform mesh with ',num2str(Nb),' block']);

fT = figure;
plot(N,time,'o');
xlabel('# of nodes');
ylabel('Time in s.');
title(['Execution time for ',num2str(niter),' iterations on a non uniform mesh with ',num2str(Nb),' block']);
%zakres_szumu - podaj wartosci wieksza od 0. Np dla zakres_szumu = 2,
%zostanie wygenerowany szum o wartosciach 0 <= szum <= 2
function error =  zad7(DZ,D,N,Nu,lambda,Upp,Ypp,zakres_szumu)

error = 0;
load('s_u.mat');
load('s_z.mat');
czas_sym=300;
start_sym=9;
                            %DMC
%----------------------------------------------------------------
M=zeros(N,Nu);
for i=1:N
   for j=1:Nu
      if (i>=j)
         M(i,j)=s_u(i-j+1);
      end;
   end;
end;

MP=zeros(N,D-1);
for i=1:N
   for j=1:D-1
      if i+j<=D
         MP(i,j)=s_u(i+j)-s_u(j);
      else
         MP(i,j)=s_u(D)-s_u(j);
      end;      
   end;
end;

MZP=zeros(N,DZ-1);
for i=1:N
   for j=1:DZ-1
      if i+j<=DZ
         MZP(i,j)=s_z(i+j)-s_z(j);
      else
         MZP(i,j)=s_z(DZ)-s_z(j);
      end;      
   end;
end;

% Obliczanie parametrów regulatora

I=eye(Nu);
K=((M'*M+lambda*I)^-1)*M';
ku=K(1,:)*MP;
kz=K(1,:)*MZP;
ke=sum(K(1,:));

dY = 0.5
u(1:czas_sym)=Upp;
y(1:czas_sym)=Ypp;
z(1:czas_sym)=0;
e=zeros(1,czas_sym);
yzad(1:start_sym)=Ypp; 
yzad(start_sym:czas_sym)=Ypp + dY;
start_zak=100;

deltaup=zeros(1,D-1);
deltazp=zeros(1,DZ-1);
t = 0:0.05:5*pi;
szum = rand(czas_sym - start_zak + 1,1)*zakres_szumu;
szum = szum - zakres_szumu/2;
for k=start_sym:czas_sym
   %symulacja obiektu
   
   if k>=start_zak
       z(k)= 1 + szum(k-start_zak + 1);
   end
   y(k)=  symulacja_obiektu11y(u(k-7),u(k-8),z(k-3),z(k-4),y(k-1),y(k-2));
   error = error + (yzad(k) - y(k))^2;
   %uchyb regulacji
   e(k)=yzad(k) - y(k);
   
   for n=DZ-1:-1:2;
       deltazp(n)=deltazp(n-1);
   end
   deltazp(1)=z(k)-z(k-1);
   
   % Prawo regulacji
   deltauk=ke*e(k)-ku*deltaup';
   deltauk=deltauk-kz*deltazp';
   
   for n=D-1:-1:2
      deltaup(n)=deltaup(n-1);
   end
   deltaup(1)=deltauk;
   u(k)=u(k-1)+deltaup(1);
   
end

subplot(211)
plot(u);
title({'DMC ';['Blad regulacji = ', num2str(error),' , DZ = ', num2str(DZ),', D = ', num2str(D), ', N = ', num2str(N),', Nu = ',num2str(Nu), ', lambda = ',num2str(lambda)];})
xlabel('Iteracje k')
ylabel('Sterowanie - U(k)')
legend('U(k)','location','best');
hold on;
subplot(212)
plot(y);
hold on;
stairs(yzad,'--')
xlabel('Iteracje k')
ylabel('Wyjscie - y(k)')
legend('Y(k)','Y_z_a_d(k)','location','best');
hold on;

figure;
plot(z);
title('Skok zaklocenia');
ylabel('Z(K) - wartosc zaklocenia');
xlabel('Iteracje k');
end
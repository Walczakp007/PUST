function [ error ] = dmcE(argN, argNu, argLambda, draw)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
load('s.mat');
D = 150;
N = argN;
Nu = argNu;
lambda = argLambda;
error = 0;
Ypp = 3;
Upp = 0.9;
Umin = 0.6;
Umax = 1.2;
dUmax = 0.1;

Yzad = zeros(N,1);
Y0 = zeros(N,1);
Yk = zeros(N,1);

U(1:11) = Upp;
Y(1:11) = Ypp;

dU = zeros(Nu,1);
dUp = zeros(D-1,1);

M = zeros(N,Nu);
Mp = zeros(N,D-1);

for i = 1:N
    for j = 1:i
        if j == Nu + 1
            break
        end
        M(i,j) = s(i-j+1);
    end
end

for i = 1:N
    for j = 1:D-1
        Mp(i,j) = s(i+j)-s(j);
    end
end

K = (M'*M + lambda * eye(Nu))\M';

yzad(1:200) = 3.1;
yzad(201:400) = 3.2;
yzad(401:600) = 3.3;
yzad(601:800) = 3.35;
yzad(801:1000) = 3.4;

for k = 12:1000
    Yk(1:end) = Y(k-1);
    Yzad(1:end) = yzad(k);
    Y0 = Yk + Mp*dUp;
    dU = K*(Yzad - Y0);
    if dU(1) > dUmax
        dU(1) = dUmax;
    end
    
    dUp(2:end) = dUp(1:end-1);
    dUp(1) = dU(1);
    
    ukk = U(k-1) + dU(1);
    if ukk < Umin
        ukk = Umin;
    elseif ukk > Umax
        ukk = Umax;
    end
    U(k) = ukk;
    Y(k) = symulacja_obiektu2Y(U(k-10),U(k-11),Y(k-1),Y(k-2));
    error = error + (yzad(k) - Y(k))^2;
end
if draw == true
    stairs(Y)
    hold on
    mTextBox = uicontrol('style','text')
    set(mTextBox,'String','N = 60, Nu = 40, Lambda = 1. Err = 0.6203')
    set(mTextBox,'Position',[140; 200; 220; 20])
    stairs(U)
    stairs(yzad)
    xlabel('k')
    ylabel('value')
    legend('Y(k)','U(k)','Yzad(k)','location','best');
end
end


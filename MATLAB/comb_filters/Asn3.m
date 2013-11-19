% Mike Dean
% Elec 484 Summer 2011
% Assignment 3 - Part 2
% Design of a universal comb filter

clear all;
close all;


% xh = x(n)+FBxh(n-M)
% y(n) = BLxh(n) + FFxh(n-M)
% Y(z) = BLXh(z) + FF(z^-4)Xh(z)
% Xh = X(z) + FB(z^-4)Xh(z)
% X(z) = Xh(z) - FB(z^-4)Xh(z)
% H(z) = [BLXh(z) + FF(z^-4)Xh(z)]/[Xh(z) - FB(z^-4)Xh(z)]

% A(z)=FF(z^-4) + BL / 1 - FBz^-4

% FIR Comb Filter
BL=0.6;
FB=0;
FF=0.5;
uniCombFilter(FB, FF, BL);

% IIR Comb Filter
BL=1;
FB=0.3;
FF=0;
uniCombFilter(FB, FF, BL);

% allpass
BL=0.6;
FB=-BL;
FF=1;
uniCombFilter(FB, FF, BL);

% delay
BL=0;
FB=0;
FF=1;
uniCombFilter(FB, FF, BL);

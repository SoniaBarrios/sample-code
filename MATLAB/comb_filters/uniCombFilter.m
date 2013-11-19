function [ir] = uniCombFilter(FB, FF, BL)

if (FB == 0 && BL ==0)
    var = 'Delay';
elseif (FB==0 && BL ~= 0)
    var='FIR Comb Filter';
elseif (FF==0 && BL ==1)
    var='IIR Comb Filter';
elseif (BL==-FB)
    var='All-Pass Filter';
end

varTitle='Impulse Response of ';
cmbTitle=[varTitle, var];

imp = [1; zeros(49,1)];
b = [BL 0 0 0 FF];
a = [1 0 0 0 -FB];
ir = filter(b,a,imp);
figure()
stem(ir);
ylabel('Magnitude');
xlabel('Samples');
title(cmbTitle);
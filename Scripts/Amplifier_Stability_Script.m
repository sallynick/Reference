clear all
close all
clc

%used for string input
S11 = "S11";
S12 = "S12";
S21 = "S21";
S22 = "S22";

%collect user data0.0.
[S11_mag, S11_phase, fail_flag1] = S_Param_Input(S11);
if(fail_flag1 ==1)
    disp("Program failed. All S parameter data is necessary");
    return
end
[S12_mag, S12_phase, fail_flag2] = S_Param_Input(S12);
if(fail_flag2 ==1)
    disp("Program failed. All S parameter data is necessary");
    return
end
[S21_mag, S21_phase, fail_flag3] = S_Param_Input(S21);
if(fail_flag3 ==1)
    disp("Program failed. All S parameter data is necessary");
    return
end
[S22_mag, S22_phase, fail_flag4] = S_Param_Input(S22);
if(fail_flag1 ==4)
    disp("Program failed. All S parameter data is necessary");
    return
end

%convert polar to rectangular complex numbers
[S11_rect, S12_rect, S21_rect, S22_rect] = pol2rect(S11_mag, S11_phase, S12_mag, S12_phase, S21_mag, S21_phase, S22_mag, S22_phase);

%check for unconditional stability
[mag_delta, K, unstable_flag] = Uncond_Stab_check(S11_rect, S12_rect, S21_rect, S22_rect);



if(unstable_flag == 1)
    %disp("Possibly unstable. Stability Circles Calculated")
    [Center_L, Radius_L, Center_S, Radius_S] = stab_circ(S11_rect, S12_rect, S21_rect, S22_rect);

    mag = abs(Center_L);
    ang = rad2deg(angle(Center_L));
    fprintf("\n\nPossibly unstable. Stability Circles Calculated\nCenter for Load Circle = %6f<%6f\n", mag, ang);
    
    mag = abs(Radius_L);
    fprintf("Radius for Load Circle = %6f\n", mag);

    mag = abs(Center_S);
    ang = rad2deg(angle(Center_S));
    fprintf("Center for Source Circle = %6f<%6f\n", mag, ang);

    mag = abs(Radius_S);
    ang = rad2deg(angle(Radius_S));
    fprintf("Radius for Source Circle = %6f\n", mag);
end

function [Center_L, Radius_L, Center_S, Radius_S] = stab_circ(S11_rect, S12_rect, S21_rect, S22_rect)

delta = S11_rect*S22_rect - S12_rect*S21_rect;

denom_L = abs(S22_rect).^2 - abs(delta).^2;
Center_L = conj(S22_rect - delta*conj(S11_rect))/(denom_L);
Radius_L = abs(S12_rect*S21_rect)/(denom_L);

denom_S = abs(S11_rect).^2 - abs(delta).^2;
Center_S = conj(S11_rect - delta*conj(S22_rect))/(denom_S);
Radius_S = abs(S12_rect*S21_rect)/(denom_S);

end

function [S11_rect, S12_rect, S21_rect, S22_rect] = pol2rect(S11_mag, S11_phase, S12_mag, S12_phase, S21_mag, S21_phase, S22_mag, S22_phase)
S_mags = [S11_mag; S12_mag; S21_mag; S22_mag];
S_phase = [S11_phase; S12_phase; S21_phase; S22_phase];
[S_x, S_y] = pol2cart(deg2rad(S_phase), S_mags);
S_rect = complex(S_x, S_y);
S11_rect = S_rect(1);
S12_rect = S_rect(2);
S21_rect = S_rect(3);
S22_rect = S_rect(4);

end

function [mag_delta, K, unstable_flag] = Uncond_Stab_check(S11_rect, S12_rect, S21_rect, S22_rect)
mag_delta = abs(S11_rect*S22_rect - S12_rect*S21_rect);
K = (1 - abs(S11_rect).^2 - abs(S22_rect).^2 + mag_delta.^2)/(2*abs(S21_rect*S12_rect));

if((mag_delta < 1) && (K > 1))
    disp("Amplifier is unconditionally stable");
    fprintf("magnitude of delta = %4f < 1 \n and K = %4f > 1\n", mag_delta, K);
    unstable_flag = 0;
elseif(mag_delta >= 1)
    fprintf("magnitude of delta = %4f > 1; Possibly unstable\n", mag_delta);
    unstable_flag = 1;
elseif(K <= 1)
    fprintf("K = %4f < 1. Possibly unstable\n", K);
    unstable_flag = 1;
end

end

function [S_Mag, S_Phase, fail_flag] = S_Param_Input(S_param)

text1 = "Enter Magnitude of ";
text2 = ": ";
prompt = strcat(text1, S_param, text2);
S_Mag = input(prompt);

text1 = "Enter Phase of ";
text2 = " in Degrees: ";
prompt = strcat(text1, S_param, text2);
S_Phase = input(prompt);

if(isempty(S_Mag) || isempty(S_Phase))
    disp("Program failed. All S parameter data is necessary");
    fail_flag = 1;
else
    fail_flag = 0;
end
end
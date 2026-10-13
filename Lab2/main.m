P_BS = 46;
P_UE = 24;
sectors_count = 3;

G_BS = 21;
Penetration_loss = 15;
Interfirence_margin = 1;

freq_range = 1.8;  % ГГц
BW_UL = 10e6;
BW_DL = 20e6;

noice_figure_BS = 2.4;
noice_figure_UE = 6;

req_SNIR_DL = 2;
req_SNIR_UL = 4;

mimo_cout = 2;
mimo_gain = 10 * log10(mimo_cout);

Area_S = 100;
Buisnes_Area_S = 4;

Thermal_Noise_UE = -174 + 10 * log10(BW_DL);
Thermal_Noise_BS = -174 + 10 * log10(BW_UL);

RX_sens_BS = Thermal_Noise_BS + noice_figure_BS + req_SNIR_UL;
RX_sens_UE = Thermal_Noise_UE + noice_figure_UE + req_SNIR_DL;

Feeder_loss = 2.9;

% Расчет бюджетов каналов MAPL
MAPL_DL = P_BS - Feeder_loss + G_BS + mimo_gain - Interfirence_margin - Penetration_loss - RX_sens_UE;
MAPL_UL = P_UE - Feeder_loss + G_BS + mimo_gain - Interfirence_margin - Penetration_loss - RX_sens_BS;

fprintf("Thermal_Noise_BS = %f \t Thermal_Noise_UE = %f\n", Thermal_Noise_BS, Thermal_Noise_UE);
fprintf("RX_sens_BS = %f \t RX_sens_UE = %f\n", RX_sens_BS, RX_sens_UE);
fprintf("MAPL_DL = %f \t MAPL_UL = %f\n", MAPL_DL, MAPL_UL);

%% Модели потерь радиосигнала
distance = linspace(1, 10000, 10000);
figure('Name', 'Сравнение моделей');
% FSPM
lambda = 3e8 / (freq_range * 1e9);
PL_FSPM = @(d) 20 * log10((4 * pi * d) / lambda);
FSPM = PL_FSPM(distance);
plot(distance, FSPM);
hold on;

% UMiNLOS
PL_UMiNLOS = @(d) 26 * log10(freq_range) + 22.7 + 36.7 * log10(d);
UM = PL_UMiNLOS(distance);
plot(distance, UM);
hold on;

% COST 231 Hata
freq_MHz = 1800;
hBS = 30;
hms = 1.5;
d_km = distance / 1000;

A = 46.3;
B = 33.9;
a_hms = 3.2 * (log10(11.75 * hms))^2 - 4.97;

s_ge1 = 44.9 - 6.55 * log10(freq_MHz);
s_lt1 = (47.88 + 13.9 * log10(freq_MHz) - 13.9 * log10(hBS)) / log10(50);
s = zeros(size(d_km));
s(d_km >= 1) = s_ge1;
s(d_km < 1)  = s_lt1;

L_clutter = 0;

PL_Hata = A + B * log10(freq_MHz) - 13.82 * log10(hBS) - a_hms + s .* log10(d_km) + L_clutter;
plot(distance, PL_Hata);
hold on;

% 4. Walfish-Ikegami
h = 15; % Высота зданий
w = 20; % Ширина улиц
b = 40; % Расстояние между зданиями
varphi = 60; % Угол между направлением распространения сигнала и улицей

L0 = 32.44 + 20 * log10(freq_MHz) + 20 * log10(d_km);

L2 = -16.9 - 10 * log10(w) + 10 * log10(freq_MHz) + 20 * log10(h - hms);
if varphi >= 0 && varphi < 35
    L2 = L2 - 10 + 0.354 * varphi;
elseif varphi >= 35 && varphi < 55
    L2 = L2 + 2.5 + 0.075 * varphi;
elseif varphi >= 55 && varphi <= 90
    L2 = L2 + 4.0 - 0.114 * varphi;
end

if hBS > h
    ka = 54;
    kd = 18;
    L11 = -18 * log10(1 + hBS - h);
else
    L11 = 0;
    ka = zeros(size(d_km));
    ka(d_km > 0.5)  = 54 - 0.8 * (hBS - h);
    ka(d_km <= 0.5) = 54 - 0.8 * (hBS - h) * (d_km(d_km <= 0.5) / 0.5);
    kd = 18 - 15 * (hBS - h) / h;
end

kf = -4 + 0.7 * (freq_MHz / 925 - 1);
L1 = L11 + ka + kd .* log10(d_km) + kf * log10(freq_MHz) - 9 * log10(b);

PL_Walfish = L0 + L1 + L2;
PL_Walfish(L1 + L2 <= 0) = L0(L1 + L2 <= 0);
plot(distance, PL_Walfish);
hold on;

% Построение линий MAPL и настройка графика

yline(MAPL_UL, '--r', 'LineWidth', 1.5, 'DisplayName', 'MAPL UL');
yline(MAPL_DL, '--g', 'LineWidth', 1.5, 'DisplayName', 'MAPL DL');
xlabel('d, м');
ylabel('PL, дБ');
title('Модели потерь сигнала и уровни MAPL');
legend('FSPM', 'UMiNLOS', 'Hata', 'Walfish-Ikegami', 'MAPL UL', 'MAPL DL', 'Location','southeast');
grid on;

%% Определение радиусов и расчет покрытия

% Радиус сот
R_UMiNLOS = 0.45;
R_Hata = 0.6;

fprintf("Радиус по модели UMiNLOS = %.2f км\n", R_UMiNLOS);
fprintf("Радиус по модели COST 231 Hata = %.2f км\n", R_Hata);

% Площадь
S_UMiNLOS = 1.95 * R_UMiNLOS^2;
S_Hata = 1.95 * R_Hata^2;

fprintf("Площадь сайта по модели UMiNLOS = %.4f кв. км\n", S_UMiNLOS);
fprintf("Площадь сайта по модели COST 231 Hata = %.4f кв. км\n", S_Hata);

% Количество сайтов
N_sites_UMiNLOS = ceil(Buisnes_Area_S / S_UMiNLOS);
N_sites_Hata = ceil(Area_S / S_Hata);

fprintf("Количество сайтов по модели UMiNLOS = %d\n", N_sites_UMiNLOS);
fprintf("Количество сайтов по модели COST 231 Hata = %d\n", N_sites_Hata);

%% Дополнительное задание

BW_range_Hz = logspace(5, 8, 200);
BW_range_MHz = BW_range_Hz / 1e6;

% Тепловой шум и чувствительность приемников
Thermal_Noise_range = -174 + 10 * log10(BW_range_Hz);
RX_sens_BS_range = Thermal_Noise_range + noice_figure_BS + req_SNIR_UL;
RX_sens_UE_range = Thermal_Noise_range + noice_figure_UE + req_SNIR_DL;

% Расчет MAPL для DL и UL
MAPL_DL_BW = P_BS - Feeder_loss + G_BS + mimo_gain - Interfirence_margin - Penetration_loss - RX_sens_UE_range;
MAPL_UL_BW = P_UE - Feeder_loss + G_BS + mimo_gain - Interfirence_margin - Penetration_loss - RX_sens_BS_range;

% Расчет радиуса COST 231 Hata
PL_1km = A + B * log10(freq_MHz) - 13.82 * log10(hBS) - a_hms;

% DL Cell Range (Hata)
R_DL_Hata = zeros(size(MAPL_DL_BW));
idx_lt1_DL = MAPL_DL_BW <= PL_1km;
R_DL_Hata(idx_lt1_DL)  = 10.^((MAPL_DL_BW(idx_lt1_DL) - PL_1km) / s_lt1);
R_DL_Hata(~idx_lt1_DL) = 10.^((MAPL_DL_BW(~idx_lt1_DL) - PL_1km) / s_ge1);

% UL Cell Range (Hata)
R_UL_Hata = zeros(size(MAPL_UL_BW));
idx_lt1_UL = MAPL_UL_BW <= PL_1km;
R_UL_Hata(idx_lt1_UL)  = 10.^((MAPL_UL_BW(idx_lt1_UL) - PL_1km) / s_lt1);
R_UL_Hata(~idx_lt1_UL) = 10.^((MAPL_UL_BW(~idx_lt1_UL) - PL_1km) / s_ge1);

% Расчет радиуса UMiNLOS
const_umi = 26 * log10(freq_range) + 22.7;
R_DL_umi = (10.^((MAPL_DL_BW - const_umi) / 36.7)) / 1000;
R_UL_umi = (10.^((MAPL_UL_BW - const_umi) / 36.7)) / 1000;

% Расчет радиуса FSPM
lambda = 3e8 / (freq_range * 1e9);
R_DL_FSPM = ((lambda / (4 * pi)) * 10.^(MAPL_DL_BW / 20)) / 1000;
R_UL_FSPM = ((lambda / (4 * pi)) * 10.^(MAPL_UL_BW / 20)) / 1000;

% Построение графика зависимости Cell Range от BW
figure('Name', 'Зависимость Cell Range от ширины полосы');
plot(BW_range_MHz, R_DL_Hata, 'g', 'LineWidth', 1.8, 'DisplayName', 'DL (COST 231 Hata)');
hold on;
plot(BW_range_MHz, R_UL_Hata, 'r', 'LineWidth', 1.8, 'DisplayName', 'UL (COST 231 Hata)');
plot(BW_range_MHz, R_DL_umi, '--g', 'LineWidth', 1.4, 'DisplayName', 'DL (UMiNLOS)');
plot(BW_range_MHz, R_UL_umi, '--r', 'LineWidth', 1.4, 'DisplayName', 'UL (UMiNLOS)');
plot(BW_range_MHz, R_DL_FSPM, ':g', 'LineWidth', 1.5, 'DisplayName', 'DL (FSPM)');
plot(BW_range_MHz, R_UL_FSPM, ':r', 'LineWidth', 1.5, 'DisplayName', 'UL (FSPM)');
set(gca, 'XScale', 'log', 'YScale', 'log');
xlabel('BW, МГц');
ylabel('R, км');
title('Зависимость Cell Range в UL и DL от ширины полосы');
legend('Location', 'northeast');
grid on;

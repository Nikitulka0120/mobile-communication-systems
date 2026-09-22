%% Параметры варианта
f = 18;
f_max = 5 * f;
Fd_min = 2 * f_max;

step = 0.0002;
t_cont = 0 : step : 1 - step;
y_cont = my_signal(t_cont, f);

figure('Name', 'Непрерывный сигнал');
plot(t_cont, y_cont, 'Color', [0.0, 0.45, 0.74], 'LineWidth', 1.5);
xlabel('t, c'); ylabel('A');
title('Непрерывный сигнал y(t)');
grid on;

%% Оцифровка 180 Гц
t_180 = 0 : 1/Fd_min : 1 - 1/Fd_min;
y_180 = my_signal(t_180, f);

figure('Name', 'Восстановление Fd = 180 Гц');
plot(t_cont, y_cont, 'Color', [0.0, 0.45, 0.74, 0.5], 'LineWidth', 2.5); 
hold on;
plot(t_180, y_180, 'Color', [0.85, 0.15, 0.15], 'LineWidth', 1.5, 'Marker', '.', 'MarkerSize', 10); 
hold off;
xlabel('t, c'); ylabel('A');
title('Оригинал и восстановление при Fd = 180 Гц');
legend('Оригинал', 'Восстановленный (Fd = 180 Гц)');
grid on;

% Вычисление спектра ДПФ
F_180 = my_dft(y_180);
amps_180 = abs(F_180);
N1 = length(y_180);
f_axis_180 = (0 : floor(N1/2)) * (Fd_min / N1);

figure('Name', 'Спектр при Fd = 180 Гц');
stem(f_axis_180, amps_180(1 : floor(N1/2) + 1), 'Color', [0.85, 0.15, 0.15], 'LineWidth', 1.5);
xlabel('f, Гц'); ylabel('Амплитуда');
title('Амплитудный спектр (Fd = 180 Гц)');
grid on;

fprintf('--- Гармонический сигнал (Fd = 180 Гц) ---\n');
fprintf('Отсчетов: %d, Память: %d байт\n', length(y_180), length(y_180) * 8);

%% Оцифровка 720 Гц
Fd_720 = Fd_min * 4;
t_720 = 0 : 1/Fd_720 : 1 - 1/Fd_720;
y_720 = my_signal(t_720, f);

figure('Name', 'Восстановление Fd = 720 Гц');
plot(t_cont, y_cont, 'Color', [0.0, 0.45, 0.74, 0.5], 'LineWidth', 2.5); 
hold on;
plot(t_720, y_720, 'Color', [0.10, 0.65, 0.20], 'LineWidth', 1.5, 'Marker', '.', 'MarkerSize', 8); 
hold off;
xlabel('t, c'); ylabel('A');
title('Оригинал и восстановление при Fd = 720 Гц');
legend('Оригинал', 'Восстановленный (Fd = 720 Гц)');
grid on;

F_720 = my_dft(y_720);
amps_720 = abs(F_720);
N2 = length(y_720);
f_axis_720 = (0 : floor(N2/2)) * (Fd_720 / N2);

figure('Name', 'Спектр при Fd = 720 Гц');
stem(f_axis_720, amps_720(1 : floor(N2/2) + 1), 'Color', [0.10, 0.65, 0.20], 'LineWidth', 1.5);
xlabel('f, Гц'); ylabel('Амплитуда');
title('Амплитудный спектр (Fd = 720 Гц)');
grid on;

fprintf('--- Гармонический сигнал (Fd = 720 Гц) ---\n');
fprintf('Отсчетов: %d, Память: %d байт\n', length(y_720), length(y_720) * 8);

%% аудиосигнал
[sound_data, Fs] = audioread('voice.wav');

duration = length(sound_data) / Fs;
Fs_calc = length(sound_data) / duration;
fprintf('\n--- Аудиофайл ---\n');
fprintf('Длительность: %.2f с\nFs (Matlab): %d Гц, Fs (расчетная): %.2f Гц\n', ...
    duration, Fs, Fs_calc);

% Выборка
N_audio = 20000;
sound_cut = sound_data(1 : min(N_audio, length(sound_data)));

% Прореживание
sound_down = downsample(sound_cut, 10);
Fs_down = Fs / 10;

% Воспроизведение
zvuk = audioplayer(downsample(sound_data, 10), Fs_down);
play(zvuk);

% временной график
figure('Name', 'Голосовой сигнал во времени');
t_orig = 0 : 1/Fs : (length(sound_cut) - 1)/Fs;
t_down = 0 : 1/Fs_down : (length(sound_down) - 1)/Fs_down;
plot(t_orig, sound_cut, 'Color', [0.0, 0.45, 0.74, 0.5], 'LineWidth', 1.5); 
hold on;
plot(t_down, sound_down, 'Color', [0.85, 0.15, 0.15], 'LineWidth', 1.2); 
hold off;
xlabel('t, c'); ylabel('Амплитуда');
title('Сравнение формы звукового сигнала во временной области');
legend('Исходный сигнал', 'Прореженный сигнал (1/10)');
grid on;

% спектральный график
F_orig_sound = my_dft(sound_cut);
F_down_sound = my_dft(sound_down);

N_s1 = length(sound_cut);
f_orig = (0 : floor(N_s1/2)) * (Fs / N_s1);
amps_s1 = abs(F_orig_sound(1 : floor(N_s1/2) + 1));

N_s2 = length(sound_down);
f_down = (0 : floor(N_s2/2)) * (Fs_down / N_s2);
amps_s2 = abs(F_down_sound(1 : floor(N_s2/2) + 1));

figure('Name', 'Спектры голоса');
plot(f_orig, amps_s1, 'Color', [0.0, 0.45, 0.74, 0.5], 'LineWidth', 1.5); 
hold on;
plot(f_down, amps_s2, 'Color', [0.85, 0.15, 0.15], 'LineWidth', 1.2); 
hold off;
set(gca, 'XScale', 'log');
xlim([1, Fs / 2]);
xlabel('f, Гц'); ylabel('Амплитуда');
title('Совмещенный амплитудный спектр звука');
legend('Исходный спектр', 'Прореженный спектр (1/10)');
grid on;

%% АЦП
figure('Name', 'Влияние разрядности АЦП');
bits = [3, 4, 5, 6];

for idx = 1 : length(bits)
    b = bits(idx);
    max_val = 2^b - 1;
    
    % Квантование
    scaled_sig = (y_720 - min(y_720)) / (max(y_720) - min(y_720)) * max_val;
    quantized_sig = round(scaled_sig);
    quantized_sig = max(0, min(max_val, quantized_sig));
    
    % Восстановление к физической амплитуде
    rec_sig = min(y_720) + (quantized_sig / max_val) * (max(y_720) - min(y_720));
    qer = mean(abs(y_720 - rec_sig));
    fprintf('АЦП %d бит: Уровней = %d, Средняя ошибка (QER) = %.4f\n', b, 2^b, qer);

    F_q = my_dft(rec_sig);
    amps_q = abs(F_q(1 : floor(N2/2) + 1));
    
    subplot(2, 2, idx);
    stem(f_axis_720, amps_q, 'Color', [0.0, 0.45, 0.74], 'Marker', 'none', 'LineWidth', 1.5);
    xlabel('f, Гц'); ylabel('Амплитуда');
    title(sprintf('%d бит (QER = %.4f)', b, qer));
    grid on;
end

%% функции
function y = my_signal(t, f)
    y = cos(2 * pi * f * t) + sin(10 * pi * f * t);
end

function F = my_dft(samples)
    N = length(samples);
    F = zeros(N, 1);
    
    for k = 1 : N
        sum_val = 0;
        for n = 1 : N
            sum_val = sum_val + samples(n) * exp(-1i * 2 * pi * (k - 1) * (n - 1) / N);
        end
        F(k) = sum_val;
    end
end
% чтение данных
[y, Fs] = audioread('voice.wav');
y = y(:, 1);

N = length(y);
f_shift = 600;

y_spec = fft(y);


k_shift = round(f_shift * N / Fs);

% сдвиг сигнала
y_shifted_spec = zeros(N, 1);
y_shifted_spec(k_shift + 1 : N/2) = 2 * y_spec(1 : N/2 - k_shift);

y_shifted = real(ifft(y_shifted_spec));

f = (0 : N/2 - 1) * (Fs / N);

% графики
Y_orig = abs(fft(y));
Y_orig = Y_orig(1 : N/2);

Y_shift = abs(fft(y_shifted));
Y_shift = Y_shift(1 : N/2);

figure;
plot(f, Y_orig, 'b', 'LineWidth', 1.2); hold on;
plot(f, Y_shift, 'r', 'LineWidth', 1.2); 
hold off;

grid on;
xlim([0, 20000]);
title('Спектр голосового сигнала');
xlabel('Частота (Гц)');
ylabel('Амплитуда');
legend('Исходный голос', 'После сдвига (y\_shifted)');

% Воспроизведение
new_audio = audioplayer(y_shifted, Fs);
play(new_audio);

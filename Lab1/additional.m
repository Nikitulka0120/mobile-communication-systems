% основные параметры
[y, Fs] = audioread('voice.wav');
y = y(1:end, 1);
t = (0 : 1/Fs : (length(y)-1)/Fs)';
f_shift = 600;
y_shifted = real(y .* exp(1i * 2 * pi * f_shift * t));

% график
N = length(y);
f = (0:N/2-1) * (Fs / N);

% спектр исходного сигнала
Y_orig = abs(fft(y));
Y_orig = Y_orig(1:N/2);

% спектр обработанного сигнала
Y_shift = abs(fft(y_shifted));
Y_shift = Y_shift(1:N/2);

% Отрисовка на графике
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

% check voice
new_audio = audioplayer(y_shifted, Fs);
play(new_audio);
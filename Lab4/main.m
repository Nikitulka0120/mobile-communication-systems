SPS = 31;

%% генерация первой последовательности
% начальные состояния регистров
x1 = [1, 1, 0, 1, 0];
y1 = [0, 0, 0, 0, 1];

fprintf('Начальное состояние X1: %s\n', num2str(x1, '%d'));
fprintf('Начальное состояние Y1: %s\n', num2str(y1, '%d'));

% генерация первой последовательности голда
seq1 = zeros(1, SPS);
x_cur = x1;
y_cur = y1;

for i = 1:SPS
    output = xor(x_cur(5), y_cur(5));
    back_x = xor(x_cur(4), x_cur(5));
    back_y = xor(y_cur(2), y_cur(5));
    
    x_cur = [back_x, x_cur(1:4)];
    y_cur = [back_y, y_cur(1:4)];
    
    seq1(i) = output;
end

fprintf('\n==== TASK 1 ====\n');
fprintf('Полученная последовательность Голда: ');
fprintf('%d', seq1);
fprintf('\n\n');

%% таблица автокорреляции
% ручной расчет циклической автокорреляции
fprintf('==== TASK 2 ====\n');
fprintf('Сдвиг |');
for i = 0:(SPS - 1)
    fprintf(' %d |', i);
end
fprintf(' R\n');

fprintf('------+');
for i = 0:(SPS - 1)
    fprintf('---+');
end
fprintf('------\n');

R_manual = zeros(1, SPS + 1);

for offset = 0:SPS
    offseted = circshift(seq1, [0, offset]);
    
    matches = sum(seq1 == offseted);
    dismatches = sum(seq1 ~= offseted);
    
    R = (matches - dismatches) / SPS;
    R_manual(offset + 1) = R;
    
    fprintf(' %4d |', offset);
    for i = 1:SPS
        fprintf(' %d |', offseted(i));
    end
    fprintf(' %.2f\n', round(R, 2));
end
fprintf('\n');

%% генерация второй последовательности
% начальные состояния второго генератора
x2 = [1, 1, 0, 1, 1];
y2 = [1, 1, 1, 0, 0];

fprintf('==== TASK 3 ====\n');
fprintf('Начальное состояние X2: %s\n', num2str(x2, '%d'));
fprintf('Начальное состояние Y2: %s\n', num2str(y2, '%d'));

seq2 = zeros(1, SPS);
x_cur = x2;
y_cur = y2;

for i = 1:SPS
    output = xor(x_cur(5), y_cur(5));
    back_x = xor(x_cur(4), x_cur(5));
    back_y = xor(y_cur(2), y_cur(5));
    
    x_cur = [back_x, x_cur(1:4)];
    y_cur = [back_y, y_cur(1:4)];
    
    seq2(i) = output;
end

fprintf('Последовательность Голда: ');
fprintf('%d', seq2);
fprintf('\n\n');

%% взаимная корреляция
% ручной расчет взаимной корреляции
fprintf('==== TASK 4 ====\n');
fprintf('Взаимная корреляция:\n');

matches12 = sum(seq1 == seq2);
dismatches12 = sum(seq1 ~= seq2);
R12_manual = (matches12 - dismatches12) / SPS;

fprintf('R_12 = (%d - %d) / %d = %.2f\n\n', matches12, dismatches12, SPS, round(R12_manual, 2));

%% расчет встроенными функциями
fprintf('==== TASK 5 ====\n');

% автокорреляция функцией autocorr
[R_autocorr, lags_ac] = autocorr(seq1, 'NumLags', SPS - 1);

fprintf('Таблица автокорреляции встроенной функцией autocorr():\n');
fprintf('Сдвиг | autocorr\n');
fprintf('------+---------\n');
for i = 1:length(lags_ac)
    fprintf(' %4d |  %6.3f\n', lags_ac(i), R_autocorr(i));
end
fprintf('\n');

% взаимная корреляция без преобразования
[R_xcorr, lags_xc] = xcorr(seq1, seq2);
zero_idx_xc = find(lags_xc == 0);
R12_xcorr_val = R_xcorr(zero_idx_xc);

fprintf('Сравнение взаимной корреляции при сдвиге 0:\n');
fprintf('Ручной расчет (формула C++): R_12 = %.4f\n', round(R12_manual, 2));
fprintf('Встроенная функция xcorr(seq1, seq2): R_12 = %d\n', R12_xcorr_val);

% преобразование в биполярный вид {+1, -1}
s1_bipolar = 1 - 2 * seq1;
s2_bipolar = 1 - 2 * seq2;

% корреляция с нормализацией
[R_xc, lags] = xcorr(s1_bipolar, s2_bipolar, 'normalized');
zero_idx = find(lags == 0);

fprintf('Нормализованная взаимная корреляция: %.4f\n\n', R_xc(zero_idx));

%% график автокорреляции
figure;
plot(lags_ac, R_autocorr, '-o');
hold on;
plot(0:(SPS - 1), R_manual(1:SPS), '-o');
grid on;
xlabel('Задержка');
ylabel('Автокорреляция');
legend('autocorr', 'ручной расчет');

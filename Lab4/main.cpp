#include <iostream>
#include <vector>
#include <cstdint>
#include <cmath>
#include <iomanip>

#define SPS 31

using namespace std;

// циклический сдвиг вектора
void cycle_offset(vector<int8_t> &array)
{
    auto buffer = array.back();
    for (size_t i = array.size() - 1; i > 0; --i)
    {
        array[i] = array[i - 1];
    }
    array[0] = buffer;
}

// генератор последовательности голда
int8_t golds_generator(vector<int8_t> &x, vector<int8_t> &y)
{
    int8_t output = x[4] ^ y[4];
    int8_t back_x = x[3] ^ x[4];
    int8_t back_y = y[1] ^ y[4];

    cycle_offset(x);
    cycle_offset(y);

    x[0] = back_x;
    y[0] = back_y;

    return output;
}

// вывод вектора в консоль
void print_vector(const vector<int8_t> &array)
{
    for (size_t i = 0; i < array.size(); ++i)
    {
        cout << static_cast<int>(array[i]);
    }
    cout << endl;
}

// округление до двух знаков
double round2(double val)
{
    return round(val * 100.0) / 100.0;
}

// вывод таблицы циклической автокорреляции
void print_autocorrelation_table(const vector<int8_t> &seq)
{
    size_t n = seq.size();

    cout << "Сдвиг |";
    for (size_t i = 0; i < n; ++i)
        cout << " " << i << " |";
    cout << " R" << endl;

    cout << "------+";
    for (size_t i = 0; i < n; ++i)
        cout << "---+";
    cout << "------" << endl;

    for (size_t offset = 0; offset <= n; ++offset)
    {
        int matches = 0, dismatches = 0;

        vector<int8_t> offseted = seq;
        for (size_t s = 0; s < offset; ++s)
            cycle_offset(offseted);

        cout << " " << setw(4) << offset << " |";
        for (size_t i = 0; i < n; ++i)
        {
            cout << " " << static_cast<int>(offseted[i]) << " |";
            if (seq[i] == offseted[i])
                matches++;
            else
                dismatches++;
        }

        double R = static_cast<double>(matches - dismatches) / n;
        cout << " " << round2(R) << endl;
    }
    cout << endl;
}

// расчет взаимной корреляции
void print_cross_correlation(const vector<int8_t> &seq1, const vector<int8_t> &seq2)
{
    cout << "\nВзаимная корреляция:" << endl;
    int matches = 0, dismatches = 0;
    size_t n = seq1.size();

    for (size_t i = 0; i < n; ++i)
    {
        if (seq1[i] == seq2[i])
            matches++;
        else
            dismatches++;
    }
    double R = static_cast<double>(matches - dismatches) / n;
    cout << "R_12 = (" << matches << " - " << dismatches << ") / " << n
         << " = " << round2(R) << endl;
}

// проверка критериев м-последовательности
bool is_m_sequence(const vector<int8_t> &seq)
{
    int n = seq.size();

    // сбалансированность
    int ones = 0;
    for (int b : seq)
        ones += b;
    int zeros = n - ones;
    bool balance = abs(ones - zeros) <= 1;

    // цикличность
    int max_len = 0, cur_len = 1;
    for (int i = 0; i < 2 * n; ++i)
    {
        if (seq[i % n] == seq[(i + 1) % n])
        {
            cur_len++;
            if (cur_len > max_len)
                max_len = cur_len;
        }
        else
        {
            cur_len = 1;
        }
    }
    int m = round(log2(n + 1));
    bool runs = (max_len <= m);

    // корреляция
    bool autocorr = true;
    for (int offset = 1; offset < n; ++offset)
    {
        int matches = 0, dismatches = 0;
        for (int i = 0; i < n; ++i)
        {
            if (seq[i] == seq[(i + offset) % n])
                matches++;
            else
                dismatches++;
        }
        if (matches - dismatches != -1)
        {
            autocorr = false;
            break;
        }
    }

    cout << "\nПроверка критериев:" << endl;
    cout << "1) Сбалансированность: " << (balance ? "OK" : "FAIL") << endl;
    cout << "2) Цикличность: " << (runs ? "OK" : "FAIL") << endl;
    cout << "3) Корреляция -1/N: " << (autocorr ? "OK" : "FAIL") << endl;

    return balance && runs && autocorr;
}

int main()
{
    // начальные состояния регистров
    vector<int8_t> x1 = {1, 1, 0, 1, 0};
    vector<int8_t> y1 = {0, 0, 0, 0, 1};

    vector<int8_t> x2 = {1, 1, 0, 1, 1};
    vector<int8_t> y2 = {1, 1, 1, 0, 0};

    cout << "Начальное состояние X1: ";
    print_vector(x1);
    cout << "Начальное состояние Y1: ";
    print_vector(y1);

    // генерация первой последовательности
    vector<int8_t> seq1;
    for (size_t i = 0; i < SPS; i++)
    {
        seq1.push_back(golds_generator(x1, y1));
    }
    cout << "\n\n\n ==== TASK 1 ====\n";
    cout << "\nПолученная последовательность Голда: ";
    print_vector(seq1);

    // проверка свойств м-последовательности
    cout << "\nПроверка seq1:";
    if (is_m_sequence(seq1))
    {
        cout << "=> Это М-последовательность!\n";
    }
    else
    {
        cout << "=> Это НЕ М-последовательность\n";
    }

    // таблица автокорреляции
    cout << "\n\n\n ==== TASK 2 ====\n";
    print_autocorrelation_table(seq1);

    // генерация второй последовательности
    cout << "\n\n\n ==== TASK 3 ====\n";
    cout << "\nНачальное состояние X2: ";
    print_vector(x2);
    cout << "Начальное состояние Y2: ";
    print_vector(y2);

    vector<int8_t> seq2;
    for (size_t i = 0; i < SPS; i++)
    {
        seq2.push_back(golds_generator(x2, y2));
    }
    cout << "\nПоследовательность Голда: ";
    print_vector(seq2);

    // взаимная корреляция
    cout << "\n\n\n ==== TASK 4 ====\n";
    print_cross_correlation(seq1, seq2);

    return 0;
}

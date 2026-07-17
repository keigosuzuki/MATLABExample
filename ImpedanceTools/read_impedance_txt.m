function [T, T_mem] = read_impedance_txt(file_path)
% read_impedance_txt - TRACE A(実部)/B(虚部) から複素インピーダンス表を作る
%
%   T = read_impedance_txt(file_path) は、TXTファイルの TRACE A から実部、
%   TRACE B から虚部を読み込み、複素インピーダンスの絶対値と位相を計算して
%   テーブル T {Frequency, Real, Imag, Magnitude, PhaseDeg} を返します。
%
%   [T, T_mem] = read_impedance_txt(file_path) は、Memory/Sim トレース
%   （データ部 5 列の 4 列目）も読み込み、同じ形式の T_mem を返します。
%
%   TRACE A/B の長さが一致しない場合は error になります。
%
%   入力:
%       file_path - 入力TXTファイルのパス
%
%   出力:
%       T     - 測定インピーダンステーブル
%       T_mem - Memory/Simトレースのテーブル (要求時のみ)

    with_mem = (nargout >= 2);
    if with_mem
        num_cols = 5;
    else
        num_cols = 3;
    end

    [freq, vals_a] = read_impedance_trace(file_path, 'A', num_cols);
    [~, vals_b] = read_impedance_trace(file_path, 'B', num_cols);

    real_part = vals_a(:, 1);
    imag_part = vals_b(:, 1);

    % freq, real_part, imag_part が同じ長さであることを確認
    if numel(real_part) ~= numel(imag_part)
        error('配列の長さが一致しません: real=%d, imag=%d', ...
            numel(real_part), numel(imag_part));
    end

    T = make_imph_table(freq, real_part, imag_part);

    if with_mem
        sim_real = vals_a(:, 3);
        sim_imag = vals_b(:, 3);
        T_mem = make_imph_table(freq, sim_real, sim_imag);
    end

end

function T = make_imph_table(freq, real_part, imag_part)
    impedance = complex(real_part, imag_part);
    magnitude = abs(impedance);
    phase_deg = rad2deg(angle(impedance));
    T = table(freq, real_part, imag_part, magnitude, phase_deg, ...
        'VariableNames', {'Frequency', 'Real', 'Imag', 'Magnitude', 'PhaseDeg'});
end

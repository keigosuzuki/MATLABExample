function m = steadymean(time_ms, x, t_window)
% steadymean - 指定時間窓における信号の平均値（定常値）を計算する
%
%   m = steadymean(time_ms, x, [t0_ms t1_ms]) は、time_ms が
%   [t0_ms, t1_ms] に含まれるサンプルの x の平均を返します。
%   窓内にサンプルが無い場合は末尾の (t1_ms - t0_ms) 区間に
%   フォールバックし、warning を出します。
%
%   m = steadymean(time_ms, x, -N_ms) は、末尾 N_ms 区間の平均を返します。
%
%   入力:
%       time_ms  - 時刻ベクトル [ms]
%       x        - 信号ベクトル (time_ms と同じ長さ)
%       t_window - [t0_ms t1_ms] の絶対窓、または負のスカラ -N_ms
%
%   出力:
%       m - 窓内の x の平均値

    if numel(time_ms) ~= numel(x)
        error('time_ms と x の長さが一致しません。');
    end

    if isscalar(t_window)
        if t_window >= 0
            error('スカラ指定は負値 (-N_ms: 末尾 N ms) のみ有効です。');
        end
        t_end = time_ms(end);
        idx = time_ms >= (t_end + t_window);
    else
        idx = time_ms >= t_window(1) & time_ms <= t_window(2);
        if ~any(idx)
            % time_ms が 0 始まりにトリムされている場合などのフォールバック
            warning('指定窓 [%g, %g] ms にサンプルがありません。末尾 %g ms 区間で代用します。', ...
                t_window(1), t_window(2), t_window(2) - t_window(1));
            t_end = time_ms(end);
            idx = time_ms >= (t_end - (t_window(2) - t_window(1)));
        end
    end

    m = mean(x(idx));

end

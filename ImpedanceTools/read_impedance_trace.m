function [freq, vals] = read_impedance_trace(file_path, trace_name, num_cols)
% read_impedance_trace - インピーダンスアナライザTXTから指定トレースを抽出する
%
%   [freq, vals] = read_impedance_trace(file_path, 'A') は、TXTファイル内の
%   "TRACE: A" セクションを探し、"Frequency" ヘッダ行以降のデータを
%   タブ区切りで読み込みます。NaN 行（空行など）は除去されます。
%
%   [freq, vals] = read_impedance_trace(file_path, trace_name, num_cols) は、
%   データ部の総列数を指定します（既定 3。Memory/Simトレース付きは 5）。
%
%   入力:
%       file_path  - 入力TXTファイルのパス
%       trace_name - トレース名 ('A' または 'B')
%       num_cols   - データ部の総列数 (省略時 3)
%
%   出力:
%       freq - 周波数ベクトル [Hz] (1列目)
%       vals - 残りのデータ列の行列 [N x (num_cols-1)]
%              (2列目: Data Trace Real, 3列目: Data Trace Imag, ...)

    if nargin < 3
        num_cols = 3;
    end

    fid = fopen(file_path, 'r');
    if fid == -1
        error('ファイルが見つかりません: %s', file_path);
    end
    cleanup = onCleanup(@() fclose(fid));

    trace_marker = sprintf('"TRACE: %s"', trace_name);
    in_trace = false;
    data_found = false;

    % ヘッダー部分を読み飛ばし、データの開始位置を探す
    while ~feof(fid)
        tline = fgetl(fid);

        if contains(tline, trace_marker)
            in_trace = true;
        end

        % 指定トレースのセクション内で "Frequency" 行（ヘッダー）を見つける
        if in_trace && contains(tline, '"Frequency"')
            data_found = true;
            break; % データ開始直前でループを抜ける
        end
    end

    if ~data_found
        error('TRACE: %s のデータが見つかりませんでした: %s', trace_name, file_path);
    end

    % データを読み込む
    data = textscan(fid, repmat('%f', 1, num_cols), ...
        'Delimiter', '\t', 'TreatAsEmpty', {'""'});

    freq = data{1};
    vals = [data{2:num_cols}];

    % 読み込みエラー（空の行などによるNaN）を除去
    validIdx = ~isnan(freq) & ~isnan(vals(:, 1));
    freq = freq(validIdx);
    vals = vals(validIdx, :);

end

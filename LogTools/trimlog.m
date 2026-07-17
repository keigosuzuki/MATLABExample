function lg = trimlog(lg, ref_field)
% trimlog - ログ構造体を基準フィールドが非ゼロの区間にトリムする
%
%   lg = trimlog(lg) は、lg.freq_ref が非ゼロの区間 [最初, 最後] に
%   全数値フィールドをトリムし、time_ms を 0 始まりに揃えて返します。
%
%   lg = trimlog(lg, ref_field) は、基準フィールド名を指定します。
%
%   入力:
%       lg        - readlog が返すログ構造体 (time_ms フィールド必須)
%       ref_field - トリム基準のフィールド名 (省略時 'freq_ref')
%
%   出力:
%       lg - トリム後のログ構造体

    if nargin < 2
        ref_field = 'freq_ref';
    end

    if ~isstruct(lg)
        error('入力は構造体である必要があります。');
    end

    if ~isfield(lg, ref_field) || ~isfield(lg, 'time_ms')
        error('構造体に %s と time_ms フィールドが必要です。', ref_field);
    end

    idx_nonzero = find(lg.(ref_field) ~= 0);
    if isempty(idx_nonzero)
        first_idx = 1;
        last_idx = numel(lg.time_ms);
    else
        first_idx = idx_nonzero(1);
        last_idx = idx_nonzero(end);
    end

    fields = fieldnames(lg);
    for ii = 1:numel(fields)
        fld = fields{ii};
        % 範囲指定可能な数値フィールドのみトリム
        val = lg.(fld);
        if isnumeric(val) && numel(val) >= last_idx
            lg.(fld) = val(first_idx:last_idx);
        end
    end

    lg.time_ms = lg.time_ms - lg.time_ms(1);

end

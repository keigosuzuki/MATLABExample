function logs = readlogs(file_paths, reader)
% readlogs - 複数のログファイルをまとめて読み込み cell 配列で返す
%
%   logs = readlogs(file_paths) は、file_paths (cell 配列) の各ファイルを
%   readlog で読み込み、同じ長さの cell 配列を返します。
%
%   logs = readlogs(file_paths, reader) は、リーダ関数ハンドルを指定します
%   (例: @readtable)。
%
%   存在しない・読み込みに失敗したファイルは warning を出して
%   空 [] を格納します（呼び出し側で isempty 判定してください）。
%
%   入力:
%       file_paths - ファイルパスの cell 配列
%       reader     - 読み込み関数ハンドル (省略時 @readlog)
%
%   出力:
%       logs - 読み込み結果の cell 配列

    if nargin < 2
        reader = @readlog;
    end

    if ~iscell(file_paths)
        file_paths = {file_paths};
    end

    logs = cell(numel(file_paths), 1);
    for k = 1:numel(file_paths)
        fp = file_paths{k};
        if ~exist(fp, 'file')
            warning('ファイルが見つかりません: %s', fp);
            continue;
        end
        try
            logs{k} = reader(fp);
        catch err
            warning('読み込みに失敗しました: %s (%s)', fp, err.message);
        end
    end

end

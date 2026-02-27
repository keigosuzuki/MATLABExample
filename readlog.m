function data_struct = readlog(file_path)
% readlog - 指定されたCSVログファイルを読み込み、構造体に格納する
%
%   data_struct = readlog(file_path) は、指定されたパスのCSVファイルを
%   読み込み、ヘッダ情報に基づいてフィールド名が設定された構造体の配列を返します。
%
%   入力:
%       file_path - 読み込むCSVファイルのパス (文字列)
%
%   出力:
%       data_struct - データの構造体の配列。各フィールド名はCSVのヘッダに対応します。
%                     ファイルが読み込めない、またはヘッダが不正な場合は空の配列を返します。

    data_struct = [];
    
    % ファイルを開く
    fid = fopen(file_path, 'r');
    if fid == -1
        error('ファイルを開けませんでした: %s', file_path);
        return;
    end
    
    % コメント行を読み飛ばす
    tline = fgetl(fid);
    while ischar(tline) && startsWith(strtrim(tline), '#')
        tline = fgetl(fid);
    end
    
    % ヘッダ行を解析
    if ischar(tline)
        header_line = tline;
        headers = strsplit(header_line, ',');
    else
        error('ヘッダ行が見つかりませんでした。');
        fclose(fid);
        return;
    end
    
    % データ行を読み込む
    data = textscan(fid, repmat('%f', 1, numel(headers)), 'Delimiter', ',');
    fclose(fid);
    
    % データを構造体に格納
    for i = 1:numel(headers)
        % フィールド名として無効な文字を修正
        field_name = matlab.lang.makeValidName(headers{i});
        
        % 空のフィールド名をチェック
        if isempty(field_name)
            warning('ヘッダに空の列名が含まれています。この列はスキップされます。');
            continue;
        end
        
        % データをフィールドに割り当て
        if i <= length(data) && ~isempty(data{i})
            data_struct.(field_name) = data{i};
        else
            warning('データ列がヘッダの数と一致しません。フィールド "%s" は空のままです。', field_name);
            data_struct.(field_name) = [];
        end
    end

end

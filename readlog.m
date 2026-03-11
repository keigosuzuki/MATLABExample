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

    headers = {};
    last_text_tokens = {};
    data_start_line = 0;
    line_count = 0;
  
    % ヘッダ行とデータ開始行の境界を探索
    while ~feof(fid)
        tline = fgetl(fid);
        if ~ischar(tline)
            break;
        end
        line_count = line_count + 1;
    
        tline_trim = strtrim(tline);
    
        % 空行やコメント行はスキップ
        if isempty(tline_trim) || startsWith(tline_trim, '#')
            continue;
        end
    
        tokens = strsplit(tline_trim, ',');
    
        % 行内の数値データの割合を計算（数値に変換できる要素が半分以上あるか）
        num_valid = sum(~isnan(str2double(tokens)));
        is_numeric_row = (num_valid / length(tokens)) > 0.5;
    
        if is_numeric_row
            % 数値主体の行が来た場合、直前に記憶した「文字列行」と列数が一致するか確認
            if ~isempty(last_text_tokens) && length(tokens) == length(last_text_tokens)
            headers = last_text_tokens;
            data_start_line = line_count;
            break;
            end
        else
            % 文字列主体の行であれば、ヘッダ候補としてトークンを記憶しておく
        last_text_tokens = tokens;
        end
    end
  
    if data_start_line == 0
        error('ヘッダ行とデータ行のペアが見つかりませんでした。');
        fclose(fid);
        return;
    end
  
    % ファイルポインタを先頭に戻し、データ行の直前まで読み飛ばす
    frewind(fid);
    for k = 1:(data_start_line - 1)
        fgetl(fid);
    end
    
    % データ行を読み込む
    data = textscan(fid, repmat('%f', 1, numel(headers)), 'Delimiter', ',');
    fclose(fid);
    
    % データを構造体に格納
    for i = 1:numel(headers)
        % フィールド名として無効な文字を修正
        field_name = matlab.lang.makeValidName(headers{i});
        field_name = strip(field_name, '_');
        
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

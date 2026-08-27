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
    
    if ~exist(file_path, 'file')
        error('ファイルが見つかりません: %s', file_path);
    end

    try
        % readtable を使用して堅牢に読み込む (R2013b以降)
        % VariableNamingRule='preserve' でヘッダ名を維持し、後で整形する
        % detectImportOptions は R2014b 以降
        opts = detectImportOptions(file_path, 'FileType', 'text');
        opts.VariableNamingRule = 'preserve';
        opts.CommentStyle = '#';
        
        t = readtable(file_path, opts);
        
        if isempty(t)
            return;
        end
        
        % 構造体に変換 (フィールド名を MATLAB の有効な形式に整形)
        vars = t.Properties.VariableNames;
        for i = 1:numel(vars)
            original_name = vars{i};
            % フィールド名として有効な形式に変換し、前後のアンダースコアを除去
            field_name = matlab.lang.makeValidName(original_name);
            field_name = strip(field_name, '_');
            
            if isempty(field_name)
                continue;
            end
            
            data_struct.(field_name) = t.(original_name);
        end
        
    catch
        % readtable が失敗した場合のフォールバック（古いMATLABや特殊な形式用）
        fid = fopen(file_path, 'r');
        if fid == -1
            error('ファイルを開けませんでした: %s', file_path);
        end

        headers = {};
        last_text_tokens = {};
        data_start_line = 0;
        line_count = 0;
      
        while ~feof(fid)
            tline = fgetl(fid);
            if ~ischar(tline), break; end
            line_count = line_count + 1;
            tline_trim = strtrim(tline);
            if isempty(tline_trim) || startsWith(tline_trim, '#'), continue; end
            
            tokens = strsplit(tline_trim, ',');
            num_valid = sum(~isnan(str2double(tokens)));
            is_numeric_row = (num_valid / length(tokens)) > 0.5;
        
            if is_numeric_row
                if ~isempty(last_text_tokens) && length(tokens) == length(last_text_tokens)
                    headers = last_text_tokens;
                    data_start_line = line_count;
                    break;
                end
            else
                last_text_tokens = tokens;
            end
        end
      
        if data_start_line == 0
            fclose(fid);
            return;
        end
      
        frewind(fid);
        for k = 1:(data_start_line - 1), fgetl(fid); end
        
        % textscan で 'nan' を NaN として扱うよう明示的に指定
        data = textscan(fid, repmat('%f', 1, numel(headers)), 'Delimiter', ',', ...
            'TreatAsNaN', {'nan', 'NaN', 'inf', 'Inf'}, 'MultipleDelimsAsOne', false);
        fclose(fid);
        
        for i = 1:numel(headers)
            field_name = matlab.lang.makeValidName(headers{i});
            field_name = strip(field_name, '_');
            if isempty(field_name), continue; end
            
            if i <= length(data) && ~isempty(data{i})
                data_struct.(field_name) = data{i};
            else
                data_struct.(field_name) = [];
            end
        end
    end
end

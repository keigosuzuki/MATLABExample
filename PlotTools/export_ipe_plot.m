function saved_path = export_ipe_plot(fig, output_path, opts)
% export_ipe_plot - Ipeでのベクター編集に最適化したPDFを出力する
%
%   saved_path = export_ipe_plot(fig, output_path) は、fig を Ipe での
%   取り込み・編集に最適な透明背景（BackgroundColor='none'）のベクター PDF
%   として保存します。
%
%   opts (Name-Value):
%       'Resolution'      - exportgraphics の解像度 (既定 300)
%       'Batch'           - true でダイアログを出さず常に上書き保存
%                           (既定 ~usejava('desktop'): matlab -batch 実行対策)
%       'Transparent'     - 背景を透明にして出力するか (既定 true)
%
%   入力:
%       fig         - Figure ハンドル (省略時 gcf)
%       output_path - 保存先パス (拡張子 .pdf 推奨)
%
%   出力:
%       saved_path  - 実際に保存したパス。キャンセル時は ''

    arguments
        fig = gcf
        output_path (1,:) char = ''
        opts.Resolution (1,1) double = 300
        opts.Batch (1,1) logical = ~usejava('desktop')
        opts.Transparent (1,1) logical = true
    end

    if isempty(output_path)
        [file, path] = uiputfile({'*.pdf', 'Ipe-ready Vector PDF (*.pdf)'}, 'Ipe用プロットの保存');
        if isequal(file, 0) || isequal(path, 0)
            saved_path = '';
            return;
        end
        output_path = fullfile(path, file);
    end

    saved_path = '';

    % 出力先ディレクトリの自動作成
    out_dir = fileparts(output_path);
    if ~isempty(out_dir) && ~exist(out_dir, 'dir')
        mkdir(out_dir);
    end

    % 既存ファイルの上書き確認
    if exist(output_path, 'file') && ~opts.Batch
        resp = questdlg(sprintf('ファイル "%s" は既に存在します。上書きしますか？', output_path), ...
            '上書き確認', 'はい', 'いいえ', 'いいえ');
        if isempty(resp) || strcmp(resp, 'いいえ')
            [~, ~, ext] = fileparts(output_path);
            if isempty(ext); ext = '.pdf'; end
            [file, path] = uiputfile({['*', ext], [upper(ext(2:end)), ' file']}, ...
                '別名で保存', output_path);
            if isequal(file, 0) || isequal(path, 0)
                warning('保存がキャンセルされました。');
                return;
            end
            output_path = fullfile(path, file);
        end
    end

    % Ipe 用ベクター PDF のエクスポート
    is_ipe = endsWith(lower(output_path), '.ipe') || endsWith(lower(output_path), '.xml');
    pdf_target = output_path;
    if is_ipe
        pdf_target = [tempname, '.pdf'];
    end

    if opts.Transparent
        exportgraphics(fig, pdf_target, 'ContentType', 'vector', 'BackgroundColor', 'none');
    else
        exportgraphics(fig, pdf_target, 'ContentType', 'vector', 'BackgroundColor', 'w');
    end

    if is_ipe
        cmd = sprintf('pdftoipe -literal "%s" "%s"', pdf_target, output_path);
        [status, cmdout] = system(cmd);
        if exist(pdf_target, 'file')
            delete(pdf_target);
        end
        if status ~= 0
            error('pdftoipe の実行に失敗しました: %s', cmdout);
        end
        fprintf('Ipeファイルを %s にエクスポートしました。\n', output_path);
    else
        fprintf('Ipe用プロットを %s にエクスポートしました。\n', output_path);
    end
    saved_path = output_path;

end

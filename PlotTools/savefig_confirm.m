function saved_path = savefig_confirm(fig, output_path, opts)
% savefig_confirm - 上書き確認付きで Figure を保存する
%
%   saved_path = savefig_confirm(fig, output_path) は、fig を
%   exportgraphics で output_path に保存します。既存ファイルがある場合は
%   上書き確認ダイアログを表示し、「いいえ」なら別名保存ダイアログを
%   出します。キャンセル時は saved_path = '' を返します
%   （呼び出し側で isempty 判定して return してください）。
%
%   saved_path = savefig_confirm(fig, output_path, opts) の opts
%   (name-value):
%       'Resolution' - exportgraphics の解像度 (既定 300)
%       'Batch'      - true でダイアログを出さず常に上書き保存
%                      (既定 ~usejava('desktop'): matlab -batch 実行対策)
%
%   出力先ディレクトリが無い場合は自動作成します。
%
%   入力:
%       fig         - Figure ハンドル (例 gcf)
%       output_path - 保存先パス (拡張子で形式決定: .png/.pdf など)
%
%   出力:
%       saved_path - 実際に保存したパス。キャンセル時は ''

    arguments
        fig
        output_path (1,:) char
        opts.Resolution (1,1) double = 300
        opts.Batch (1,1) logical = ~usejava('desktop')
    end

    saved_path = '';

    % 出力先ディレクトリの作成
    out_dir = fileparts(output_path);
    if ~isempty(out_dir) && ~exist(out_dir, 'dir')
        mkdir(out_dir);
    end

    % 既存ファイルの上書き確認（バッチ実行時はスキップして上書き）
    if exist(output_path, 'file') && ~opts.Batch
        resp = questdlg(sprintf('ファイル "%s" は既に存在します。上書きしますか？', output_path), ...
            '上書き確認', 'はい', 'いいえ', 'いいえ');
        if isempty(resp) || strcmp(resp, 'いいえ')
            % 別名保存ダイアログを表示
            [~, ~, ext] = fileparts(output_path);
            [file, path] = uiputfile({['*', ext], [upper(ext(2:end)), ' image']}, ...
                '別名で保存', output_path);
            if isequal(file, 0) || isequal(path, 0)
                warning('保存がキャンセルされました。');
                return;
            end
            output_path = fullfile(path, file);
        end
    end

    exportgraphics(fig, output_path, 'Resolution', opts.Resolution);
    fprintf('グラフを %s に保存しました。\n', output_path);
    saved_path = output_path;

end

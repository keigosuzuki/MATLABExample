function setup_ipe_plot(fig, preset, opts)
% setup_ipe_plot - Ipeでの取り込み・仕上げに最適化したFigure/Axes設定を適用する
%
%   setup_ipe_plot(fig, preset) は、指定された Figure 配下の全 Axes および
%   Figure 自体の物理寸法・フォント・線幅・LaTeXインタープリタ・背景透明化を
%   Ipeでの図版作成（スライド・論文）に最適化します。
%
%   プリセット (preset):
%       'slide_single'    - スライド用 単一プロット (標準枠用: 140x105 mm, Font 13pt)
%       'slide_multi'     - スライド用 複合プロット (2x1, 2x2, 3x3等のサブプロット用: 200x125 mm, Font 10pt)
%       'paper_column'    - 学会論文 1段組幅 (幅 84 mm, Font 8.5pt)
%       'paper_full'      - 学会論文 2段ぶち抜き幅 (幅 174 mm, Font 9pt)
%       'paper_multi'     - 学会論文 複合サブプロット (幅 174x110 mm, Font 8.5pt)
%
%   オプション (Name-Value):
%       'FontSize'        - フォントサイズ (指定時はプリセット既定値を上書き)
%       'LineWidth'       - プロット線の太さ (既定: 1.25)
%       'GridColor'       - グリッド線の色 (既定: [0.85 0.85 0.85])
%       'GridAlpha'       - グリッドの透明度 (既定: 1.0)
%       'FontName'        - フォント名 (既定: 'Times New Roman')
%       'Interpreter'     - テキストインタープリタ (既定: 'latex')
%
%   使用例:
%       fig = figure();
%       subplot(2, 2, 1); plot(t, y); xlabel('$t$ [s]'); ylabel('$y$ [V]');
%       ...
%       setup_ipe_plot(fig, 'slide_multi');
%       export_ipe_plot(fig, 'my_slide_plot.pdf');

    arguments
        fig = gcf
        preset (1,:) char = 'slide_single'
        opts.FontSize double = []
        opts.LineWidth (1,1) double = 1.25
        opts.GridColor (1,3) double = [0.85 0.85 0.85]
        opts.GridAlpha (1,1) double = 1.0
        opts.FontName (1,:) char = 'Times New Roman'
        opts.Interpreter (1,:) char = 'latex'
    end

    % プリセットごとの寸法 [width_mm, height_mm, default_font_size]
    switch lower(preset)
        case 'slide_single'
            fig_w_mm = 140;
            fig_h_mm = 105;
            base_font_size = 13;
        case {'slide_multi', 'slide_composite', 'slide_grid'}
            fig_w_mm = 200;
            fig_h_mm = 125;
            base_font_size = 10;
        case {'paper_column', 'paper_single'}
            fig_w_mm = 84;
            fig_h_mm = 65;
            base_font_size = 8.5;
        case {'paper_full', 'paper_double'}
            fig_w_mm = 174;
            fig_h_mm = 75;
            base_font_size = 9;
        case 'paper_multi'
            fig_w_mm = 174;
            fig_h_mm = 110;
            base_font_size = 8.5;
        otherwise
            error('未知のプリセット "%s" です。slide_single, slide_multi, paper_column, paper_full, paper_multi から選択してください。', preset);
    end

    if ~isempty(opts.FontSize)
        base_font_size = opts.FontSize;
    end

    % MATLAB 標準カラー順序を color_matlab.isy に完全一致させる
    matlab_colors = [
        0.000, 0.447, 0.714;  % matlab_blue
        0.850, 0.325, 0.098;  % matlab_red
        0.929, 0.694, 0.125;  % matlab_orange
        0.494, 0.184, 0.556;  % matlab_purple
        0.466, 0.674, 0.188;  % matlab_green
        0.301, 0.745, 0.933;  % matlab_cyan
        0.635, 0.078, 0.184   % matlab_brown
    ];
    set(fig, 'DefaultAxesColorOrder', matlab_colors);

    % Figure の物理寸法と背景色設定
    set(fig, 'Units', 'centimeters');
    pos = get(fig, 'Position');
    set(fig, 'Position', [pos(1), pos(2), fig_w_mm / 10, fig_h_mm / 10]);
    set(fig, 'PaperUnits', 'centimeters');
    set(fig, 'PaperSize', [fig_w_mm / 10, fig_h_mm / 10]);
    set(fig, 'PaperPosition', [0, 0, fig_w_mm / 10, fig_h_mm / 10]);
    set(fig, 'Color', 'none');

    % 全 Axes の探索とスタイリング
    all_axes = findall(fig, 'Type', 'axes');
    for i = 1:numel(all_axes)
        ax = all_axes(i);

        % カラー順序を適用
        set(ax, 'ColorOrder', matlab_colors);

        % グリッドと副目盛り
        grid(ax, 'on');
        set(ax, 'XMinorTick', 'on', 'YMinorTick', 'on');
        set(ax, 'GridColor', opts.GridColor, 'GridAlpha', opts.GridAlpha);
        set(ax, 'MinorGridColor', opts.GridColor, 'MinorGridAlpha', opts.GridAlpha * 0.6);

        % フォント設定
        set(ax, 'FontName', opts.FontName, 'FontSize', base_font_size);
        set(ax, 'TickLabelInterpreter', opts.Interpreter);

        % 枠線と軸の線の太さ
        set(ax, 'LineWidth', 0.75);
        set(ax, 'Box', 'on');

        % 軸ラベル・タイトルのインタープリタ設定
        if ~isempty(ax.XLabel)
            set(ax.XLabel, 'Interpreter', opts.Interpreter, 'FontSize', base_font_size);
        end
        if ~isempty(ax.YLabel)
            set(ax.YLabel, 'Interpreter', opts.Interpreter, 'FontSize', base_font_size);
        end
        if ~isempty(ax.ZLabel)
            set(ax.ZLabel, 'Interpreter', opts.Interpreter, 'FontSize', base_font_size);
        end
        if ~isempty(ax.Title)
            set(ax.Title, 'Interpreter', opts.Interpreter, 'FontSize', base_font_size + 1);
        end
    end

    % 凡例のインタープリタとスタイル
    all_legends = findall(fig, 'Type', 'legend');
    for i = 1:numel(all_legends)
        lgd = all_legends(i);
        set(lgd, 'Interpreter', opts.Interpreter, 'FontSize', max(base_font_size - 1.5, 7));
        set(lgd, 'AutoUpdate', 'off');
    end

    % プロット線 (Line / Stair / Scatter) の線幅調整
    all_lines = findall(fig, 'Type', 'line');
    for i = 1:numel(all_lines)
        ln = all_lines(i);
        % グリッド線や軸枠以外のデータプロット線を太くする
        if ln.LineWidth < opts.LineWidth && ~strcmp(ln.Tag, 'GridLine')
            set(ln, 'LineWidth', opts.LineWidth);
        end
    end

end

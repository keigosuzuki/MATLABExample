function setup_plot_style(ax, font_size)
% setup_plot_style - 共通のプロットスタイルを適用する
%
%   setup_plot_style() は、現在の Axes (gca) に共通スタイル
%   （白背景・Times New Roman・minor tick・grid）を適用します。
%   フォントサイズの既定は 14 です。
%
%   setup_plot_style(ax, font_size) は、対象 Axes とフォントサイズを
%   指定します。
%
%   軸ラベル・凡例・タイトルは図ごとに異なるため、呼び出し側で
%   設定してください。
%
%   入力:
%       ax        - 対象の Axes ハンドル (省略時 gca)
%       font_size - フォントサイズ (省略時 14)

    if nargin < 1 || isempty(ax)
        ax = gca;
    end
    if nargin < 2
        font_size = 14;
    end

    grid(ax, 'on');
    set(ax, 'XMinorTick', 'on', 'YMinorTick', 'on');
    set(ax, 'FontName', 'Times New Roman', 'FontSize', font_size);
    set(ancestor(ax, 'figure'), 'Color', 'w');

end

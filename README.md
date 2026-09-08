# MATLABExample

研究用のMATLAB共通関数ライブラリ。カテゴリ別のサブフォルダに整理されています。

## 使い方

```matlab
addpath(genpath('/path/to/MATLABExample'));
```

ResearchPrj からは `setup_env.m` 経由で自動的にパスが通ります
（環境変数 `MATLABEXAMPLE_DIR`、無ければ隣接ディレクトリ `../MATLABExample` を解決）。

## ライブラリマップ

### LogTools/ — 測定ログの読み込み・前処理

| 関数 | 概要 |
|---|---|
| `readlog(file_path)` | CSVログを構造体に読み込む。ヘッダ行とデータ行の境界を自動検出 |
| `readlogs(file_paths, reader)` | 複数ファイルの一括読み込み。失敗時は warning + 空 `[]`。リーダ差替可（例 `@readtable`） |
| `trimlog(lg, ref_field)` | 基準フィールド（既定 `freq_ref`）が非ゼロの区間へトリムし `time_ms` を0始まりに |
| `steadymean(time_ms, x, t_window)` | 時間窓平均。絶対窓 `[t0 t1]` (ms) または末尾窓 `-N` (ms) |

### PlotTools/ — 図の体裁・保存

| 関数 | 概要 |
|---|---|
| `setup_plot_style(ax, font_size)` | 共通スタイル（白背景・Times New Roman・minor tick・grid）。軸ラベルは呼び出し側で設定 |
| `setup_ipe_plot(fig, preset, opts)` | Ipeでの図版作成（スライド `slide_single`/`slide_multi`、論文 `paper_column`/`paper_full`/`paper_multi`）に最適化した物理寸法・LaTeXインタープリタ・フォント・線幅を一括適用 |
| `export_ipe_plot(fig, output_path, opts)` | Ipeでのベクター編集に最適化した透明背景（`BackgroundColor='none'`）のPDFを出力 |
| `savefig_confirm(fig, output_path, opts)` | 上書き確認付き `exportgraphics`。`matlab -batch` 実行時（`~usejava('desktop')`）はダイアログなしで上書き。キャンセル時 `''` を返す |

### ImpedanceTools/ — インピーダンスアナライザTXTの解析

| 関数 | 概要 |
|---|---|
| `read_impedance_trace(fp, 'A', num_cols)` | `"TRACE: A/B"` セクションのデータ抽出（タブ区切り、NaN行除去） |
| `read_impedance_txt(fp)` | TRACE A(実部)+B(虚部) → 複素インピーダンステーブル `{Frequency, Real, Imag, Magnitude, PhaseDeg}`。第2出力で Memory/Sim トレースも取得可 |

### ProfileTools/ — 指令値プロファイル生成

| 関数 | 概要 |
|---|---|
| `traj2profile(t, freq, phase, min_duration, show_fig)` | 時系列軌道を `[freq, phase, duration_ms]` 形式の指令値プロファイルへ変換 |
| `ex_traj2profile.m` | 使用例スクリプト（`custom_trajectory_profile.csv` はそのサンプル出力） |

### TrajectTools/ — 軌道生成ツールボックス（サードパーティ）

Wataru Ohnishi 氏（東京大学, 2020）による軌道生成ツールボックス。
`backandforth`, `polyTraj`, `poly2traj` など。`Advanced_Setpoints/` の
ライセンスは同フォルダの `license.txt` を参照。**このフォルダは改変しない。**

## 規約

- 関数はH1コメントブロック（署名・入力・出力）を持つ。コメントは日本語可
- 使用例スクリプトは `ex_` プレフィックス

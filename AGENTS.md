# MATLABExample

研究用MATLAB共通関数ライブラリ。解析スクリプト、プロット整形、ログ処理等の共通ツール群を管理する。

---

## 1. ライブラリ構成と機能マップ

- **`LogTools/`**: 測定ログの読み込み・前処理
  - `readlog(file_path)`: CSVログを構造体に読み込む。ヘッダ行とデータ行の境界を自動検出
  - `readlogs(file_paths, reader)`: 複数ファイルの一括読み込み
  - `trimlog(lg, ref_field)`: 基準フィールド（既定 `freq_ref`）が非ゼロの区間へトリムし `time_ms` を0始まりに補正
  - `steadymean(time_ms, x, t_window)`: 時間窓平均。絶対窓 `[t0 t1]` (ms) または末尾窓 `-N` (ms)
- **`PlotTools/`**: 図の体裁・保存
  - `setup_plot_style(ax, font_size)`: 共通スタイル（白背景・Times New Roman・minor tick・grid）。
  - `setup_ipe_plot(fig, preset, opts)`: Ipeでの取り込みに最適化したFigure寸法・全Axesスタイリング（`slide_single`, `slide_multi`, `paper_column`, `paper_full`, `paper_multi`）。
  - `export_ipe_plot(fig, output_path, opts)`: Ipe用透明背景ベクターPDFのエクスポート。
  - `savefig_confirm(fig, output_path, opts)`: 上書き確認付き `exportgraphics`。`matlab -batch` 実行時（`~usejava('desktop')`）はダイアログなしで自動上書き。
- **`ImpedanceTools/`**: インピーダンスアナライザTXTの解析
  - `read_impedance_trace(fp, 'A', num_cols)`: `"TRACE: A/B"` セクションのデータ抽出
  - `read_impedance_txt(fp)`: TRACE A(実部)+B(虚部) → 複素インピーダンステーブル `{Frequency, Real, Imag, Magnitude, PhaseDeg}`
- **`ProfileTools/`**: 指令値プロファイル生成
  - `traj2profile(t, freq, phase, min_duration, show_fig)`: 時系列軌道を `[freq, phase, duration_ms]` 形式の指令値プロファイルへ変換
- **`TrajectTools/`**: 軌道生成ツールボックス（サードパーティ・東大 大西氏）
  - ※ **このフォルダ配下は原則改変しない。**

---

## 2. 開発・利用規約

### 他リポジトリ（ResearchPrj等）との連携
- `ResearchPrj` などの外部リポジトリからは `setup_env.m` 経由で自動的に本リポジトリへパスが通る設計となっている。
- **Git Push 順序**:
  `MATLABExample` の関数変更と `ResearchPrj` のスクリプト変更が連動する場合、**必ず先に MATLABExample をコミット・push** してから `ResearchPrj` を push すること。

### 関数設計・追加時のガイドライン
1. **汎用性と責務の分離**:
   特定の実験装置や特定プロジェクト固有の決め打ち処理は含めず、純粋なデータ処理・プロット補助関数として設計する。
2. **バッチ実行対応**:
   GUIダイアログ等の対話処理は `usejava('desktop')` で分岐し、CIやバッチ実行（`matlab -batch`）時にブロックしないよう配慮する（例: `savefig_confirm.m` の実装参照）。
3. **ドキュメンテーション**:
   関数冒頭のヘルプコメント（引数・戻り値・使用例）を明記し、`README.md` のライブラリマップにも追記する。

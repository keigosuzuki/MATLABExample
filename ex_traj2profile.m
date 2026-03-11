% ex_generate_profile.m
% traj2profile関数を使用して、指令値プロファイルCSVを生成するサンプルスクリプト
clear; close all;

%% --- 1. 軌道データの設定 ---

% 例: 5秒かけて周波数が37kHzから38kHzまで正弦波状に変化し、
%      位相が90degから0degまで線形に変化する軌道

T = 5;
Ts = 1e-3;
t = (0:Ts:T)'; % 時間ベクトル (1msステップ)

% 周波数軌道 (例: sin波)
freq_start = 37000;
freq_end = 38000;
freq = freq_start + (freq_end - freq_start)/2 * (1 - cos(pi * t / T));

% 位相軌道 (例: 線形ランプ)
phase_start = 90;
phase_end = 0;
phase = phase_start + (phase_end - phase_start) * (t / T);


%% --- 2. 指令値プロファイルへの変換 ---
show_fig = true;
min_duration_ms = 10;
profile_data = traj2profile(t, freq, phase, min_duration_ms, show_fig);


%% --- 3. CSVファイルへ保存 ---
output_path = 'custom_trajectory_profile.csv';

% 開始/終了シーケンスの追加 (任意)
add_start_end_seq = true;
if add_start_end_seq
    start_seq = [0, 90, 500];
    
    % 最後の指令値の位相を取得してend_seqに反映
    last_phase = 90;
    if ~isempty(profile_data)
      last_phase = profile_data(end, 2);
    end
    end_seq = [0, last_phase, 500];

    profile_data = [start_seq; profile_data; end_seq];
end

% CSVに書き出し
writematrix(profile_data, output_path);

fprintf('プロファイルが%s に保存されました。\n', output_path);

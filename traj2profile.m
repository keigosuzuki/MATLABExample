function profile_data = traj2profile(t, freq, phase, min_duration, show_fig)
%traj2profile 任意の時系列軌道から指令値プロファイルを生成する
%
%   Inputs:
%       t            - 時間ベクトル (sec, 1msステップ)
%       freq         - 周波数ベクトル (Hz)
%       phase        - 位相ベクトル (deg)
%       min_duration - (Optional) 持続時間の最小ステップ (ms)
%                      これより短い行は直前の行に統合される. デフォルトでは0.
%       show_fig     - (Optional) グラフを表示するかどうかのフラグ. デフォルトではfalse.
%
%   Outputs:
%       profile_data - 生成されたプロファイル行列 [freq, phase, duration_ms]

%% --- 引数の確認とデフォルト値の設定 ---
if nargin < 5
    show_fig = false;
end
if nargin < 4
    min_duration = 0;
end

if isempty(t) || isempty(freq) || isempty(phase)
    error('入力ベクトル t, frequency, phase は空にできません。');
end
if length(t) ~= length(freq) || length(t) ~= length(phase)
    error('全ての入力ベクトルの長さは同じでなければなりません。');
end


%% --- 指令値プロファイルへの変換 ---
% 指令値を整数に丸める
freq_cmd = round(freq);
phase_cmd = round(phase);

% 指令値が変化する点を検出
freq_changes = [true; diff(freq_cmd) ~= 0];
phase_changes = [true; diff(phase_cmd) ~= 0];
val_changes = freq_changes | phase_changes;

% 変化点のインデックスを取得
change_indices = find(val_changes);

% 変化点間の持続時間を計算 (単位: ms)
% 時間ベクトルのステップが1msであることを前提とする
durations_ms = diff([change_indices; length(t) + 1]);

% 変化点における指令値を取得
output_freq = freq_cmd(change_indices);
output_phase = phase_cmd(change_indices);

% プロファイルデータを作成
profile_data = [output_freq, output_phase, durations_ms];

% 持続時間が0の行は削除
profile_data(profile_data(:, 3) == 0, :) = [];

%% --- 最小持続時間の制約を適用 ---
if min_duration > 0 && size(profile_data, 1) > 1
    for i = size(profile_data, 1):-1:2
        if profile_data(i, 3) < min_duration
            % 直前の行に持続時間を加算
            profile_data(i-1, 3) = profile_data(i-1, 3) + profile_data(i, 3);
            % 現在の行を削除
            profile_data(i, :) = [];
        end
    end
end


%% --- 軌道のプロット ---
if show_fig
    figure;

    % 周波数グラフ
    subplot(2, 1, 1);
    plot(t, freq, 'LineWidth', 1.5);
    hold on;
    stairs(t, freq_cmd, 'LineWidth', 1);
    hold off;
    title('Frequency Trajectory');
    xlabel('Time [s]');
    ylabel('Frequency [Hz]');
    legend('Original', 'Command (Rounded)');
    grid on;

    % 位相グラフ
    subplot(2, 1, 2);
    plot(t, phase, 'LineWidth', 1.5);
    hold on;
    stairs(t, phase_cmd, 'LineWidth', 1);
    hold off;
    title('Phase Trajectory');
    xlabel('Time [s]');
    ylabel('Phase [deg]');
    legend('Original', 'Command (Rounded)');
    grid on;

    sgtitle('Trajectory before and after rounding');
end

end

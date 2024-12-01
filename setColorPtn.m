function [cptn,cptn_idx] = setColorPtn(item_list,num_ptn,color_div,color_border)
% SETCOLORPTN 色を適切に分割しつつグループ化することで、colororder で使用するカラーパターンを生成します。
% 
% 構文：
% [cptn, cptn_idx] = setColorPtn(item_list, num_ptn, color_div, color_border) % [cptn, cptn_idx] = setColorPtn(item_list, num_ptn, color_div, color_border)
% 
% 説明：
% この関数は、色配列を作成することにより、プロットで使用する色パターンを生成します。
% この関数は、2 種類の入力構成を取ることができます：
% 1. item_listでプロットとグループの数を直接指定します。
%    例えば、3つのグループに分け、最初のグループから1色、2番目から3色、3番目から3色を選択するには、[1 3 3]を使用します。
% 2. または、プロットの総数 (num_ptn) とグループの数 (color_div) を指定します。この場合、色はグループ間で均等に分割されます。
%    割り切れない数は、適当にいずれかのグループに分配します。コード内の記述を参考にしてください。
% 
% 両方の構成が指定された場合、関数は'item_list'によって提供された構成を優先します。
%
% 入力引数：
% - item_list : 各グループの色の数を指定するベクトル。指定された場合、他の入力を上書きします。(デフォルト: [])
% - num_ptn : (オプション) 生成する色の総数。item_list' が指定されていない場合に使用されます。(デフォルト: 1)
% - color_div : (オプション) 色を分割する色グループの数。item_list' が指定されていない場合に使用されます。(デフォルト: 1)
% - color_border : (オプション) ボーダー領域とみなす色グループの割合 (0 から 1)。
%  0にするとボーダー領域なしを意味し、1に近い場合ほぼすべての色がボーダー領域で、ごく限られた領域から色を取得します。(デフォルト： 2/3)
%  つまり'color_border'パラメータは、グループをどの程度区別して表示するかを制御します。値が小さいとグループ間の区別が少なくなり、値が大きいと同じグループ内の色の区別が少なくなります。
%
% 出力引数: 
% - cptn : プロットの色を指定するために colororder で使用できる色配列。
% - cptn_idx : HSV 色空間から選択された色のインデックス。
% 
% 例1. item_list を使用して色を指定します：
% [cptn, cptn_idx] = setColorPtn([1, 4, 5]); % 10個のプロットを3グループに分けたカラーパターン生成
% colororder(cptn);
% 
% 例2. num_ptn と color_div を使用して色を指定します：
% [cptn, cptn_idx] = setColorPtn([], 10, 3); % 10個のプロットを3グループに分けたカラーパターン生成
% colororder(cptn);

arguments
    item_list = [];
    num_ptn = 1;
    color_div = 1;
    color_border = 2/3;
end

% item_listが一次元配列であることのチェック
if ~isempty(item_list)
    if ~isvector(item_list)
        error('item_list は一次元配列（行ベクトルまたは列ベクトル）でなければなりません。');
    end
end

hsv_num = 256; % HSV色相256色を使用

% 色ベクトルの指定
hsv_vec = hsv(hsv_num);


elem = [];
if isempty(item_list) & isempty(num_ptn) & isempty(color_div)
    % いずれの引数も指定されてない場合、エラー
    error('少なくとも一つの入力を指定してください。item_listか、num_ptn、またはcolor_divのいずれかが必要です。');
elseif ~isempty(item_list) % 引数でリスト指定されている場合を想定
    num_ptn = sum(item_list);
    color_div = length(item_list);
    elem = item_list;
else    % 引数でプロット総数と色の分割数が指定されている場合を想定
    if color_div==0 % ゼロ割保護
        error('色の分割数 color_div はゼロに設定できません。');
    end
    base_elem_size = floor(num_ptn / color_div);
    remainder = mod(num_ptn, color_div);
    
    % 例えば
    % num_ptn=9, color_div=3 なら、elem=[3, 3, 3]に分配
    % num_ptn=10, color_div=3 なら、elem=[4, 3, 3]に分配
    % num_ptn=11, color_div=3 なら、elem=[4, 4, 3]に分配
    % num_ptn=12, color_div=3 なら、elem=[4, 4, 4]に分配
    elem = ones(1, color_div) * base_elem_size; 
    elem(1:remainder) = elem(1:remainder) + 1; 
end

color_idx = [];
color_ptn = [];

for i=1:color_div
    idx_start = 1+floor(hsv_num/color_div)*(i-1);
    idx_end = idx_start + floor( (hsv_num/color_div)*(1-color_border) );
    color_idx{i} = floor(linspace(idx_start, idx_end, elem(i)));
    color_ptn{i} = hsv_vec(color_idx{i},:);
end
cptn = vertcat(color_ptn{:});
cptn_idx = horzcat(color_idx{:})';

% % テスト用 HSVのどの部分を取ってきているか可視化
% scatter(cptn_idx/hsv_num,linspace(0,0,length(cptn)),100, cptn, 'filled');
% hold on;
% scatter(linspace(0,1,hsv_num),linspace(0.2,0.2,hsv_num),100, hsv_vec, 'filled');
% text(0.2,0.1,sprintf('↑から%dグループ分を抽出したもの↓',color_div),'FontSize',14)
% hold off;
end

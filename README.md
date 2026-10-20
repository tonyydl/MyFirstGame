# 小小守線 · Godot 4 塔防 Demo

以 GDScript 製作的 2D 塔防第一階段 Demo。初次檢查時此目錄為空，沒有既有專案或素材；本次檔案均為新增。

## 開始遊玩

用 Godot 4 開啟 `project.godot`，按 **F5（執行專案）**，由主選單選「開始防守」。也可以在此目錄執行：

```powershell
godot --path .
```

1. 按「開始下一波」派出敵人；進攻期間無法重複開波。
2. 三座固定哨塔自動攻擊射程內、路線進度最前的敵人；淡綠色圓圈表示射程。
3. 敵人從橘色入口沿道路前進，抵達綠色基地扣 1 點生命。
4. 清空三波敵人且基地仍有生命即可勝利；生命歸零則失敗。
5. 結果畫面可「再守一次」或返回主選單。

本階段採固定塔位，沒有建塔、金錢、升級或音效。圖形由 Godot 繪製，不需下載外部素材。

## 專案結構

```text
project.godot                 專案設定與主場景
scenes/main_menu.tscn         主選單
scenes/battlefield.tscn       戰場節點、路線容器、HUD、結果畫面
scenes/enemy.tscn             可重用 PathFollow2D 敵人
scenes/tower.tscn             可重用 Node2D 防禦塔
scripts/main_menu.gd          選單導航
scripts/map_view.gd           地圖繪製、路線座標、固定塔位
scripts/battlefield.gd        波次生成、基地生命、擊退數、勝敗
scripts/enemy.gd              路線移動、敵人生命、死亡與漏怪事件
scripts/tower.gd              射程、目標選擇、冷卻、傷害與射線
ui/theme.tres                 共用字型、顏色、按鈕與面板
tests/                       導航、移動、戰鬥、完整三波遊戲測試
tools/check_project.ps1       CLI 匯入與測試入口
docs/superpowers/plans/       分步計畫與驗證紀錄
```

敵人透過 `escaped` / `defeated` 訊號回報；戰場負責扣基地血量與更新 HUD。已死亡或漏怪的敵人會立即退出目標群組，避免重複處理。

## 調整數值

- `scripts/battlefield.gd`：基地生命 10；三波各 6 / 9 / 12 隻，出生間隔 0.85 秒；每波增加敵人血量與移速。
- `scripts/tower.gd`：射程 155、傷害 20、攻擊間隔 0.65 秒，可在 Inspector 設定。
- `scripts/map_view.gd`：路線 `waypoints`、塔位 `TOWER_POSITIONS`。

## 分步驗證

實作順序為「主選單與地圖 → 敵人移動與基地生命 → 塔攻擊與完整遊戲循環」。各步先確認對應測試失敗，再完成程式並執行 CLI 匯入與場景檢查。

```powershell
# 一次執行匯入、全部四組測試、主選單與戰場啟動檢查
powershell -ExecutionPolicy Bypass -File tools/check_project.ps1

# 也可指定 Godot 執行檔
powershell -ExecutionPolicy Bypass -File tools/check_project.ps1 -Godot 'C:\path\to\godot.exe'

# 手動執行單項
godot --headless --path . --editor --quit
godot --headless --path . --script tests/test_game_flow.gd
```

本機驗證版本為 **4.7.2.stable.official.ed1daf0bf**。測試包含導航、依時間移動與轉彎、漏怪僅扣血一次、射程與冷卻、敵人死亡、實際三波戰鬥、勝利、基地失敗、重玩重置及波次防重入。

目前受限環境無法讀取 Windows 系統憑證，Godot 會輸出 `Failed to read the root certificate store`；這是啟動時的環境診斷，離線遊戲與上述測試仍可執行。驗證工具保留原始紀錄，只豁免這一項確切診斷，任何其他錯誤或警告都會使驗證失敗。

`.tools/` 是忽略的本機驗證資料，含同版 Godot 的工作區副本、隔離的編輯器設定與日誌，遊戲不依賴此目錄。CLI 選項參考 [Godot 官方命令列文件](https://docs.godotengine.org/en/4.5/tutorials/editor/command_line_tutorial.html)。

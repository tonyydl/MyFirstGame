# 2D 塔防 Demo 分步實作計畫

> **For agentic workers:** Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 以 GDScript 製作可由主選單開始、守住三波敵人的 Godot 4 2D Demo。

**Architecture:** 獨立主選單與戰場場景；地圖管理 Path2D 路線，敵人沿 PathFollow2D 移動，塔以射程與冷卻時間攻擊。戰場統一管理波次、基地生命及勝敗。

**Tech Stack:** 本機 Godot 4.7.2、GDScript、Compatibility renderer，無外部套件或素材。

**Spec:** 使用者本次需求；空資料夾檢查結果與以下範圍約定。

## Global Constraints

- 原始資料夾完全空白，沒有既有 Godot 專案、AGENTS.md 或 Git repository。
- 只新增檔案；後續分步更新限於本次建立的檔案，不覆蓋使用者原有內容。
- 第一階段只做主畫面、固定地圖、敵人移動、固定塔攻擊、生命值和基本勝敗重玩。
- 每次功能修改後執行 Godot CLI 匯入檢查及執行檢查，再進入下一步。
- 本次直接在指定空目錄執行，不初始化 Git、不建立 worktree、不提交。
- 採用程式繪製圖形、固定塔位、三波手動開始的敵人；不加入金錢、建塔與升級。

## Review Focus

- 敵人到達終點只扣一次基地生命；死亡敵人不再扣血或成為目標。
- 移動使用 delta，不能跳過路線轉角或依賴畫面更新率。
- 塔只攻擊射程內存活敵人，冷卻期間不重複攻擊。
- 最後一波必須等場上敵人清空才勝利；基地歸零優先判定失敗。
- 遊戲結束停止移動與攻擊；重玩會重置生命、波次及計數。

## Task 1：主選單與固定地圖

**Files:** 新增 project.godot、.gitignore、scenes/main_menu.tscn、scenes/battlefield.tscn、scripts/main_menu.gd、scripts/battlefield.gd、scripts/map_view.gd、ui/theme.tres、tests/test_navigation.gd。

**Interfaces:** 主選單按鈕切換至 battlefield.tscn；地圖提供 Route: Path2D、三個固定塔位。

- [x] 先寫導航測試，確認缺少場景時失敗。
- [x] 建立 1152×720 視窗、主選單、可辨識的路線與基地、戰場 HUD、返回主選單。
- [x] CLI 匯入、導航測試、主場景執行檢查均通過。

## Task 2：敵人移動與基地生命

**Files:** 新增 scenes/enemy.tscn、scripts/enemy.gd、tests/test_movement.gd；更新本次建立的 battlefield 腳本。

**Interfaces:** Enemy.setup(health, speed)、advance(delta)、take_damage(amount)、escaped/defeated signals；Battlefield.start_wave()、base_health、wave_active。

- [x] 先寫敵人按時間移動、抵達只扣血一次的失敗測試。
- [x] 沿 Route 移動、波次排程、10 點基地生命、生命值 HUD。
- [x] CLI 匯入、導航及移動測試、戰場執行檢查均通過。

## Task 3：防禦塔攻擊與完整遊戲循環

**Files:** 新增 scenes/tower.tscn、scripts/tower.gd、tests/test_combat.gd、tests/test_game_flow.gd、README.md；更新本次建立的 battlefield 腳本。

**Interfaces:** Tower.attack_range、damage、cooldown、tick(delta)、shot signal；Battlefield.game_over、finish_game(won)。

- [x] 先寫射程、冷卻、敵人血量、死亡與漏怪排他，以及勝敗/重玩測試並確認失敗。
- [x] 加入三座固定塔、瞬時傷害加短暫射線、敵人血條、三波敵人、勝敗與重玩。
- [x] CLI 匯入、全部測試、主選單與戰場執行檢查均通過。
- [x] 補上操作方式、結構、CLI 指令與驗證紀錄。

## Progress

- 初始盤點完成：空資料夾；godot --version = 4.7.2.stable.official.ed1daf0bf。
- Task 1 完成：導航測試 RED→GREEN；匯入與兩場景 headless 執行退出碼均為 0。
- CLI 環境：Scoop portable 需寫入安裝資料夾，故複製同版執行檔至忽略的 .tools；APPDATA/LOCALAPPDATA 指向該資料夾下，以免寫入工作區外。系統憑證存放區讀取錯誤仍存在，與離線遊戲功能無關，保留原始紀錄。
- Task 2 完成：移動測試 RED→GREEN；修正測試對烘焙路線的精度預期（轉角距離採 1px 容差）；導航、移動、匯入與戰場執行均通過。
- Task 3 完成：戰鬥與遊戲流程測試 RED→GREEN；全部四組測試及兩場景啟動通過。完整三波模擬結果為擊退 27 隻、基地 10 / 10。
- 視覺驗證：以 NVIDIA OpenGL Compatibility 實際繪製主選單、戰鬥中及完整三波勝利畫面，確認無遮擋或文字截斷；預覽位於 .tools/preview-*.png。
- 最終獨立唯讀檢閱：無 Critical / Important 問題；補強建議為最後一波等待存活敵人、失敗後停止存活敵人的獨立測試斷言，已補上；未擴大驗證其他 GPU / 平台。
- 執行與範圍判斷：依使用者授權直接在指定空目錄分步新增，不額外要求設計/執行方式確認；無現存檔案被覆蓋，無 Git 分支或提交操作。
- 最終驗證入口：tools/check_project.ps1；七項檢查的原始日誌保留於 .tools/validation，分步歷史日誌保留於 .tools/history。

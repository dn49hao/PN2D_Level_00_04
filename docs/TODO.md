# 待做功能

> 还没做、以后要做的功能单独记在这里，方便查阅。  
> 已完成的系统细节不写这里：密码锁见 `docs/CODELOCK.md`，总览见 `docs/PROJECT_CONTEXT.md`。  
> 工程以 **`D:\PN2D_Level_00_04`** 为准。

最后更新：2026-09-16（圆格已拆到 Canvas；菜单外框黑底；头像不加）

---

## 今天做

| 优先级 | 项 | 说明 |
|--------|----|------|
| **已测通** | **栏内选格** | 开栏不能走、关栏能走、拾取 Yes/No、A/D 换格。Scale/Opacity 打在格子 **Border** 上（空格也能看出框）。选中 1.5 / 1.0，其它 1.0 / 0.55 |
| **已测通** | **开栏全屏变暗** | HUD 内 `Img_Dim`（Border，黑 A≈0.6）；不 SET In Menu |
| **已测通** | **开栏屏蔽 J** | `IA_Interactive` 最前看 Inventory Visible；True 空着（菜单入口）。关栏后 J 恢复 |
| **已测通** | **背包 8 格数据层 + Text 刷新** | Resize 8；`AddItem` 填空格；`RemoveItem` 清格不前挤；`Slot Texts` 刷 0–7。见 `INVENTORY.md` |
| **已测通** | **满包拒捡** | `DoYes` 看 `b Added`；失败不 Destroy；`SayBagFull` 出对话。新物品走同一套拾取板即可 |
| **已测通** | **格子出图** | `AddItem` 写入 `Inventory Images`；Refresh `Make Slate Brush` 64×64 + `Set Brush`。新物品只改实例 `Display Image` |
| **已确认** | BeginPlay 临时出板 | 开局不弹锁 |
| **已测通** | **栏内菜单壳** | 有物 J 出四项；空格无；A/D 换项格子不动；再 J 关菜单。`<`/`>` 须接 Forward。见 `INVENTORY.md` |

## 下次做

按顺序，一次只做一块。

| 优先级 | 项 | 说明 |
|--------|----|------|
| **已测通** | **菜单对齐当前格** | `PlaceSlotMenuOverSelected`；选中格上方。不要再改除非偏了 |
| **已测通** | **调查出图** | `InvActionExamine` 走 `WBP_ExaminePanel`（左图右文、J 返回）。拾取 = `Item Description`；调查 = `Examine Title` / `Examine Body`。栏内缩图已测通（只 `Set Size`，不改 Designer） |
| **已测通** | **丢弃清格** | `DoYes` 补 `In Can Discard`；`ClearSlot` Refresh Target=`Inventory HUD`。勾实例才能丢；测完去掉。见 `INVENTORY.md` 第五块 |
| **已测通** | **菜单 A/D 跳过藏项** | `MoveSlotMenuCursor`：看不见的行只改 Cand。一下 D Examine→Combine；选格仍是 `MoveSlotCursor` 0～7 |
| **进行中** | **手电进圆格** | 捡进圆格 + Canvas 独立圆格已接。下次：开局锁 `L`。菜单头像先不加。见 `INVENTORY.md` 手电节 |
| **下次** | **使用 / Combine** | 使用仍空；合成仍空。一般物菜单有「使用」项即可 |

关灯出数字仍搁置。解锁直接进背包已记，先不做。

---

## 有空再做（不挡流程）

| 项 | 说明 |
|----|------|
| 密码锁换美术 | `Img_Lock`、按钮 Style、三格底。只换图，不改控件名。`CODELOCK.md` 第 8 节 |
| 按钮改中文 | 改 Button **里面的 Text**（Delete / OK / Cancel）。不要改 `Btn_OK` 等名字 |
| 改默认密码 | Widget 变量 `CorrectCode`。墙上数字已搁置，先只改锁 |
| **解锁直接进背包** | 锁上 `Grant Item ID`（Name，空则不发）；解开 `AddItem` 到角色。不要和场景捡同一件，否则会进两次。2026-08-22 已记，先不做 |
| 拾取板增强 | 上模型可转、描述、Take it? 参考 Asleep；排在本关串通之后 |
| **背包 8 格 + 栏内操作** | 8 格 + 选格已测通；菜单见「下次做」 |
| 开局自言自语 | BeginPlay 或区域自动对话 |
| **开局锁背包 + 引导按 I** | 开局 I 无效；引导触发后才允许开栏。**第一次开栏**再提示 A/D 换格。只锁开栏，不锁 AddItem。见 `INVENTORY.md`。**先不做** |
| **手电 = 左边圆格** | 开局就有、可使用、不能丢。不进 `InventoryItems`；8 方格仍捡东西。A/D 以后最左是圆格。**菜单壳先不做** |
| Toast、环境短提示 `WBP_ScreenPrompt` | 延后 |
| 检视板正文折行 / 栏宽 | `WBP_ExaminePanel`：`Txt_Body` Fill + Padding 或 Size Box 定宽；中文 Allow Per Character Wrapping。文案在实例 `ExamineBody`。白罩已关、字已改白。**先不做** |

---

## 明确延后（先不要做）

| 项 | 为什么延后 | 以后怎么做（备忘） |
|----|------------|-------------------|
| **关灯出墙上 7/1/4** | 2026-08-22 搁置；已有实现先不动 | 开关 `BedRoom` + `PuzzleDigits` 显隐。接回本关时再测，不要在 Reveal 里改开关 |
| **三关切关** | 先做完本关一条线 | Level_00_01 → 02 → 03；GameInstance 进度；`Open Level`。可另建 `docs/CAMPAIGN_FLOW.md` |
| **存档 / 读档** | 和切关一起设计 | SaveGame：背包、旗标、当前关、门已开等 |
| **一把锁一个密码** | 现在全关一张锁、默认 `714` 即可 | 触发器 Instance Editable `CorrectCode`；Create 后 SET 到 Widget |
| **改成 4 位** | 现在锁死 3 格 | 加 `Txt_D3`、`DigitCount=4`、所有 SET/Substring 补第四格；不要只改 `DigitCount` |
| **密码锁改键盘** | 拾取先改；锁继续鼠标 | 方案已写 `CODELOCK.md` 第 16 节：0–9 / Backspace / Enter / Esc；改时去掉 UI Only |

不要把延后项和「下次做」混在一次改里。

---

## 后续：背包栏（8 格）— 规格已定，先不做

排在 **拾取板展示（第一版）** 之后。不要和本次拾取板、密码锁混做。  
布局参考 Asleep 底栏：左状态圆标 + **8 个方格**；选中格上方弹出菜单。菜单项与 Asleep 对齐并留口：**调查 / 使用 / Combine / 丢弃**。

### 格子分配

`InventoryItems` 改成固定 **8 格数组**（空格 = 空 Name）。`HasItem` 仍按 `ItemID` 查，开门不必改成按格子号。

| 规则 | 做法 |
|------|------|
| 一直捡 → 格 1、2、3、4… | `AddItem` 从左找 **第一个空格** 写入 |
| 1–8 全满 | `AddItem` 失败；提示无法拾取；物品留在地上，不 Destroy |
| 中间某格被清掉 | 该格变空，**后面的不往前挤**；下次捡的放进这个空格 |

例：`[钥匙][电池][纸条]` → 用掉/丢掉电池 → `[钥匙][空][纸条]` → 再捡手电 → `[钥匙][手电][纸条]`。

`RemoveItem`：清掉对应那一格，不要把数组缩短。开门耗钥走同一套空格回填。

满包拒捡 **已测通**（对话 `SayBagFull`，不必 `WBP_ScreenPrompt`）。格子第一版可用 Text 显示 `Item_A`；图标以后换。

### 栏内操作（选中格后）

| 操作 | 现在定什么 | 以后 |
|------|------------|------|
| **调查** | 开 **`WBP_ExaminePanel`**。两类都有 | 有 Mesh 时接到检视左栏 |
| **使用** | **一般物**才有（药剂、电池）。特殊物（钥匙）**没有这项** | 栏内使用再接效果 |
| **Combine** | 两类都有 | 配方表、结果进第一个空格 |
| **丢弃** | **一般物**才有。特殊物**不能丢** | 清格；是否扔回场景届时再定 |

栏内调查走现有 `WBP_ExaminePanel`，不要新建第三套检视。数据仍来自拾取物（`Display Image` / 描述）；不要开拾取板、不要 Yes/No。

按 I 显隐、默认隐藏 **已测通**，改多格时不要拆这套。

---

## 查阅

| 文档 | 内容 |
|------|------|
| 本文 `docs/TODO.md` | 还要做什么；背包规格见「后续：背包栏」 |
| `docs/INVENTORY.md` | 背包 8 格：数据层步骤、不要改什么、怎么测 |
| `docs/PICKUP.md` | 拾取确认：键盘光标 Yes/No（**已测通**） |
| `docs/CODELOCK.md` | 密码锁；第 17 节 Reveal（Tag，任意 Actor） |
| `docs/PROJECT_CONTEXT.md` | 全项目背景、已测通系统 |

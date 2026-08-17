# PN2D_Level_00_04 项目上下文

> 供 AI / 开发者快速了解项目。新对话可用 `@docs/PROJECT_CONTEXT.md` 引用。  
> 待做功能见 `docs/TODO.md`；密码锁见 `docs/CODELOCK.md`。

最后更新：2026-08-17（密码锁触发器已测通；待做见 `docs/TODO.md`）

---

## 基本信息

| 项 | 值 |
|----|-----|
| 项目名 | PN2D_Level_00_04 |
| 引擎 | Unreal Engine 5.5.4 |
| 路径 | `D:\PN2D_Level_00_04` |
| 类型 | **纯蓝图** 2D 关卡项目（无 `Source/`） |
| 系列 | ProjectN 2D（PN2D），当前为 Level_00 / Level_00_01 |
| 原开发路径 | `F:\work\PorjectN_2D\UE\`（已迁移，部分资源未拷贝） |

---

## 技术栈

- **Paper2D** + **PaperZD**（v2.1.4，项目插件）
- **Enhanced Input**（`IA_movement`、`IA_Sprint`、`IA_Interactive` 等）
- **Forward Shading** + Lumen
- 编辑器启动地图：`/Game/Maps/Level_00/Level_00_01/Level_00_01_P`

### PaperZD 插件

- 位置：`Plugins/Marketplace/PaperZD_5.2/`
- 已在 `.uproject` 启用 `Paper2D`、`PaperZD`
- 角色依赖：`PaperZDCharacter`、`ANBP_Player_01` 等

---

## 目录结构（Content）

```
Content/
├── Maps/Level_00/Level_00_01/     # 主关卡与子关卡
├── Assests/                       # 美术（角色、关卡资产、材质）
│   └── Charactors/C_01/BP/        # BP_Cha_01 等
└── Data/
    ├── GameBase/                  # BP_GameModeBase
    ├── InPuts/                    # 输入映射与 IA
    ├── Interactives/              # 交互 Blueprint
    ├── Dialogue/                  # S_DialogueLine、DT_Dialogue（表已建，读表播多句待接）
    └── UMG/
        ├── HUD/                   # WBP_InventoryHUD 等
        ├── LS_Interludes/         # WLS_BlackFade
        └── Dialogue/              # WBP_DialogueBox
```

---

## 已有资源（磁盘上确认存在）

### 交互 / 玩法

| 资源 | 路径 |
|------|------|
| `BP_Switch` | `Content/Data/Interactives/BaseBP/` — 事件 `Switch`，Tag 显隐 |
| `BP_Transport` | `Content/Data/Interactives/BaseBP/` — 事件 `Transport`，淡出+转门+传送 |
| `BP_Door_KeySwitch` | `Content/Data/Interactives/Door/` — 钥匙 + Switch 显隐（已测通） |
| `BP_Door_KeyTransport` | `Interactives/Door/` — 钥匙 + Transport 传送（已测通） |
| `BP_Item_Key` | `Content/Data/Interactives/`（Items 或同级）— 拾取钥匙（已测通） |
| `BPI_Player` | `Content/Data/Interactives/Interface/` |
| `BPC_Door` / `BPC_Door_NoMesh` | `Content/Assests/.../S_Porp_Door_01/` |
| `BPC_Switch` | `Content/Assests/.../S_Prop_LightSwitch_01/` |

### 输入

| 资源 | 路径 |
|------|------|
| `IA_Interactive` | `Content/Data/InPuts/Player_Movements/` |
| `IA_movement` / `IA_Sprint` / `IA_Flashlight` | 同上 |
| `IM_Player_Movement` | 同上 |
| `BPF_MappingInupt` | `Content/Data/InPuts/BP_Funtions/` |

### 角色 / UI

| 资源 | 路径 |
|------|------|
| `BP_Cha_01` | `Content/Assests/Charactors/C_01/BP/` |
| `BP_GameModeBase` | `Content/Data/GameBase/` |
| `WLS_BlackFade` | `Content/Data/UMG/LS_Interludes/` |

---

## 缺失资源（旧项目有，当前项目未迁移）

以下仅存在于编辑器历史 / 旧 `F:` 项目，**磁盘上无文件**：

- `BP_Main_Int`
- `BP_Main_Int_Child`
- `BPI_Check`
- `BP_Main_TransPort`

如需统一交互框架，需在本地 **新建**，或从旧项目手动拷贝 `.uasset`。

---

## 关卡结构（Level_00_01）

| 地图 | 用途 |
|------|------|
| `Level_00_01_P` | Persistent Level（编辑器默认打开） |
| `Level_00_01_BP` | 蓝图逻辑层 |
| `L_00_01_Bulidings` | 建筑 |
| `L_00_01_LightMap_01` | 光照 |
| `BaseLight_Map` | 基础光照 |

---

## 进行中 / 计划功能

### 1. 调查交互（Examine）— **开闭已测通**（2026-08-14）

- 方案：**纯 Blueprint**；抄 `BP_DialogueTrigger` + 角色 `Examine UI`；不新建 `BP_Main_Int`
- 资源：`WBP_ExaminePanel`（`Content/Data/UMG/Examine/`）；`BP_ExamineTrigger`（`Interactives/Examine/`）
- **布局**：全屏变暗；**左**大图；**右**标题 + 正文；下页数 `1/1` + **J 返回**（不是 Yes/No）
- 第一版：单页；`Txt_Page` 写死 `1/1`；翻页以后再 SetText
- 与钥匙分开：钥匙仍 `WBP_PickupConfirm`；检视是看图读字后返回
- **已测通**：靠近 MeshA → J 开板（软暂停）→ J 关板并恢复移动 / Icon；对话与捡钥匙未改
- 版式可继续微调：字色、换行、透明底图、`Img_Item` 不要白框（Draw As = Image）

#### `WBP_ExaminePanel`

| 项 | 说明 |
|----|------|
| Hierarchy | Canvas（默认 Collapsed）→ `Img_Dim`（全屏锚）→ `Img_Item` → `Border_Info`（右半屏；内 Vertical Box：Title/Body/Page/BackHint） |
| `Img_Dim` | 全屏；`WhiteSquareTexture`；Tint 黑 A≈0.6；须在 Hierarchy 最底 |
| `Img_Item` | 左中锚、Size 约 720×820；Angle -6 仅观感；**Draw As = Image**（Box/Border 会出白框）；图用透明 PNG |
| `Border_Info` | Anchors Min (0.5,0) Max (1,1)；字在其 Vertical Box 内，勿直接挂 Canvas |
| `SetupExamine(InTitle, InBody, InImage)` | SetText；`InImage` 蓝针=Texture2D，Is Valid 才 Set Brush |
| `ShowPanel` | **Canvas Panel Visible**（只设 self 而 Canvas 仍 Collapsed 则看不见）；PC0 Ignore Move **勾上**；In Menu + HideInteractIcons |
| `CloseExamine` | Ignore Move **不勾**；Idle；INT OBJ Valid→ShowExamine；两路→SET Examine UI=None→Remove from Parent(self) |
| `HandleExamine` | 第一版只调 `CloseExamine` |

#### `BP_ExamineTrigger`

- 由 `BP_DialogueTrigger` 复制；Overlap 仍 Add INT OBJ + ShowExamineIcon
- 变量（Instance Editable）：`ExamineTitle` / `ExamineBody` / `DisplayImage`
- **只用 Event Interactive**（接口），勿再新建同名函数
- Interactive：Is Valid(角色 Examine UI) Valid 则空着；否则 Create（Owning Player=PC0）→ SET Examine UI（Target=角色，值=Create Return）→ SetupExamine → Add to Viewport → Delay 0 → ShowPanel（后四步 Target 皆 Create Return）

#### `BP_Cha_01` 交互链（已接）

### 2. 简易背包 — 数据层已完成；HUD 进行中

- 在 `BP_Cha_01` 上已实现：
  - 变量 `InventoryItems`：类型为 **命名（Name）的集合/数组**（中文界面显示为「命名」，不是「名称」）
  - 函数 `HasItem(ItemID: 命名) → 布尔`：Contains（已对齐）
  - 函数 `AddItem(ItemID: 命名)`：Add 进集合/数组（执行白线必须经过 Add）
- **HUD**：`WBP_InventoryHUD` 上屏 + Refresh；**按 I 显隐已测通**（默认隐藏）；多格 Index / 图标仍待做
- **已定（2026-08-10）**：进游戏 **默认隐藏** 背包栏；按 **I** 显隐；引导提示打开（另做）；下滑动画后期；拾取文字提示另开 UI
- **按 I 显隐 — 已测通（2026-08-11）**
  - `WBP_InventoryHUD`：`ShowInventoryHUD` / `HideInventoryHUD` / `ToggleInventoryHUD`；变量 `Inventory Visible`；`Set Visibility` Target=`self`（Show=Visible+true，Hide=Collapsed+false）
  - 输入：`IA_Inventory`（键 **I**）→ `IM_Player_Movement`；角色用 **Started**（勿用 Triggered，连按会连 Toggle）
  - BeginPlay：Create → SET `Inventory HUD` → Owning Player=PC0 → Add to Viewport → Hide →（可选）Refresh；调用前须已 SET，否则 Accessed None
  - 对话中：`Player Status == In menu` 时忽略 I；平时 Is Valid 后 Toggle
- **UI 参考**：**Asleep（沉睡）** / Asleep: Act 1（Black Hole Games）
  - 2D 心理恐怖；手电+环境光、理智、潜行；解谜/调查
  - 截图 UI：底部常驻条；左圆标（灯泡状）+ 约 8 方格；手电/电池图标；紫边深底；场景「放大镜?」调查提示
  - **拾取确认参考视频**（约 1:00:31）：https://www.youtube.com/watch?v=3gIjtoZPiRg&t=3631s  
    （上模型可旋转 → 中描述 → 下 Take it? Yes/No）
- 可借鉴：常驻底栏、状态与道具格分离、图标道具、调查提示与背包分开、格数有限
- 第一版 MVP：底部横条 + 方格（Text 显示 `Item_A`）；圆格/图标/选中/调查提示后续
- **2026-08-05～06**：`WBP_InventoryHUD` 布局 + 上屏；`RefreshInventory`（先写单格测试）；`RemoveItem` + 开门消耗钥匙；清空后旧字不残留
- 注意：格子 Is Variable 勾在 **Text** 上不是 Size Box；Designer 默认 Text 应留空（勿当编号）
- `BP_Item_Key` 里 AddItem 后的 Print 为临时调试，可删
- **任务队列（2026-08-09 起）**：见下方「当前优先顺序」；背包多格/图标排在对话与 Icon 之后
- 延后：ExitPoint、选中框、Examine；耗钥确认可复用 PickupConfirm；环境短提示 `WBP_ScreenPrompt` 与对话框分开

### 3. 对话 / 打字机信息框 — **打字机 MVP 已测通**（2026-08-09～10）

#### 资源

| 资源 | 路径 / 说明 |
|------|-------------|
| `S_DialogueLine` | `Content/Data/Dialogue/` — Speaker(Text)、Text(Text)、NextRow(Name)、TypeSpeed(Float) |
| `DT_Dialogue` | 同上；测试链 `Test_01`→`Test_02`→`Test_03`（末行 NextRow 空）；**读表多句已测通** |
| `WBP_DialogueBox` | `Content/Data/UMG/Dialogue/` |
| `BP_DialogueTrigger` | `Content/Data/Interactives/Dialogue/` — 靠近 `Add Interactive Obj`；`Interactive` 开对话框；**已测通** |

#### 统一交互原则

- 调查 / 开门 / 拾取 / 对话：**同一套** `IA_Interactive`（J）→ `INT OBJ` → `Interactive`
- 分叉在物体内部（拾取板 / 门 / 说话），不是多套按键
- 与废纸短提示分开：角色说话用 `WBP_DialogueBox`；废纸用以后的 `WBP_ScreenPrompt`

#### `WBP_DialogueBox`（已实现）

| 项 | 说明 |
|----|------|
| 布局 | 底部 Border 条；`Txt_Speaker` + `Txt_Body` |
| 正文显示 | 变量 `BodyDisplay`（Text）+ 绑定 `Get_Txt_Body_Text`（避免难找的 UMG SetText） |
| 打字机 | `FullText` + `CharIndex` + `TypeSpeed`（默认 30=每秒约 30 字） |
| Timer | **`Set Timer by Function Name`** → 函数名 `TypeNextChar`（函数图里不好建 Custom Event） |
| Time | `1.0 / Max(TypeSpeed, 1.0)`；**Looping=true**；存 `TypeTimerHandle` |
| `ShowLine(Speaker, InText)` | 设说话人 → SET FullText → `StartTypewriter`；正文靠 **`BodyDisplay` 绑定**到 `Txt_Body` |
| `ShowRow(RowName)` | Get Data Table Row(`DT_Dialogue`) → SET CurrentRow → Break → `ShowLine`；Not Found → Close |
| `AdvanceOrClose` | 用 CurrentRow 查表 → NextRow 空则 Close，否则 `ShowRow(NextRow)`；**Row Found 白线须接 Branch** |
| `HandleInteractive` | Branch(**必须接** `Is Typing`)：True→`FinishCurrentLine`；False→**`AdvanceOrClose`**（勿再直接 Close） |
| `CloseDialogue` | StopTypewriter → Is Open=false → Game Only（Get Player Controller Index0）→ Remove from Parent → Cast 角色清空 `Dialogue UI` |
| 防闪 | 根/Border 默认 **Collapsed**；`ShowPanel` 设 Visible；角色侧 Add to Viewport 后 **Delay 0** 再 `ShowPanel` |

#### `BP_Cha_01` 交互链（正式，临时已删）

```
IA_Interactive
  → Is Valid (Dialogue UI)
       有效 → Handle Interactive          // 跳过全文 / 翻句 / 关闭
       无效 → Is Valid (Examine UI)
                有效 → HandleExamine       // 第一版：关检视板
                无效 → Is Valid (INT OBJ)
                         有效 → Interactive  // 门 / 拾取 / 对话触发器 / 检视触发器
                         无效 → （无操作）
```

**已删除**：注释「测试自我对话框」的无 INT OBJ 时 Create 临时段。

#### `BP_DialogueTrigger`（已测通；读表多句 2026-08-13）

- Overlap：Begin `Add Interactive Obj(self)`；End 清空 INT OBJ；头顶 `ShowExamineIcon` / `HideInteractIcons`
- 变量：**`StartRow`**（Name，Instance Editable，须为 `Test_01` 等**纯行名**，勿出现 `NoneTest_01`）
- `Interactive`：Dialogue UI 已有效则 Return；否则 Create → SET 角色 Dialogue UI → **`ShowRow(StartRow)`** → Add to Viewport → Delay0 → ShowPanel（Target 皆 Create Return）
- J：打字中跳过 → 满句 AdvanceOrClose 翻句 → 无 NextRow 关闭

#### J 操作预期（多句，走触发器 + 表）

| 次数 | 效果 |
|------|------|
| 靠近后第 1 次 J | 打开 + 第 1 句打字机 + 软暂停 |
| 打字中再 J | 立刻全文 |
| 全文后再 J | 下一句（有 NextRow） |
| 最后一句后再 J | 关闭并恢复移动；清空 Dialogue UI |

#### 软暂停（已测通，2026-08-10；K/L 漏洞 2026-08-12 已修）

- **勿用** `Disable Input`（会连 J/`IA_Interactive` 一起关掉，关不了对话）
- 打开（`ShowPanel`）：`Player Status = In Menu` + `Set Ignore Move Input = true`
- 关闭（`CloseDialogue`）：`Player Status = Idle` + `Set Ignore Move Input = false` + 清空 Dialogue UI
- `IA_movement`：若 Status 为 In Menu，**不要** SET Player Forward / 转 Sprite（否则 A/D 仍会转向）
- 角色原有 Switch：Idle/Walking/Running 才 Add Movement Input；In Menu 本就不走位移
- **`IA_Sprint`（K）/ `IA_Flashlight`（L）**：Triggered **与 Completed** 都须先判断 `Player Status == In menu`，True 则不改 Speed/Status（松 K 曾 SET Walking 会解开软暂停）
- 按 I 背包同理：In Menu 时忽略

#### 踩坑（已解决）

| 问题 | 原因 / 处理 |
|------|-------------|
| 找不到 SetText / 易搜成 Tool Tip | 正文改用 `BodyDisplay` 绑定 |
| Timer Event 找不到 Add Custom Event | 在**函数**里不能建 Custom Event；改用 Function Name 调 `TypeNextChar` |
| 按 J 关不掉 | Branch Condition 手勾 True，未接 `Is Typing` |
| 按 J 开不了 | 角色只 Handle/原 Interactive，无 Create；临时用「无 INT OBJ → Create」 |
| 关后无法再开 | `CloseDialogue` 须 Cast `BP_Cha_01` 将 `Dialogue UI` 置 None |
| 一帧闪全文/高亮感 | 默认 Collapsed + Delay0 后 `ShowPanel`；先 ShowLine 再 Add to Viewport |
| Accessed None DialogueUI | Delay 后误 SET 空引用，或未 Is Valid 就调 ShowPanel/Handle |
| Is Valid 误用 `DT_Dialogue` 表 | 应 Is Valid **`Dialogue UI`** Widget 引用 |
| StartRow 变成 `NoneTest_01` | Name 空值 None 与行名粘连；清空后只填 `Test_01`；实例也要改 |
| 有框无正文 | `Txt_Body` 须绑定 `BodyDisplay`；Designer 勿留默认 Text Block |
| 第二下 J 无反应 | `AdvanceOrClose` 的 **Row Found 白线须接 Branch** |
| 叠多层对话框 | Interactive 开头 Dialogue UI Valid 则 Return；角色优先 Handle |

#### 已定：对话进行中 = 游戏暂停（2026-08-10）— **软暂停已落地测通**

- 打开：In Menu + Ignore Move Input；关闭：Idle + 恢复移动
- 勿 Disable Input；藏 Icon 仍待 Icon 系统
- 打开时暂停、关闭时恢复

#### 仍待做（对话相关）

- 调试 Print 可删
- 开局/新区自言自语（BeginPlay 或区域自动 `ShowRow`）
- 门需要钥匙也可改成表行（现仍可 ShowLine）
- 复杂分支对话：以后再考虑插件 / Yarn / Ink

### 本关流程 Level_00_01 — **已定**（2026-08-14，分步实施）

```
按开关关灯
  → Tag A（灯）隐藏
  → Tag B（墙上/地上数字）显示
玩家记住数字
  → 密码锁输入
  → 对了：Reveal 钥匙（场景内先藏着，不要 Spawn）
  → 拾取（现有 BP_Item_Key + 背包）
  → 出门（现有 BP_Door_KeyTransport）
```

| 段 | 做法 | 状态 |
|----|------|------|
| 关灯 | 现有 `BP_Switch` Toggle Tag A（`BedRoom`）；只应打在灯上 | **已有** |
| 出数字 | `RevealTag`=`PuzzleDigits`；`Set Actor Hidden In Game` 取反；三画默认显、三数字默认 Hidden | **已测通** |
| 密码锁 | `WBP_CodeLock` + `BP_CodeLock`；对了 Reveal 钥匙 | **触发器开板 + 714 解开后不再开 已测通**；Reveal **未做**。详见 `docs/CODELOCK.md` |
| 刷钥匙 | Tag 显隐，不 Spawn；钥匙默认 Hidden | **待做** |
| 拾取 / 出门 | `BP_Item_Key` + `BP_Door_KeyTransport` | **已测通** |

实施顺序：① 关灯↔数字 ② 密码锁+Reveal钥匙 ③ 用现成拾取出门串一遍。  
三关切关 / 存档仍后期；本关不写关卡蓝图，继续摆 Actor。

### 当前优先顺序（2026-08-15）

1. ~~读表多句 / 变暗 / 检视开闭~~ **已测通**
2. ~~本关谜题① 关灯↔数字~~ **已测通**
3. ~~密码锁面板 Graph~~ **已测通**（临时 BeginPlay）。改密码 / 换图见 `docs/CODELOCK.md`。下一步：`BP_CodeLock` + Reveal 钥匙，再删 BeginPlay
4. Reveal 钥匙；串现有拾取出门
5. 钥匙拾取板增强；多格 Index；开局自言自语（可并行/延后）  
其后：引导按 I、Toast、环境短提示、ExitPoint；**三关切关 / 存档（后期）** 等

### 后期：三关线性流程 + 存档（已记需求，暂不实施）

> 2026-08-13 讨论存档；细节之后再做。

#### 三关线性（策划方向）

- 目标：先做 **三关** 线性游玩（如 Level_00_01 → 02 → 03）
- **当前做法不变**：玩法在 Actor/Blueprint 实例上；**尚未使用** Level Blueprint
- 推荐结构（后期落地）：
  - **多张 umap**（或 Persistent + 子关卡）= 每关一张图
  - **Game Instance**：跨关进度（当前关、通关旗标等）
  - **每关可选 `BP_LevelFlow_XX`**：编排开场对话、调查后显钥匙、通关切关（不必把整关塞进关卡蓝图）
  - **关卡蓝图**：仅少量本关胶水；非必须
- 本关内前置（密码锁后钥匙出现）：**场景内隐藏再 Reveal**；非必须 Spawn
- 切关：通关点 → 写 GameInstance → `Open Level` 下一张
- 文档：正式流程可另建 `docs/CAMPAIGN_FLOW.md`；实施前再补

#### 存档（后期）

- 需要：**存档 / 读档**（进度、背包、旗标、关卡位置等）
- 与 GameInstance 进度、三关流程一起设计；未开工
- 备忘：UE 可用 SaveGame 蓝图；存哪些字段待定（InventoryItems、Dialogue/调查旗标、CurrentLevel、门已开等）

### 4. 钥匙门 / 拾取 / 钥匙传送 — 玩法与落点已测通

#### 交互蓝图分工（重要）

| 蓝图 | 入口事件 | 行为 | 是否换位置/关卡 |
|------|----------|------|-----------------|
| `BP_Switch` | `Switch` | Tag → Toggle Visibility | 否 |
| `BP_Door_KeySwitch` | `Switch` | 钥匙检测 + 上表显隐 | 否 |
| `BP_Transport` | `Transport` | 关输入 → `WLS_BlackFade` → 门旋转 Timeline → 传送到 `Player Location` | 是（同关卡内位移） |
| `BP_Door_KeyTransport` | `Transport` | 钥匙检测 + 上表传送 | 是 |
| `BP_Item_Key` | `Switch` | `AddItem` → Destroy | — |

- **不要**假定 `BP_Switch` / `BP_Door_KeySwitch` 会传送；需要进门换位时应用 `BP_Transport` 系。
- 屏幕短提示 / 调查面板：**延后**；当前仍用 Print。

#### `BP_Door_KeySwitch`（显隐钥匙门）— 已完成

- 路径：`Content/Data/Interactives/Door/BP_Door_KeySwitch`（由 `BP_Switch` 复制）
- 变量：`RequiredItemID`（命名，默认 `Item_A`）、`bDoorOpened`（默认 **False**）
- **已测通**：无钥匙提示；拾取后 find key + 门显隐

#### `BP_Item_Key`（可拾取钥匙）— 已完成

- 由 `BP_Switch` 复制；`Switch` → Cast `BP_Cha_01` → `AddItem(ItemID)` → Destroy
- 接线：Cast 对象 / AddItem 目标必须是角色；ItemID=`Item_A`；BeginPlay 临时 AddItem 应已删

#### `BP_Cha_01.HasItem` — 已对齐 Contains

- 函数内：`InventoryItems` → Contains ← 参数 `ItemID` → Return
- 门应调用 `HasItem`（Target=角色），勿在门上对 `self` 查背包

#### `BP_Door_KeyTransport` — 钥匙 + 传送玩法已测通；无钥匙改对话框（2026-08-12）

- 流程：Branch(`Door Opened`) → 未开则 `HasItem(RequiredItemID)` → 有钥匙 SET 已开 → 原 Transport；无钥匙 → **`WBP_DialogueBox`**（非 Print）
- 变量：`RequiredItemID`=`Item_A`，`Door Opened` 默认 False；可选 NeedKey 文案
- 无钥匙：Is Valid(Dialogue UI)则跳过；否则 Create→SET 角色 Dialogue UI→ShowLine→Add to Viewport→Delay0→ShowPanel（Target=Create Return，勿门 self）
- **已测通**：有钥匙传送；无钥匙出对话框；关对话后不因门 INT OBJ 误弹头顶 Icon
- 关对话恢复 Icon：触发器→Examine；钥匙→Pickup；其它（门）→HideInteractIcons；三路白线须接到 SET Dialogue UI=None + Remove
- **踩坑**：背包 Target 须角色；对话框勿 self；Hide Icon 断线未接 Remove → 关不掉对话

#### 传送落点 — 已校准（关卡实例）；ExitPoint 延后

- 原因：关卡里门实例的 **`Player Location`** 未对准门外（蓝图默认值常为 0，要以实例为准）
- 处理：在关卡选中门 → Details → `Player Location` 填世界坐标后测通
- **ExitPoint（延后不做）**：计划在 `BP_Transport` 加 Scene 组件 `ExitPoint` → `Get World Location` → `Set Actor Location`（勾 Teleport），视口拖落点；每扇门实例各自摆 ExitPoint。当前继续用手填 `Player Location`
- 其它传送门若仍偏：同样改对应实例的 `Player Location`

### 5. UI 提示 / 环境文本 — 排在对话与 Icon 之后

- 环境只读（废纸等）：`BP_Interact_Text`（单类多实例改 `PromptText`）+ `WBP_ScreenPrompt`；量大后再考虑 DataTable
- 与 `WBP_DialogueBox` 分开，勿混用

### 6. 靠近交互提示 Icon — **头顶 A/B 已测通**（2026-08-12）

| 靠近类型 | 角色头顶 | 按 J | 状态 |
|----------|----------|------|------|
| 调查 / 对话触发器 | **MeshA** `Icon_Examine` | `WBP_DialogueBox` | **已测通** |
| 检视（图文板） | **MeshA** `Icon_Examine` | `WBP_ExaminePanel` | **开闭已测通** |
| 可拾取（钥匙） | **MeshB** `Icon_Pickup` | `WBP_PickupConfirm` | **已测通** |
| 门等 | 可另定或暂缓 | 现有门 / 传送 | 暂缓 |

#### 实现（只挂角色头顶）

- `BP_Cha_01`：`Icon_Examine` + `Icon_Pickup`（Capsule 下）；BeginPlay → `HideInteractIcons`
- 函数：`ShowExamineIcon`（显 A 隐 B）、`ShowPickupIcon`（显 B 隐 A）、`HideInteractIcons`（都隐）
- `BP_DialogueTrigger` Overlap：Cast 角色 → ShowExamine / HideInteractIcons（**不依赖**物体上 Icon）
- `BP_Item_Key` Overlap：Cast 角色 → ShowPickup / HideInteractIcons；钥匙**不挂**自己的 Icon Mesh
- 开对话 `ShowPanel` → `HideInteractIcons`；关对话 INT OBJ Valid → 可再 ShowExamine（或按类型分）
- 开拾取板 → `HideInteractIcons`；**No** → `ShowPickupIcon`；**Yes** 销毁后走 End Overlap 保持隐
- Cast：Overlap 用 **Other Actor**；开板用 **Get Player Character**（勿 Cast 钥匙 self）；勿接 AutoRTFM 之类错误 Cast
- Visibility Target **仅**两个 Icon 组件；勿 Capsule/self+Propagate
- 正式美术可换 MeshA/B 模型；侧视不用 Widget 文字当 Icon

#### 仍可选

- 关对话恢复时按 INT OBJ 精确选 A/B（钥匙 vs 触发器）
- 删掉触发器/钥匙上残留调试球
- `WBP_InteractIcon` 若未用可删

### 当前优先顺序（2026-08-15）

1. ~~读表多句 / 变暗 / 检视开闭~~ **已测通**
2. ~~本关谜题① 关灯↔数字~~ **已测通**
3. ~~密码锁面板 Graph~~ **已测通**。改密码 / 换图见 `docs/CODELOCK.md`。下一步：`BP_CodeLock` + Reveal 钥匙
4. 串现有拾取出门
5. 钥匙拾取板增强；多格 Index；开局自言自语（可并行/延后）  
其后：引导按 I、Toast、环境短提示、ExitPoint 等

---

## 会话记录

### 2026-08-04（至 08-05 凌晨存档）

- 背包数据层：`InventoryItems` + `HasItem` + `AddItem`（中文类型「命名」）
- `BP_Door_KeySwitch` 显隐钥匙门测通；`BP_Item_Key` 拾取测通
- 讨论屏幕提示 vs 调查面板 → 延后
- `BP_Door_KeyTransport` 钥匙传送测通；`HasItem` 改为 Contains 并对齐
- 发现问题：传送落点偏移（含旧 Transport 门）
- 2026-08-05：校准关卡实例 `Player Location` 后落点正确
- 下一步：其它门若偏移同样填实例坐标；常驻背包 HUD；（可选）ExitPoint / 屏幕短提示；Transport Delay→Finished

### 2026-08-05

- 传送落点：关卡实例 `Player Location` 测通；ExitPoint 延后
- UI 参考确认为 **Asleep（沉睡）**；`WBP_InventoryHUD` 布局开始

### 2026-08-06（凌晨存档）

- `WBP_InventoryHUD` 上屏；格子 Is Variable 须勾在 **Text** 上（非 Size Box）
- `RefreshInventory` + `AddItem`/`RemoveItem` 联动；开门消耗钥匙后刷新
- 清空格子后占位数字会消失（正常）；Designer 默认 Text 应留空，勿当编号用
- `BP_Item_Key` 内 Print 为临时调试，可删

### 2026-08-07（换新对话前）

- 状态确认：钥匙拾取/耗钥出门、传送落点、HUD 上屏与刷新已通
- **下一对话优先任务**：① Refresh 多格 Index ② Designer 收尾/删临时 Print ③ 可选图标
- 新对话请 `@docs/PROJECT_CONTEXT.md`

### 2026-08-07（续·存档）

- 通用拾取确认 `WBP_PickupConfirm` + `BP_Item_Key`：**已测通**
  - 弹窗 Yes/No；No 可再弹；Yes 后销毁不再弹；WaitingConfirm 防叠层；UI Only ↔ Game Only
- 当时下次优先：靠近 Icon → 拾取板增强 → 多格 Index（已被 08-09 队列更新）

### 2026-08-09

- 确认交互要两类结果：拾取确认板 / 环境文本提示；文本类用单蓝图多实例复用
- 补角色对话信息框需求；与废纸短提示分开
- 对话第一版：多句表结构 + 打字机；`TypeSpeed` 可配；J = 跳过打字 → 再 J = 下一句/关闭
- 队列：打字机 → Icon → 拾取板增强 → Refresh 多格 Index / 道具图标

### 2026-08-09～10（打字机存档）

- 新建：`S_DialogueLine`、`DT_Dialogue`（`Test_01`）、`WBP_DialogueBox`（`Content/Data/UMG/Dialogue/`）
- 打字机 MVP **已测通**：`TypeSpeed`、Timer 调 `TypeNextChar`、`BodyDisplay` 绑定、J 跳过/关闭
- `BP_Cha_01`：`IA_Interactive` 优先 `Dialogue UI`→Handle，否则 `INT OBJ`→Interactive
- **临时**：无 INT OBJ 时 Create 自测对话（「测试自我对话框」）+ Delay0→`ShowPanel` 防闪；正式触发器后删除
- `CloseDialogue` 清空角色 `Dialogue UI`；根 UI 默认 Collapsed
- 未做：`BP_DialogueTrigger`、读表多句 Advance、环境 `WBP_ScreenPrompt`、Icon
- 收工前追加需求：
  - 调查 Icon=**？** → J 出对话框/自言自语；拾取 Icon=**✋** → J 出拾取板；键位统一 J
  - **对话进行中游戏暂停**（优先软暂停）；暂停期间藏 Icon；关闭后恢复
  - 删临时 Create 后须补对话触发器，否则空地 J 无对话属正常

### 2026-08-10（下午）

- `BP_DialogueTrigger` **已测通**（Overlap→INT OBJ→Interactive→开对话框）
- 删除角色临时「测试自我对话框」；空地按 J 不再出框
- 软暂停 **已测通**：`Player Status=In Menu` + Ignore Move Input；关闭恢复 Idle
  - 踩坑：`Disable Input` 会导致 J 无法关对话；A/D 转向须在 `IA_movement` 对 In Menu 提前 Return
- 下次优先：靠近 Icon（？/✋）→ 读表多句 → 拾取板增强 → 多格 Index

### 2026-08-11（背包显隐）

- 按 **I** 显隐 `WBP_InventoryHUD` **已测通**：默认 Hide；Show/Hide/Toggle；对话中禁 I
- 踩坑：Show 时须 `Inventory Visible=true`；Hide/Refresh 须在 Create+SET 之后；`IA_Inventory` 用 **Started** 非 Triggered（否则连按偶发打不开）

### 2026-08-11（靠近 Icon · 收工）

- **Mesh Icon 部分已测通**：触发器物体 Mesh + 角色头顶；靠近显、离开隐；对话中藏 / 关后按 INT OBJ 恢复
- 放弃第一版 Widget 文字；踩坑见 FAQ（Visibility Target、Controller、侧视 Widget）
- **收工补充（已定、下次做）**：Icon **只走角色头顶**；调查 → **MeshA（？）**，拾取 → **MeshB（手）**；钥匙**不挂**物体 Icon，Overlap 只调角色切换
- **下次优先**：头顶 A/B 分型 + 钥匙接入 → 读表多句 → 拾取板增强 → 多格 Index

### 2026-08-12（软暂停漏洞）

- 对话中按 **K（跑步）/ L（手电）** 会解除 A/D 限制：**已修好**
- 原因：`IA_Sprint` 的 **Completed** 未判断 In menu，松键把 `Player Status` 设成 Walking
- 处理：Sprint / Flashlight 的 Triggered **与 Completed** 均在 In menu 时提前 Return

### 2026-08-12（头顶 MeshA/B）

- **已测通**：`Icon_Examine` / `Icon_Pickup`；触发器→Examine；钥匙→Pickup；物体不挂 Icon
- 开对话 / 开拾取板 → `HideInteractIcons`；拾取 **No** → `ShowPickupIcon`；Yes 后销毁保持隐
- 踩坑：钥匙 Overlap Cast 须 Other Actor；开板 Hide 用 Get Player Character，勿 Cast 钥匙 self
- **下次优先**：读表多句 → 拾取板增强 → 多格 Index

### 2026-08-12（门无钥匙 → 对话框）

- `BP_Door_KeyTransport` 无钥匙改开对话框 **已测通**（可同步 KeySwitch）
- 关对话按 INT OBJ 类型恢复头顶 Icon；门走 Hide，避免误弹
- 踩坑：CloseDialogue 里 HideInteractIcons 白线未接 SET Dialogue UI / Remove → 对话框关不掉；接上后修复

### 2026-08-12～13（读表多句）

- **已测通**：`ShowRow` / `AdvanceOrClose`；Handle 满句走 Advance；触发器 `StartRow`→`ShowRow`
- 踩坑：`StartRow` 勿成 `NoneTest_01`；`Txt_Body` 须绑 `BodyDisplay`；`AdvanceOrClose` 的 Row Found 须接白线；防叠层须 Valid 则 Return
- **下次优先**：拾取板增强 → 多格 Index → 开局自言自语

### 2026-08-13（流程与存档备忘）

- 确认：目前无 Level Blueprint；玩法均为关卡内 Actor BP
- **后期**：三关线性（GameInstance 进度 + 每关 Flow/Actor 编排 + Open Level）；本关前置可用显隐钥匙，非必须先 Spawn
- **后期**：存档 / 读档（SaveGame；与进度、背包、旗标一起设计）
- 均暂不实施；正式流程文档可另建 `docs/CAMPAIGN_FLOW.md`

### 2026-08-13～14（检视板 + 全屏变暗）

- **已测通**：`WBP_DialogueBox` / `WBP_PickupConfirm` 全屏变暗
- **已测通（08-14）**：检视开闭 — `WBP_ExaminePanel` + 角色 `Examine UI` + `BP_ExamineTrigger`；靠近 MeshA → J 开 → J 关
- 版式：`Img_Dim` 全屏锚；`Border_Info` 右半屏；字须在 Border 的 Vertical Box 内；字色/换行/透明底图可继续微调
- 踩坑：空 Image 变暗实心黑；`InImage` 是函数输入（蓝针）；Ignore Move 开勾关不勾
- 踩坑：不要第二个 `Interactive` 函数（只留 Event Interactive）；SET Examine UI 的 Target 须角色、值须 Create Return
- 踩坑：`ShowPanel` 须把 **Canvas Panel** 设 Visible（只设 self 而 Canvas Collapsed = 无 UI 但仍锁移动）
- 踩坑：`Img_Item` Draw As 用 **Image**；图须真透明 PNG（棋盘格烤进图会像白框）

### 2026-08-15 午（密码锁 Designer 框架已齐）

- `WBP_CodeLock` Designer **框架已齐**（推倒重画过一次）；Graph / 软暂停 / `BP_CodeLock` **未做**
- 右栏键盘 123/456/789、`0` 居中、Delete/OK/Cancel 预览已像密码锁
- 下午从接线开始，不要再改 Hierarchy

### 2026-08-14（本关谜题流程已定）

- Level_00_01：关灯(Tag A=`BedRoom`) → 数字(Tag B=`PuzzleDigits`) → 密码锁 → Reveal 钥匙 → 拾取 → 出门
- `BP_Switch` 增加可选 `RevealTag`；空则只关灯
- **已测通**：`PuzzleDigits` + `Set Actor Hidden In Game` 取反
- **已定表现**：墙上三幅画（默认显）与三个数字（默认 Hidden）**共用** `PuzzleDigits`；关灯画藏、数字出；开灯反过来
- **2026-08-14**：三幅画 + 三数字（7/1/4 Unlit）共用 `PuzzleDigits` **已测通**
- Digit：**No Collision**、**Movable**（避免挡路、少脏 Lightmap）
- 关灯只 Toggle 灯；`Toggle Visibility` 打在 Mesh 上会关掉碰撞
- Forward Shading 双方向光：主光 **ForwardShadingPriority=1**，另一盏 0
- 红字 unbuilt：Digit 改 Movable 后对其余 Static **Build Lighting Only**

### 密码锁（单独文档）

**维护入口：[`docs/CODELOCK.md`](CODELOCK.md)**（改密码、换图、Graph 接法、下一步触发器）。下面历史收工记保留，新改动写 CODELOCK。

### 下午开工：谜题②密码锁（2026-08-15 午收工记）

`WBP_CodeLock` Designer **框架已齐**（`Content/Data/UMG/Puzzle/`）。面板 Graph 已于 2026-08-16 夜测通；`BP_CodeLock` 未建。**不要再改 Hierarchy**。

### 2026-08-16 凌晨（密码锁 Graph 进行中，未测）

**变量（沿用，勿强改名）：** `InputCode`（已输入）、`DigitCount`=3（上限）、`CorrectCode`=`714`（Instance Editable）

**已接：**

| 项 | 状态 |
|----|------|
| `RefreshDigits` | 三格：Len>0/1/2 → Substring Start 0/1/2 → Txt_D0/D1/D2；False 清空同格 |
| `AppendDigit(Digit: String)` | **Digit 须为函数 Inputs**；Len(InputCode)>=DigitCount 则 Return；否则 Append→SET→RefreshDigits |
| 数字键 | Event Construct→Bind OnClicked；**OnClicked_Event 白线**→AppendDigit（Digit 填在调用节点上）。至少 7/1/4；Bind 出口白线勿接 Append |
| Hierarchy | 勿再改 |

**未做 / 已改（见下方 08-16 晚）：** 显示不要走 `RefreshDigits` 函数。

### 2026-08-16 晚（密码锁今晚收工）

工程：`D:\PN2D_Level_00_04`，当前 **`main`**。临时用角色 BeginPlay Create 出板测，**先不建 `BP_CodeLock`**。

**已测通（不要回退）：**

| 项 | 结果 |
|----|------|
| BeginPlay Create + ShowPanel | 进关出板 |
| Cancel OnClicked → ClosePanel | 关板、能走 |
| DigitCount 默认 3；CorrectCode `714` | 已设 |
| **Event Graph OnClicked → SET `Txt_D0`** | **格子能出字**（点 7 出 7） |
| 0–9 / Delete / OK 对错 | **已测通**（2026-08-16 夜） |

**不要用（已证实会空格 / 浪费时间）：**

- 函数 `RefreshDigits` 里 SetText（False 空 SetText 易抄错 Target；函数里改格子不显示）
- Bind 的 **then** 接 ClosePanel / AppendDigit / DeleteLast（Construct 时就会跑）
- 数组 Append（Element List）；要用 **Append (String)** A+B
- 粉线插白口；SET 控件却不接白线执行

**显示规则（今晚只准这一种）：** 改左三格只在 **Event Graph 的 OnClicked** 上，用和 Construct 成功时**同一颗**「SET `Txt_Dx` 的 Text」。先不要调 `RefreshDigits`。

**今晚顺序（改一块、测一块，测不过不要往下）：**

1. **显示** — `Btn_7` OnClicked：Append(String)→SET InputCode→按 Len SET D0/D1/D2。测：7、1、4 三格有字；第 4 下无效。再抄 0–9。
2. **Delete** — OnClicked 只调 `DeleteLast`，然后同样三格 SET（或 DeleteLast 末尾只 SET 三格，不调 RefreshDigits）。测：删最后一位。
3. **OK** — OnClicked 只调 `TryConfirm`。对 714 → ClosePanel；错 → ClearEntry + 清三格。测对/错。
4. **Cancel** 已通，不要改 Bind then。
5. 通了再 **Save**；`BP_CodeLock` / 删 BeginPlay 临时段 **明天**。

**出问题先测哪：** 格子无字 → 只在该键 OnClicked 硬 SET `Txt_D0`=`7`（Event Graph）；能出则拼字/Len 错，不能出则 Bind/OnClicked。关不掉 → Cancel 的 OnClicked 是否 ClosePanel。进关红字 Game Only → Bind then 误接了 ClosePanel。

**接线：** Bind then 只串下一个 Bind；OnClicked 白线才进逻辑。白接白、粉接粉。改完 **Stop PIE → Compile → Play**，不要 Simulating 时改图。

**踩坑（今晚）：** 勿空白搜 Length（从粉针拖）；Substring 无白线；三个 Substring 勿共用；Append 上限比的是 InputCode 不是 Digit；`>=` 接 DigitCount 不是 Digit；Assign OnClicked 后 Append 接在 **OnClicked_Event 白线**；Digit 必须是函数输入参数才有填框。

**已定玩法（不要改回 +/-）：**

- 外壳：全屏变暗、软暂停、出鼠标 + UI Only
- 点数字从左往右填三格；满 3 位再点数字无效
- **删除**：清最后一位；**确认**：比对默认 **`714`**，对了 Reveal 钥匙（Tag，不 Spawn）并关板；错了清空三位、板不关；**返回**：关板不提交
- 功能键预览文案暂为英文 Delete / OK / Cancel（可以后改中文）；按按钮名字接线

**已定 Hierarchy（2026-08-15 午已核对，无大问题）：**

```
Canvas Panel
├── Img_Dim                 Border；铺满；黑 A≈0.6；Draw As = Box/Rounded Box（不要空 Image，会炸 Designer 视口）
└── Border_Panel            Slot：锚正中；Alignment 0.5,0.5；Size 1100×720；ZOrder 1
    └── HB_Main
        ├── SB_Left
        │   └── VB_Left
        │       ├── SizeBox_Lock → Img_Lock     320×320 占位，图以后贴
        │       ├── Spacer                      Y=24
        │       ├── HB_Digits
        │       │   ├── SizeBox_D0 → Border_D0 → Txt_D0
        │       │   ├── SizeBox_D1 → Border_D1 → Txt_D1
        │       │   └── SizeBox_D2 → Border_D2 → Txt_D2
        │       └── Txt_Label                   「CODE」；须与 HB_Digits 平级
        └── SB_Right
            └── VB_Right
                ├── HB_Row1 → SB_1/2/3 → Btn_1/2/3 → Text
                ├── HB_Row2 → SB_4/5/6 → Btn_4/5/6 → Text
                ├── HB_Row3 → SB_7/8/9 → Btn_7/8/9 → Text
                ├── HB_Row0 → Pad_L · SB_0 → Btn_0 · Pad_R     （0 对准 8）
                └── HB_Actions → SB_Delete/OK/Cancel → Btn_* → Text
```

数字键 Size Box **96×96**；功能键约 **140×56**。Button 在 UE5 **不自带 Text**，须自己拖进去。

**下午接线顺序：（2026-08-15 夜继续）**

1. Canvas 进游戏前改 **Collapsed**；`ShowPanel` 把 Canvas 设 Visible（抄检视）
2. 角色加 `CodeLock UI`；J 链：Dialogue → Examine → CodeLock → INT OBJ
3. `ShowPanel` / `ClosePanel`：In Menu + Ignore Move + 显鼠标 + UI Only / 恢复 Game Only
4. 数字键填位；删除；确认比对；返回关板
5. 再建 `BP_CodeLock`（抄 `BP_ExamineTrigger`）+ 钥匙 Tag `PuzzleKey`

#### `WBP_CodeLock` Graph 规格（接线用）

**变量**

| 名 | 类型 | 默认 | 说明 |
|----|------|------|------|
| `CorrectCode` | String | `714` | Instance Editable |
| `Entered` | String | 空 | 当前已输入 |
| `MaxDigits` | Int | 3 | |
| `RevealKeyTag` | Name | `PuzzleKey` | 对了后 Get All Actors With Tag → Set Actor Hidden In Game = false |
| `Is Open` | Bool | false | 防重复 |

**Designer**：根 `Canvas Panel` 默认 **Collapsed**（进 PIE 前改好）。

**函数 `RefreshDigits`**：`Txt_D0/D1/D2` 分别显示 `Entered` 第 0/1/2 字符；长度不够则该格 `SetText` 空（或 `_`）。

**函数 `AppendDigit(Digit: String)`**：若 `Len(Entered) >= MaxDigits` Return；否则 `Entered = Entered + Digit` → RefreshDigits。

**函数 `DeleteLast`**：若 Len>0，`Left(Entered, Len-1)` → SET Entered → RefreshDigits。

**函数 `ClearEntry`**：Entered=`""` → RefreshDigits。

**函数 `ShowPanel`**（抄检视 + 拾取鼠标）：
1. Canvas Panel → Visible；Is Open=true
2. PC0：`Set Ignore Move Input` true；Cast 角色 → Status=`In Menu`；`HideInteractIcons`
3. `Set Show Mouse Cursor` true；`Set Input Mode UI Only`（Widget=self，勾 Flush）

**函数 `ClosePanel(bSolved: Bool)`**：
1. Is Open=false；ClearEntry（可选：解开后也清）
2. Mouse false；`Set Input Mode Game Only`
3. Ignore Move false；Status=`Idle`
4. INT OBJ Valid → 可再 ShowExamine（或 Hide，门锁用 Examine 图标）
5. SET 角色 `CodeLock UI`=None → Remove from Parent(self)

**函数 `TryConfirm`**：
- `Entered == CorrectCode` → Get All Actors With Tag(`RevealKeyTag`) → 每个 `Set Actor Hidden In Game(false)` → `ClosePanel(true)`
- 否则 → ClearEntry（板不关）

**函数 `HandleCodeLock`**：第一版只 `ClosePanel(false)`（J 当返回，与 Cancel 同）

**Event Construct 或按钮绑定**：
- `Btn_0`…`Btn_9` OnClicked → AppendDigit(`"0"`…`"9"`)
- `Btn_Delete` → DeleteLast
- `Btn_OK` → TryConfirm
- `Btn_Cancel` → ClosePanel(false)

#### `BP_Cha_01`

- 变量 `CodeLock UI`：`WBP_CodeLock` 对象引用
- `IA_Interactive`：Dialogue Valid→Handle；否则 Examine Valid→HandleExamine；否则 **CodeLock Valid→HandleCodeLock**；否则 INT OBJ→Interactive

#### `BP_CodeLock`（新建，路径 `Interactives/Puzzle/`，抄 `BP_ExamineTrigger`）

- Overlap：Add INT OBJ + ShowExamineIcon / End 清空 + Hide
- Interactive：CodeLock UI Valid 则 Return；否则 Create `WBP_CodeLock`（Owning=PC0）→ SET 角色 CodeLock UI →（可选 SET CorrectCode/RevealKeyTag）→ Add to Viewport → Delay0 → ShowPanel
- 场景钥匙 Actor 默认 **Hidden**，Tag=`PuzzleKey`（与 RevealKeyTag 一致）

**Designer 踩坑（已解决，勿重蹈）：**

| 问题 | 处理 |
|------|------|
| 空 Image / Image=None 铺满 | Designer 视口白光条、Zoom 卡死；变暗用 **Border** 纯色，或先 Collapsed 再重开 Widget |
| Border 直接丢进 Horizontal Box | 竖着拉满、画刷糊成条；必须 **Size Box 包住** 再放 Border/Button |
| 拖到预览上 | 必须拖到 Hierarchy **名字上** |
| `HB_Digits` 与 `SB_Left` 平级 | 三框跑到锁图右边；须在 `VB_Left` 里、Spacer 下 |
| `Txt_Label` 进了 `HB_Digits` | CODE 和框挤一行；须与 `HB_Digits` 平级 |
| `Pad_L` `Pad_R` `SB_0` 顺序错 | 须 `Pad_L` → `SB_0` → `Pad_R` |
| Details 搜 size 只见 Image Size 32 | **不要改 Image Size**；面板大小改 Slot Size X/Y |
| Border Draw As = Border | 九宫格厚相框；用 **Rounded Box / Box** |
| UE5 Button 无自带 Text | 自己往 Button 名字上拖 Text |

---

---

### 拾取确认面板 — 已测通

| 资源 | 职责 |
|------|------|
| `WBP_PickupConfirm` | 通用 Yes/No + `SetupPrompt`；`SourcePickup` 引用拾取物 |
| `BP_Item_Key` | Switch：WaitingConfirm 锁 → Create 面板 → SetupPrompt → SourcePickup=self → Viewport → 显鼠标 + UI Only |

- **已测通**：弹出确认；No 可再弹；Yes 拾取后不再弹；关面板恢复 Game Only
- Yes：AddItem → Destroy(SourcePickup) → 藏鼠标 → Game Only → Remove from Parent
- No：藏鼠标 → Game Only → WaitingConfirm=False → Remove from Parent（Is Not Valid 也要关面板）
- Get Player Controller 用**无 Target**的那个（勿用 Target is Player State）
- AddItem 用角色函数（Target is BP_Cha_01），勿用 List View 的 Add Item

### 拾取展示增强 — 已记需求，待做

参考 Asleep 拾取界面（用户参考视频约 **1:00:31**）：  
https://www.youtube.com/watch?v=3gIjtoZPiRg&t=3631s  
（Asleep - Ato 1 Gameplay Walkthrough；该段为拾取确认 UI）

确认板不只 Yes/No，还可：

| 能力 | 说明 |
|------|------|
| **显示模型** | 面板上方展示道具模型（可 3D 渲染图 / Mesh） |
| **自动旋转** | 展示中模型持续慢速旋转 |
| **物品描述** | 可配置描述（如 “Used batteries. Do they still work?”）+ 提问句（“Take it?”） |
| **Yes / No** | 已有 `WBP_PickupConfirm` |

- 布局参考：上模型 → 中描述 → 下 Take it? + Yes/No  
- 建议扩展 `WBP_PickupConfirm`；数据由拾取物传入（Mesh/软引用 + Description + PromptText）
- 排在 Icon 之后

---

## AI 协作说明

- **无法**直接操控 Unreal 编辑器 UI；通过 Blueprint 步骤文档协作
- **无法**直接编辑 `.uasset` 二进制；可写 `.uproject`、`.ini`、文档、脚本
- 用户偏好：**简体中文**回复
- Context 快满时：更新本文件 + `.cursor/rules/pn2d-project.mdc`

---

## 常见问题

| 问题 | 处理 |
|------|------|
| PaperZD 类加载失败 | 确认 `Plugins/Marketplace/PaperZD_5.2/` 存在且 `.uproject` 已启用 |
| 找不到 BP_Main_Int | 正常，当前项目未包含，需新建 |
| 材质依赖缺失 | 如 `MI_Floor_Indoor_01a`，与交互无关，需补资源或 Fix Redirector |
| 中文界面找不到 Name 类型 | 搜「命名」或英文 `Name`；也可用「字符串」数组 |
| AddItem 不加道具 | 白线（执行）必须经过 ADD，不能直接进返回节点 |
| 钥匙门不进检测 / 不出 find key | 检查 `bDoorOpened` **默认值**是否误为 True |
| 看不出门有没有开 | 原 Switch 是按 Tag Toggle Visibility；先 Print Length，再查 Tag |
| 捡了钥匙门仍「需要钥匙」 | 核对 ID；**HasItem/Inventory 的 Target 必须是角色不是门**；可用 Contains 直连验证 |
| 门开了但不传送/不换位 | `BP_Switch` 只显隐；传送用 `BP_Transport` / `BP_Door_KeyTransport` |
| Transport 传送异常/重复 | Delay→SetActorLocation 勿接 Timeline Update，改接 Finished |
| 出门落点偏移/不对齐门 | 关卡选中门 → Details → `Player Location` 填世界坐标；建议勾 Teleport；可用 Target Point 抄 Location |
| 对话按 J 关不掉 | `HandleInteractive` 的 Branch 须接 `Is Typing`，勿手勾 True |
| 对话闪一帧全文 | 默认 Collapsed；ShowLine→Add to Viewport→Delay0→ShowPanel；打开时勿调 Handle |
| DialogueUI Accessed None | Target 用 `Dialogue UI`；Delay 后勿 SET 空；调用前 Is Valid |
| 函数里 Timer 无 Add Custom Event | 改用 `Set Timer by Function Name` 调 `TypeNextChar` |
| UMG SetText 易找成 Tool Tip | 用 `BodyDisplay` 绑定，或从控件针拖出确认 Target is Text |
| 对话中 J 关不掉 | 勿对角色 Disable Input；用 In Menu + Ignore Move Input |
| 对话中 A/D 仍转向 | `IA_movement` 在 In Menu 时勿 SET Player Forward / 转 Sprite |
| 进触发器仍出旧台词 | 多半走了角色临时 Create；确认 INT OBJ 与分支 B |
| InventoryHUD Accessed None | BeginPlay 须 Create→SET→再 Hide/Refresh；Owning Player 接 PC0；查是否两套变量名 |
| 快速按 I 有时打不开 | `IA_Inventory` 改接 **Started**，勿用 Triggered（会连 Toggle） |
| 角色进游戏消失 | Icon 的 Set Visibility 勿对 Capsule/`self`+Propagate；Target 仅 `PlayerInteractIcon` |
| Widget Icon 编辑器有游戏无 | 侧视 World 平面易成一条边；已改 Mesh；若仍用 Widget 须朝向相机 |
| 对话框 Compile：not BP_Cha_01 / invalid INT OBJ | 角色变量 Target 接 Cast 结果；Controller 用 Index0 无 Target 版 |
| 对话中按 K/L 后又能 A/D | Sprint/Flashlight 的 **Completed** 也要拦 In menu；勿在对话中 SET Status=Walking/Running |
| 关对话后门头顶误出 Icon | Close 恢复 Icon 须按类型；门等走 HideInteractIcons |
| 全屏变暗实心黑 | `Img_Dim` 须指定 `WhiteSquareTexture`；Tint 黑且 **A≈0.6**（A=1 或空 Image 会不透明） |
| SetupExamine 搜不到 InImage | 它是函数 **Inputs** 里自建的参数，从入口蓝/粉针拖出，不要空白处搜名字 |
| 关灯后能走进碰撞 | `Toggle Visibility` 会关网格碰撞；`BedRoom` 只打灯；数字 Mesh 用 **No Collision** |
| 双方向光黄字 | Forward Shading 只能一盏主光；设 **ForwardShadingPriority** |
| 数字不亮 | Cube 的 Material Element 0 须换成 Unlit 材质，不要留 `BasicShapeMaterial` |
| 检视 Compile：两个 Interactive | 只留接口 **Event Interactive**，删掉后加的同名函数 |
| J 锁移动但看不见检视板 | `ShowPanel` 须 Set Visibility **Canvas Panel**；并有 Add to Viewport；Delay0 后再 ShowPanel |
| 检视字在左上、无遮罩 | `Img_Dim` 全屏锚；`Border_Info` 右半屏锚；Text 放进 Border 的 Vertical Box |
| 检视图周围白框 | `Img_Item` Draw As = **Image**；贴图用透明 PNG，勿把棋盘格画进图 |
| 改 Icon 恢复后对话框关不掉 | Show/Hide 三路白线须接到 SET Dialogue UI=None + Remove from Parent |
| 变暗搜不到 WhiteSquareTexture | `Img_Dim` 用 Border 黑 A≈0.6；或 Image Tint A=0.6；勿 A=1 / 空 Image 实心黑 |
| UMG 画布巨大糊框 | Designer 勿 Zoom -10；Border Draw As 用 Box/Rounded Box，勿 Border；面板大小改 Slot Size 不是 Image Size 32 |

---

## 相关旧项目（参考用）

`PN2D_ArtWhiteBox`、`PN2D_BaseMove`、`PN2D_MoveSYS`、`PN2D_Level_00_01_*` 等均在原 `F:` 路径，勿假设本地可用。

微信参考工程（2026-08-15）：`C:\Users\MSI_NB\xwechat_files\...\2026-08\PN2D_01` — 旧交互/UI 参考，见下节「回头小调整」。

---

## 回头小调整（待做，勿打断当前密码锁）

参考 `PN2D_01` 的 UI/交互做法，**以后做小改**，不整包搬：

| 学 | 做法 |
|----|------|
| 少 Cast 具体 BP | 交互接口（对齐 `BPI_INT_Check` 或新建 `BPI_Interact`）；角色 J 调接口 |
| 开板表现 | 可选抄 `UMG_Fade` 淡入淡出 |
| 调查文案 | 表驱动（已有对话表；检视可类似 `DT_CheckList_Home`） |

**不要照搬：** `SetGamePaused` 硬暂停（继续软暂停）；整换 `UMG_OnCheck` / 整包背包 UMG。

**保持：** Collapsed→Delay0→ShowPanel；J 链 Dialogue→Examine→CodeLock→INT OBJ；关板清空引用。

---

## 04 仓库：墙上密码数字提示（2026-08-15 查）

路径：`D:\PN2D_Level_00_04`。

| 资源 | 状态 |
|------|------|
| 贴图 `Interactives/Puzzle/11` `44` `77`（Texture2D） | **在** |
| `M_Digit_1`、`M_PuzzleDigit_Unlit` | **在** |
| `M_Digit_4` / `M_Digit_6` / `M_Digit_7` | **曾缺失**（04 只有 1；关卡用 7/1/4 会粉/丢材质）→ **已从 02 拷回** |
| 关卡 Actor + Tag `PuzzleDigits` | 需在编辑器里确认是否仍摆在卧室墙/地（umap 内难扫到明文） |

材质依赖：`M_Digit_4`→`44`，`M_Digit_7`→`77`，`M_Digit_6`→`11`。拷材质后若仍粉，检查贴图引用与关卡 Element 0 是否仍挂 Unlit。

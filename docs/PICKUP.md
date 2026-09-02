# 拾取确认（键盘光标）

> 拾取 Yes/No **不用鼠标**，用左右光标 + J 确认。  
> 密码锁 **仍用鼠标**；键盘方案预留在 `docs/CODELOCK.md` 第 16 节。  
> 工程：`D:\PN2D_Level_00_04`

最后更新：2026-08-24（键盘光标已测通；展示第一版进行中：静图 + 描述）

---

## 操作

| 键 | 作用 |
|----|------|
| **A / 左** | 光标到 **Yes** |
| **D / 右** | 光标到 **No** |
| **J** | 确认（Yes 拾取 / No 关板，再靠近可再捡） |
| 鼠标 | **不出**；按钮 OnClicked 留着当备用 |

默认 **No**（2026-08-22）。已在 No 再按 D 仍停在 No；A 到 Yes。

---

## 现状（已落地）

开板：`Player Status = In Menu`；**Game Only**；**不出鼠标**。  
**不要** Ignore Move（会把 A/D 丢掉，光标切不了）。In Menu 时 Switch 本来就不 `Add Movement Input`。

关板（`DoYes` / `DoNo` 都要）：Game Only、Ignore Move 不勾、Status = **Idle**、SET 角色 `Pickup Confirm UI` = None、Remove from Parent。

J 链：Dialogue → Examine → CodeLock → **Pickup Confirm UI → ConfirmChoice** → INT OBJ。

密码锁 `ShowPanel` **不要改**。

---

## 资源

| 资源 | 改了什么 |
|------|----------|
| `BP_Cha_01` | 变量 `Pickup Confirm UI`；J 链插入 ConfirmChoice；`IA_movement` 的 **In Menu** 口切 Yes/No |
| `BP_Item_Key` | Create 后 SET `Pickup Confirm UI`；开板 Game Only、不显鼠标、In Menu；Cast 角色一次即可 |
| `WBP_PickupConfirm` | `Yes Selected`（Bool，默认 **false**）；`SetupPrompt` 末尾调 `SelectNo` + `RefreshCursor`。`SelectYes` 的 SET **必须勾 true**；`SelectNo` 的 SET 不勾 |

函数不能直接接到 Event Graph 的 OnClicked，所以 Yes/No 白线收进 `DoYes` / `DoNo`，按钮和 `ConfirmChoice` 都去调。

---

## A/D 接线（`IA_movement`）

只接 Switch 的 **`In Menu`**。idle / Walking / Running 仍接 `Add Movement Input`，不要拆。

```
In Menu
  → Is Valid (Pickup Confirm UI)
       有效 → Branch（Player Forward < -0.5）True → SelectYes
              False → Branch（Player Forward > 0.5）True → SelectNo
       无效 → 空着（对话 / 检视 / 锁）
```

两条 Select 都在 **Is Valid** 上。Not Valid 不要接 `SelectNo`。  
`< -0.5` 不要写成 `< 0.5`（松手 Forward=0 会一直当成 Yes）。

---

## 验收

| 操作 | 预期 |
|------|------|
| 靠近钥匙 J | 出板、无鼠标、不能走 |
| 默认 | **No 高亮** |
| D | No 高亮 |
| A | 回到 Yes |
| J 在 Yes | 进背包，钥匙消失，能走，Icon 没 |
| J 在 No | 关板能走，钥匙还在，Icon 回，再靠近还能捡 |
| 对话 / 检视 / 密码锁 | 不受影响 |

测 No 时先松开 A/D 再按 J。按住 D 再 J 容易误确认 No。

---

## 踩坑

| 现象 | 原因 |
|------|------|
| 能走、叠一层变暗 | 还是 UI Only，或 J 仍进钥匙 Create；Pickup 必须在 INT OBJ **前面** |
| 出板能走 | 没 SET In Menu |
| A/D 没反应 | Ignore Move 勾着；或 Select 接在 Walking 上而不是 **In Menu** |
| 选 No 后整个人不能动、键全死 | `DoNo` 没 SET **Idle**、没清空 `Pickup Confirm UI` |
| 字色看起来不变 | `RefreshCursor` 的 True / False **画成同一套颜色**（选谁谁亮） |
| PIE 突然卡死 | `IA_movement` 上每帧 Print String，测完删掉 |
| Cast ERROR | Cast 必须进白线；钥匙上 Cast 一次，SET / Hide Icons / In Menu 共用 As BP Cha 01 |
| 开板停在 No，A/D 切不到 Yes | 改默认时把 **`SelectYes` 里的 SET 勾也去掉了**。SelectYes 必须 SET true；只有变量 Default 和 SelectNo 不勾 |

---

## 展示增强（第一版）— **进行中**

参考 Asleep：上图/模型 → 中描述 → 下「Take it?」+ Yes/No。

第一版只接 **静图 + 描述**。`Display Mesh` 变量先挂上、不接线。自动旋转、Scene Capture 以后再说。

展示数据挂在拾取物上。以后栏内「调查」开新窗口时复用同一套（同一份图/描述/Mesh、同一块 `Img_Item`），不要另做检视 UI；只是没有 Take it? / Yes/No。见 `TODO.md`「后续：背包栏」。

**不要改：** Yes/No 控件名、A/D、默认 No、`SelectYes` 的 SET 勾、密码锁 `ShowPanel`、`DoYes`/`DoNo`。

### 数据（挂在 `BP_Item_Key`，Instance Editable）

| 名 | 类型 | 说明 |
|----|------|------|
| `Display Image` | Texture2D（可空） | 静图。透明 PNG；空则藏 `Img_Item` |
| `Item Description` | Text（可空） | 如 “An old key. Still usable?”；空则描述格为空 |
| `Display Mesh` | Static Mesh（可空） | **这次不接**。以后和调查共用 |
| 现有 Prompt / `In Text` | Text | “Take it?”。不要改掉 |

换钥匙文案/图：改关卡里**这把钥匙实例**的 Details，不要写死在 Widget 里。

### 步骤 1 — Designer（只加控件，不接线）

打开 `Content/Data/UMG/HUD/WBP_PickupConfirm` → **Designer**。

**不要改名、不要删：** `Prompt Text`、`Txt_Yes`、`Txt_No`、`Btn_Yes`、`Btn_No`。Yes/No **不要拖进别的父节点**。

若上次已经加过 `Img_Item` / `Txt_Desc`，跳到步骤 2。

Palette 拖到 Hierarchy，放在提示字和 Yes/No **上面**（同级 Canvas 即可）：

| 名字 | 类型 | Details |
|------|------|---------|
| `Img_Item` | Image | 勾 **Is Variable**。Draw As = **Image**（不要 Box，会出白框）。Size 大约 360×360。先不填图，或随便一张透明 PNG。Anchors 水平居中、偏上 |
| `Txt_Desc` | Text | 勾 **Is Variable**。字色可先偏黄。Auto Wrap。Justification 居中。Size 大约 720×宽、高度够两行 |

排版目标：`Img_Item` 在上，`Txt_Desc` 在中，原来的「Take it?」和 Yes/No 留在下。

`Img_Item` / `Txt_Desc` 的 **Is Focusable 不勾**（如果有这项）。

Compile → Save。把 Hierarchy 截一张（能看到新旧名字）。

### 步骤 2 — `SetupPrompt` 加两个输入

打开 `WBP_PickupConfirm` → 函数 **`SetupPrompt`**。

现有 **`In Text`** 不要删、不要改名。在 Inputs **+** 两颗：

| 名 | 类型 |
|----|------|
| `In Desc` | Text |
| `In Image` | Object Reference → **Texture2D**（可空） |

现有末尾的 **`SelectNo`** 留着，不要拆。在 **SetText（Prompt）之后、`SelectNo` 之前** 插入：

```
SetText（Target = Txt_Desc，In Text = In Desc）
  → Branch（Is Valid  In Image）
       True  → Set Visibility（Img_Item，Visible）
             → Set Brush from Texture（Target = Img_Item，Texture = In Image）
       False → Set Visibility（Img_Item，Collapsed）
  → SelectNo（原来那颗）
```

搜 **Set Brush from Texture**，不要 Set Brush from Asset。  
`Is Valid` 的对象接 **`In Image`**，不是 self。

Compile。若 `BP_Item_Key` 上 SetupPrompt 变红，去步骤 3 补针。

### 步骤 3 — `BP_Item_Key` 变量 + 开板传入

打开 `Content/Data/Interactives/Items/BP_Item_Key` → Variables **+**：

| 名 | 类型 | Details |
|----|------|---------|
| `Display Image` | Texture2D 对象引用 | 勾 **Instance Editable**；可空 |
| `Item Description` | Text | 勾 **Instance Editable**；可空 |
| `Display Mesh` | Static Mesh 对象引用 | 勾 **Instance Editable**；可空。**不要接到任何节点** |

找到 Create `WBP_PickupConfirm` 后面那颗 **`SetupPrompt`**。现有 `In Text` 针不动。补上：

- `In Desc` ← `Item Description`（self）
- `In Image` ← `Display Image`（self）

后面的 SET `Pickup Confirm UI` / Viewport / Game Only / 不显鼠标 / In Menu **不要改**。

Compile → Save。

### 步骤 4 — 关卡里填这一把钥匙

打开 `Level_00_01_P`（或钥匙所在子关卡），选中那把 `BP_Item_Key` 实例：

1. Details → `Item Description` 写一句（不要写死电池）
2. `Display Image` 拖一张 **透明 PNG** 的 Texture2D。没有图就空着，板上只出描述
3. `Display Mesh` 这次空着

Stop PIE → Play：靠近钥匙 **J**。

| 预期 | |
|------|--|
| 上有图（填了图时）/ 没图则无大图空洞 | |
| 中有描述 | |
| 下仍是 Take it? + Yes/No | |
| 默认 **No** 高亮；A/D、J 和以前一样 | |

### 踩坑（展示）

| 现象 | 原因 |
|------|------|
| 图周围白框 | `Img_Item` Draw As 用了 Box/Border；或 PNG 把棋盘格烤进图了 |
| 开板无图无字 | 改了 Class 默认，没改**关卡实例**；或 SetupPrompt 新针没接到钥匙变量 |
| SetupPrompt 编译红 | 加了输入但钥匙那边没把 `In Desc` / `In Image` 接上 |
| A/D 又没了 | 误改了 Ignore Move / UI Only / `SelectYes` 的 SET 勾 |
| 图铺满全屏 | 锚点铺满且 Offset 全 0；改成居中 + 固定 Size |

---

## 不要做（这次）

- 3D 旋转模型、Scene Capture、接线 `Display Mesh`
- 改 Yes/No 按钮 Hierarchy 名字；加 `Sel_Yes` / `Sel_No`（光标灰框以后再说）
- 密码锁改键盘 / ShowPanel
- 解锁直接进背包
- 背包 8 格 / 栏内调查（调查以后复用这套 `Img_Item`）

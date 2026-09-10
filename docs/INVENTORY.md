# 背包栏（8 格）

> 固定 8 格；从左填第一个空格；中间清空不前挤。  
> 按 I 显隐 **已测通**，改多格时不要拆。  
> 工程：`D:\PN2D_Level_00_04`

最后更新：2026-09-10（选格 + 开栏变暗 + 开栏屏蔽 J 已测通；下次栏内菜单）

---

## 操作（已有，不要改）

| 键 | 作用 |
|----|------|
| **I** | 显隐底栏。`IA_Inventory` 用 **Started**。In Menu 时忽略 |
| 开局 | 默认 **Hide**（Collapsed） |
| **A / D**（仅底栏可见时） | 高亮左/右一格；到头停住不循环。关栏后 A/D 仍是走路 |
| 开栏时 **J** | **屏蔽场景交互**（调查 / 拾取 / 门）。栏内菜单以后接在这一口，现在 True 空着 |

调查 / 使用 / Combine / 丢弃：**还没做**。

---

## 规格（已定）

`InventoryItems` = 固定 **8 格**数组，类型 **命名（Name）**。空格 = 空 Name（None）。

| 规则 | 做法 |
|------|------|
| 一直捡 → 格 1、2、3… | `AddItem` 从左找 **第一个空格** 写入 |
| 1–8 全满 | `AddItem` 失败（返回 false）；物品留在地上，不 Destroy |
| 中间某格被清掉 | 该格变空，**后面的不往前挤**；下次捡回填这个空格 |
| `HasItem` | 仍按 `ItemID` **Contains**。开门不要改成按格子号 |
| `RemoveItem` | 找到该 ID 的那一格，写成空 Name；**不要** Remove / 缩短数组 |

例：`[钥匙][电池][纸条]` → 用掉电池 → `[钥匙][空][纸条]` → 再捡手电 → `[钥匙][手电][纸条]`。

格子有图显示图（64×64），没图才显示 `Item_A`。  
满包：**已测通**。`AddItem` 失败 → 关板（不要走 `DoNo` 的 ShowPickupIcon）→ `HideInteractIcons` → `SayBagFull`。`CloseDialogue` 须先 Cast `BP_Item_Key` → `ShowPickupIcon`，再 Cast 对话/检视 → `ShowExamineIcon`（互斥）。否则关对话会错成「调查」或和「拾取」叠字。

---

## 不要改

- `ShowInventoryHUD` / `HideInventoryHUD` / `ToggleInventoryHUD` 里的 **Set Visibility** 和 **SET Inventory Visible**。Show 末尾：SET Latched **不勾** + `RefreshSlotCursor`
- `IA_movement` **Completed** 上解锁 Latched（Target = Inventory HUD）。原来 Completed 的 Set Relative Location 不要拆（用 Sequence 并行）
- `IA_Inventory` 的 **Started**；In Menu 时忽略 I
- BeginPlay 里背包 HUD 的 Create → SET → Add to Viewport → **Hide**
- 密码锁 `ShowPanel` / Hierarchy；`RefreshDigits`
- 拾取 A/D：**只动** `IA_movement` 的 Idle / Walking / Running 口。**In Menu 口一根线都不要动**（Yes/No、默认 No、`SelectYes` 的 SET 勾）
- 解锁直接 `AddItem`（`Grant Item ID`）
- 栏内菜单（调查 / 使用 / Combine / 丢弃）——下一块再做
- **不要**开栏时 SET `In Menu`（否则 I 会被忽略，关不了栏）
- **开局锁背包 / 引导按 I**：以后再做。现在 I 仍随时能开。做引导时只加开关，不要拆 `IA_Inventory` 的 Started

`DoYes` **只允许**加一颗 Branch：看 `AddItem` 的返回。其它关板逻辑不要拆。

---

## 资源

| 资源 | 职责 |
|------|------|
| `BP_Cha_01` | `InventoryItems` + `Inventory Images`（各 8 格）；`AddItem` / `HasItem` / `RemoveItem`；`TryInventoryNav`（走路口，勿接 In Menu） |
| `WBP_InventoryHUD` | 底栏；`Slot Texts` / `Slot Images` / `Slot Frames`；`RefreshInventory` 刷字+图；`Selected Slot` + `HandleInventoryNav` 选格 |
| `WBP_PickupConfirm` | `DoYes`：`In Image` ← Source Pickup 的 `Display Image`；满包则 `DoNo` + `SayBagFull` |

路径：`Content/Assests/Charactors/C_01/BP/BP_Cha_01`  
HUD：`Content/Data/UMG/HUD/WBP_InventoryHUD`

---

## 第一块：数据层 + 8 格刷新（已测通，2026-09-05）

- `InventoryItems` Resize 8；`AddItem` 填第一空格；`RemoveItem` 清格不缩短
- `WBP_InventoryHUD`：`Slot Texts` 在 Construct 里按序 Add 控件 `1`～`8`（不要加 `SizeBox_SP` 里的 `Text`）
- `RefreshInventory` **只留一套**：Cast 角色 → For Loop 0–7 → 空格 SetText 空 / 有物 To Text。旧的 For Each + `Inventory Text` **已删**
- 测通：按 I 八格空、无编号；捡钥匙后状态格右边第一格显示 `Item_A`

---

## 第一块（步骤存档）

只改数组怎么装 / 怎么删。8 个方格 UI、栏内菜单下一块。

测这一块：捡钥匙 → 按 I 仍能看到 `Item_A`；出门耗钥后门仍开、栏清空。满 8 格以后再测。

### 步骤 1 — 确认类型 + 开局拉成 8 格

打开 `BP_Cha_01` → Variables → **`InventoryItems`**。

| 项 | 必须是 |
|----|--------|
| 类型 | **命名（Name）** 的 **数组（Array）**。不要「集合 / Set」 |
| 默认 | 空数组即可（BeginPlay 会 Resize） |

若现在是 **集合**：改成数组。Compile 后 `AddItem` / `HasItem` 上的 Add / Contains 会红，步骤 2、3 会重接。

打开 Event Graph → **Event BeginPlay**。

找到背包 HUD 那一串（Create `WBP_InventoryHUD` → SET `Inventory HUD` → Add to Viewport → Hide）。  
**不要动** 这一串。

在 **Hide 之后**（有 Refresh 就放在 Refresh 之前）插入：

```
Resize Array（Target Array = InventoryItems，Size = 8）
```

搜 **Resize Array**。Size 填 **8**。  
这一步只保证长度是 8；空格是 None。

同一条 BeginPlay 里若还有 **Create `WBP_CodeLock`**（后面接 ShowPanel）：**断开**，见 `CODELOCK.md` 第 6 节。不要动背包 HUD。

Compile → Save。

### 步骤 2 — 重写 `AddItem`（找空格，返回成败）

打开函数 **`AddItem`**。

1. 现有 **`ItemID`** 输入不要删、不要改名。
2. 函数 Outputs **+** 一颗：`b Added`（Boolean）。没有 Outputs 栏就点函数名旁边的编辑。
3. **删掉** 里面的 **Add**（往数组末尾追加的那个）。不要用 Add Unique。
4. 按这个接：

```
入口
  → Branch（ItemID != None）
       False → Return（b Added = false）
       True  → For Loop（First = 0，Last = 7）
                 → Get（数组 = InventoryItems，Index = Loop Index）
                 → Branch（这一格 == None）
                      True → Set Array Elem
                               （Array = InventoryItems，
                                Index = Loop Index，
                                Item = ItemID）
                           → RefreshInventory（Target = Inventory HUD，先 Is Valid）
                           → Return（b Added = true）
                      False → 空着（继续下一格）
               For Loop 的 Completed
                 → Return（b Added = false）
```

要点：

- `Set Array Elem` 的 Array 必须是变量 **`InventoryItems`**，不是拷出来的局部数组。
- True 路的 **Return** 会跳出函数，后面的格不会再写。
- `RefreshInventory` 的 Target 是角色变量 **`Inventory HUD`**，不是 self。没有这颗调用就先不加，步骤 4 再说。
- 白线必须经过 **Set Array Elem**，不能直接 Return。

Compile。`DoYes` / 钥匙上的 `AddItem` 可能多一颗没接的 `b Added`，先不管。

### 步骤 3 — 重写 `RemoveItem`（清格，不缩短）

打开 **`RemoveItem`**（输入仍是 `ItemID`）。

**删掉** **Remove** / **Remove Item** / **Remove Index**（这些会把后面的往前挤）。

改成：

```
For Loop（0 到 7）
  → Get InventoryItems[Loop Index]
  → Branch（这一格 == ItemID）
       True → Set Array Elem（同一 Index，Item = None）
            → RefreshInventory（同步骤 2，Is Valid 后）
            → Return
       False → 空着
Completed → Return（没找到也正常）
```

`HasItem` **不要改**：仍是 `InventoryItems` → **Contains** ← `ItemID` → Return。  
Contains 在 8 格数组上照样能查 `Item_A`。不要改成按格子号。

Compile。门上现有的 `RemoveItem` / `HasItem` 不用改调用。

### 步骤 4 — `RefreshInventory` 空格不要写出 None

打开 `WBP_InventoryHUD` → **`RefreshInventory`**。

现在多半只有 **1 个** Text 格子（名字以编辑器为准，常见 `Txt_Slot` / `ItemText`）。

**这一块先只刷格 0**，不要先做 8 个 Text。

从角色取数组（现有怎么取就怎么取：Cast Pawn / 传入数组都可以）。改成：

```
Get InventoryItems 的 [0]
  → Branch（== None）
       True  → SetText（那个格子 Text，空）
       False → SetText（Name → String → Text）
```

Designer 里这个 Text 的默认字应是 **空**，不要写 `1` 当编号。  
Is Variable 勾在 **Text** 上，不是 Size Box。

`ShowInventoryHUD` / Hide / Toggle **不要动**。

Compile → Save。

### 步骤 5 — `DoYes`：满包不 Destroy

打开 `WBP_PickupConfirm` → **`DoYes`**。

找到现有那颗 **`AddItem`**（Target 是角色）。会多一颗 **`b Added`**。

在 AddItem **后面**、**Destroy**（或清 WaitingConfirm）**前面** 插入 Branch：

```
AddItem
  → Branch（b Added）
       True  → 原来的 Destroy / 关板（Idle、清空 Pickup Confirm UI、Remove）
       False → SetText（Txt_Desc，「背包已满，无法拾取。」）
               不要 Destroy，不要关板，不要 SET Idle
```

Yes/No 控件名、`SelectYes` 的 SET 勾、A/D、`DoNo` **不要改**。

Compile → Save。

---

## 这一块怎么测

Stop PIE → Compile 角色 + HUD + 拾取板 → Play。

| 操作 | 预期 |
|------|------|
| 进关 | **不要**弹出密码锁；能走 |
| 按 I | 底栏显隐还在；空栏格子是空的，不要写 `None` |
| 714 → 捡钥匙 Yes | 钥匙消失；按 I 格 0 显示 `Item_A`（或现有那一格） |
| 有钥匙出门 | 门仍开；栏清空（格 0 变空，不是整条数组没了） |
| 对话 / 检视 / 密码锁 | 不受影响 |

满 8 格拒捡：**下一块**再测（本关还没有 8 件东西）。

---

## 踩坑

| 现象 | 原因 |
|------|------|
| 进关就弹锁 | BeginPlay 还接了 Create `WBP_CodeLock`。只拆锁那一串 |
| AddItem 编译红 / 类型不匹配 | `InventoryItems` 还是集合；或 Set Array Elem 接了拷贝数组 |
| 捡了钥匙栏是空的 | 白线没经过 Set Array Elem；或 Refresh Target 不是 `Inventory HUD` |
| 栏上写着 `None` | Refresh 没判断空 Name，直接 SetText 了 [0] |
| 出门后格子变少 / 下次捡跑到末尾 | `RemoveItem` 用了 Remove，数组缩短了 |
| 按 I 打不开 | 动了 Toggle / Started；或 Hide 在 Create 之前 |
| 开拾取板 A/D 没了 | 误勾了 Ignore Move / 改了 `SelectYes` |
| Accessed None Inventory HUD | BeginPlay 须 Create→SET→再 Hide/Resize/Refresh |

---

## 第二块：选格（2026-09-09～10）

**已测通：** 开栏人不能走；关栏能走；拾取板 A/D 仍是 Yes/No；开栏 A/D 换格（看钥匙图变大/缩回）。  
菜单还没做。

### 换格外观修复（2026-09-10，已测通）

根因：`ShowInventoryHUD` 末尾 SET Latched **true**；`HandleInventoryNav` 只在 `Forward` 接近 0 时解锁。`IA_movement` **Triggered** 松手后通常不再跑，解锁永远走不到 → 每次 A/D 都被 Latched 吃掉。人站住（`b Handled` 仍是 true）但格子不动。

只改两处。不要动 In Menu 口、不要动 `TryInventoryNav` 的 Triggered 接线。

**1. `ShowInventoryHUD` 末尾：Latched 改不勾**

打开 `WBP_InventoryHUD` → `ShowInventoryHUD`。  
末尾那颗 **SET `Slot Nav Latched`**：把勾**去掉**（false）。  
`RefreshSlotCursor` 仍接在它后面，不要拆。

站住开栏后第一下 D 才能动。测的时候开栏前先松 A/D。

**2. `IA_movement` 的 Completed：松手解锁**

打开 `BP_Cha_01` Event Graph，找到已有的 **`IA_movement`**（Triggered 那颗）。  
同一颗节点上的 **Completed** 口（没有就再放一颗 `IA_movement`，只接 Completed）。  
Completed **如果已经有线，不要拆**，用 Sequence 把下面接在现有逻辑后面。

```
Completed
  → Is Valid（Inventory HUD）
       无效 → 空着
       有效 → Branch（Get Inventory Visible）
                True  → SET Slot Nav Latched（Target = Inventory HUD，不勾）
                False → 空着
```

从 **Inventory HUD** 针拖出搜 **Set Slot Nav Latched**。不要空白搜成角色自己的变量。  
不要在 Completed 上调 `HandleInventoryNav` / `TryInventoryNav`，不要 SET `Player Status`，不要碰 Switch / In Menu。

Compile 角色 + HUD → Save。

**怎么测**

Stop PIE → Play。开栏前站住、松开 A/D。

| 操作 | 预期 |
|------|------|
| 714 → 捡钥匙 → I | 第一格钥匙图略大 |
| 点一下 D | 钥匙缩回正常大小（高亮到空的格 1） |
| 再点 D | 继续右移；空格几乎看不出，以钥匙是否又变大判断是否回到格 0 |
| 点 A 回到格 0 | 钥匙再次略大 |
| 按住 D | 只跳一格 |
| 再 I 关栏 | A/D 又能走 |
| 拾取板 A/D | 仍是 Yes/No |

仍看不出：打开 `HandleInventoryNav`，确认 `Forward > 0.5` 的 **False** 有 SET Latched **不勾**。再查 `Slot Frames` 是否 8 个不同 Parent（8 张图若共用一个 Horizontal Box，循环最后会把 Scale 设回 1.0）。

---

## 第二块步骤（接线存档）

开栏用 A/D 高亮 0–7；**不** SET In Menu；**不**改拾取 In Menu 口。  
按住 A 不要连跳：用 **Latched**，松手才能再移一格。

### 不要做（本块）

菜单、调查窗口、J 开菜单、循环到头、鼠标点格。

### 步骤 1 — HUD 变量

打开 `WBP_InventoryHUD` → Variables **+**：

| 名 | 类型 | 默认 | 说明 |
|----|------|------|------|
| `Selected Slot` | Integer | **0** | 当前高亮格，0–7 |
| `Slot Nav Latched` | Boolean | **false** | 按住 A/D 只移一格 |
| `Slot Frames` | **Widget** 对象引用的 **数组** | 空 | 8 个格子的父控件（用来缩放） |

`Slot Texts` / `Slot Images` / `Inventory Visible` **不要改类型、不要清空**。

Compile。

### 步骤 2 — Construct 装满 `Slot Frames`

打开 **Event Construct**（已有给 `Slot Texts` / `Slot Images` Add 的那串）。

在 Texts/Images **都 Add 完之后**（不要插到中间、不要动现有 Add）：

```
Clear（数组 = Slot Frames）
  → For Loop（First = 0，Last = 7）
       → Get（Slot Images，Index = Loop Index）
       → Get Parent（Target = 这个 Image）
       → Add（数组 = Slot Frames，Item = Parent）
```

要点：

- `Get Parent` 搜 **Get Parent**（Widget）。Target 必须是 **Slot Images** 里那颗 Image，不要用 Text。
- Add 的数组必须是变量 **`Slot Frames`**，不是拷出来的局部数组。
- 若某格 Image 没有 Parent（极少）：那一格以后不会高亮，先把 Hierarchy 里 Image 放进 Size Box / Overlay 再 Compile。

Compile。Play 一次按 I：不应崩。还没有高亮属正常。

### 步骤 3 — 函数 `RefreshSlotCursor`

新建函数 **`RefreshSlotCursor`**（无输入）。

```
For Loop（0 到 7）
  → Get Slot Frames[Loop Index]
  → Is Valid
       False → 空着（这一格跳过）
       True  → Branch（Loop Index == Selected Slot）
                 True  → Set Render Scale（Scale = 1.15, 1.15）
                 False → Set Render Scale（Scale = 1.0, 1.0）
```

`Set Render Scale` 搜这个名字；Target 是 **Get Slot Frames** 的返回（Widget）。  
不要用 Set Render Transform 里别的，不要 Print。

Compile。

### 步骤 4 — 函数 `MoveSlotCursor`

新建函数 **`MoveSlotCursor`**。Inputs **+**：`Delta`（Integer）。

```
入口
  → SET Selected Slot
       = Clamp（Value = Selected Slot + Delta，Min = 0，Max = 7）
  → RefreshSlotCursor
```

搜 **Clamp (Integer)**。`Selected Slot + Delta` 用 **Add**（整数）。  
到头停住：格 0 再 A 仍是 0；格 7 再 D 仍是 7。不要取余循环。

Compile。

### 步骤 5 — 函数 `HandleInventoryNav`

新建函数 **`HandleInventoryNav`**。Inputs **+**：`Forward`（Float）。

这是给角色 `IA_movement` 调的。按住不连跳。

```
入口
  → Branch（Inventory Visible）
       False → Return
       True  → Branch（Forward < -0.5）          // A / 左
                 True  → Branch（Slot Nav Latched）
                          True  → 空着
                          False → MoveSlotCursor（Delta = -1）
                                → SET Slot Nav Latched = true（勾上）
                 False → Branch（Forward > 0.5）   // D / 右
                          True  → Branch（Slot Nav Latched）
                                   True  → 空着
                                   False → MoveSlotCursor（Delta = 1）
                                         → SET Slot Nav Latched = true（勾上）
                          False → SET Slot Nav Latched = false（不勾）
```

要点：

- `< -0.5` 不要写成 `< 0.5`（松手 Forward=0 会一直当成左）。
- 两个 `MoveSlotCursor` 之后都要 SET Latched **true**。
- 松手走最内层 False：只 SET Latched **false**，不要 Move。
- 不要 Print（Triggered 每帧会卡死）。

Compile → Save HUD。

### 步骤 6 — `ShowInventoryHUD` 末尾两颗

打开 **`ShowInventoryHUD`**。

**不要动** 现有的 Set Visibility、SET `Inventory Visible = true`。

在这两颗 **之后**（函数出口前）接：

```
SET Slot Nav Latched = true（勾上）
  → RefreshSlotCursor
```

开栏时若正按着 A/D 走路，Latched 可避免立刻跳一格。

`HideInventoryHUD` / `ToggleInventoryHUD` **整图不要改**（Toggle 调 Show 时会走到上面两颗）。

Compile。

### 步骤 7 — 角色：函数 `TryInventoryNav`

打开 `BP_Cha_01`。新建函数 **`TryInventoryNav`**。Outputs **+**：`b Handled`（Boolean）。

```
入口
  → Is Valid（Inventory HUD）
       False → Return（b Handled = false）
       True  → Branch（Get Inventory Visible）     // 从 Inventory HUD 拖出
                 False → Return（b Handled = false）
                 True  → HandleInventoryNav
                            Target = Inventory HUD
                            Forward = Player Forward     // 角色已有的那个 Float
                       → Return（b Handled = true）
```

`HandleInventoryNav` 搜不到时：从 **Inventory HUD** 针拖线，列表里找。  
`Player Forward` 是角色变量，和走路用的同一颗。

Compile。若 `Get Inventory Visible` 拖不出：打开 HUD 变量 `Inventory Visible`，勾 **Instance Editable**（或 Blueprint Read），再 Compile HUD → 角色。

### 步骤 8 — `IA_movement`：In Menu 先走，再拦走路

打开 `BP_Cha_01` Event Graph → **`IA_movement`**（Triggered）。

开栏后按 A/D 往往会 **SET Walking**，只拦 Idle 会漏，人照样走。  
改成：**In Menu 仍进原来的 Switch；不是 In Menu 才 TryInventoryNav。**

找到 **SET Player Forward**（Action Value 那颗）。我们的新节点必须在它 **后面**，在 Switch **前面**。

**In Menu 口里面的 SelectYes / SelectNo 一根线都不要拆**，只改 Switch 的入口白线。

原来多半是：`SET Player Forward` → `Switch on Player Status`。  
把进 Switch 的那根白线断开，改成：

```
SET Player Forward
  → Branch（Player Status == In Menu）
       True  → 仍进原来的 Switch          // 拾取 A/D 还走 In Menu 口
       False → TryInventoryNav
                 → Branch（b Handled）
                      True  → SET Player Status = Idle
                              到此结束。不要进 Switch，不要 Add Movement，不要转 Sprite
                      False → 仍进原来的 Switch   // 和平时一样走路
```

`Player Status == In Menu`：从 `Player Status` 拖线搜 **Equal (Enum)**，另一侧选 **In Menu**。不要手勾 Branch。

要点：

- Switch **本身不要删**。In Menu / Idle / Walking / Running 口原来接什么还接什么。
- `b Handled` 的 **True 不要再接到 Switch**，也不要用 Sequence 同时走路。
- True 口 SET Idle：避免开栏时还在播走动画。
- 不要开栏 SET In Menu。

Compile → Save。

### 这一块怎么测

Stop PIE → Compile HUD + 角色 → Play。测时开栏前先松 A/D、站住。

| 操作 | 预期 |
|------|------|
| 进关，不按 I | 能走；**不要**弹出密码锁 |
| 按 I | 底栏出现；**格 0（状态圆标右边第一格）略放大** |
| 开栏按 D | 高亮右移一格；人**不动**、不转向 |
| 开栏按住 D | **只跳一格**，不会连滑到格 7 |
| 松 D 再按 D | 再右移一格 |
| 开栏连按 D 到头 | 停在格 7，再 D 仍是 7 |
| 开栏按 A | 左移；格 0 再 A 仍是 0 |
| 再按 I 关栏 | 底栏藏；A/D **又能走** |
| 关栏后转向 | 和以前一样 |
| 靠近钥匙出拾取板，A/D | **仍是 Yes/No**，不是移格；默认仍是 No |
| 对话 / 检视 / 密码锁 | 不受影响；I 在这些板开着时仍忽略 |

### 踩坑（选格）

| 现象 | 原因 |
|------|------|
| 开栏人站住但 A/D 看不出换格 | Show 的 Latched 吃掉第一下；或下一格是空的看不出（看钥匙是否缩小）；或 `> 0.5` False 没解锁 Latched |
| 开栏 A/D 仍走路 | 只拦了 Idle：按 A 会进 **Walking** 口照走。应按步骤 8 在 Switch **前**拦。或 `b Handled` True 仍接 Add Movement / 用了 Sequence。或 `Inventory Visible` 为 false |
| 关栏后不能走 | 误开栏 SET 了 In Menu，或 True 口和 False 口接反 |
| 按 I 关不了栏 | 开栏时 SET 了 In Menu（I 在 In Menu 被忽略）。**不要**用 In Menu 挡走路 |
| 按住 D 格子连飞 | 没走 Latched，或 Move 接在 Latched 的 True 口 |
| 松手还在往右跳 | `< -0.5` 写成了 `< 0.5`；或松手没 SET Latched false |
| 拾取板 A/D 没了 / 切到背包格 | 动了 **In Menu** 口，或 `TryInventoryNav` 接在 In Menu 上 |
| 没有任何格子变大 | `Slot Frames` 没在 Construct 里 Add；Get Parent 接错成 Text；RefreshSlotCursor 没在 Show 末尾调 |
| 只有有字/有图的格会变大 | 正常一点：空 Image 的 Parent 仍应能 Scale。若完全没变化，查 Size Box 是否 Override 了 Transform |
| PIE 卡死 | `IA_movement` 上每帧 Print String |
| 开栏瞬间跳一格 | Show 末尾没 SET Latched true（开栏时还按着 D） |

### 选中格亮度（2026-09-10，已测通）

Scale + Opacity 须打在格子 **Border** 上（`Slot Frames[i]` = Overlay → **Get Parent**）。只打 Overlay 时空格没有像素，几乎看不见。Construct 装 Slot Frames 的那串不要改。

| 口 | Scale | Opacity |
|----|-------|---------|
| 选中 | 约 **1.5** | **1.0** |
| 其它 | 1.0 | **0.55** |

空格能看出框；有图的格放大 + 旁边压暗。

---

## 开栏全屏变暗（2026-09-10，已测通）

抄检视 / 密码锁的 `Img_Dim`。只改 `WBP_InventoryHUD` Designer。  
**不要** SET `In Menu`，**不要**改 `ShowInventoryHUD` / Hide / Toggle 接线。遮罩是 HUD 的子控件，随 self 显隐。

Hierarchy：`Canvas Panel` → **`Img_Dim`（最前）** → 原来的底栏 `Border`。  
`Img_Dim` 用 **Border**，不要空 Image。Anchors 铺满，Offset 全 0。Draw As = Box / Rounded Box。Tint 黑 **A≈0.6**。底栏 Border **ZOrder = 1**。

## 开栏屏蔽 J（2026-09-10，已测通）

`BP_Cha_01` 的 `IA_Interactive` **最前面**：Is Valid（Inventory HUD）→ Branch（Inventory Visible，Target = HUD）。  
True 空着（以后接栏内菜单）；False / 无效仍进原来的 Dialogue → Examine → CodeLock → Pickup → INT OBJ。  
不要 SET `In Menu`。关栏后 J 恢复场景交互。

## 以后：开局锁背包 + 引导按 I（已记，先不做）

开局 **不允许** 按 I 开栏。场景里触发引导提示之后，才把开栏解开。

| 项 | 定什么 |
|----|--------|
| 锁的是什么 | **只锁按 I 开栏**。捡东西进 `InventoryItems` 照旧（钥匙仍可捡） |
| 开关 | 角色上 Bool，如 `Inventory Unlocked`，默认 **false** |
| 开锁 | 引导触发器 / 提示播完后 SET **true**。只 SET 一次 |
| 按 I | `IA_Inventory` Started：In Menu 忽略（已有）→ 再看 Unlocked，false 则 Return，true 才 Toggle |
| **第一次开栏** | 玩家**第一次真正打开**底栏后，再提示：**A / D 左右换格**。只出一次 |
| 不要 | 不要用 In Menu 当这把锁；不要 Disable Input；不要拆 Started / Show / Hide |

**当前选格外观（已测通）：** 打在格子 **Border** 上。选中放大约 **1.5** + Opacity **1.0**；其它 Scale **1.0**、Opacity **0.55**。空格也能看出框。

现在开发阶段 I 保持随时能开，方便测背包。做引导时再加这颗 Branch。

---

## 下一块（选格测通后再做）

栏内菜单壳：选中**有物**的格按 J → 调查 / 使用 / Combine / 丢弃。空格 J 无菜单。丢弃只留口。调查复用拾取板图/描述，不要 Yes/No。

规格全文也在 `docs/TODO.md`「后续：背包栏」。

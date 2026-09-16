# 背包栏（8 格）

> 固定 8 格；从左填第一个空格；中间清空不前挤。  
> 按 I 显隐 **已测通**，改多格时不要拆。  
> 工程：`D:\PN2D_Level_00_04`

最后更新：2026-09-15（手电改为拾取进左边圆格，不进 8 方格）

---

## 操作（已有，不要改）

| 键 | 作用 |
|----|------|
| **I** | 显隐底栏。`IA_Inventory` 用 **Started**。In Menu 时忽略 |
| 开局 | 默认 **Hide**（Collapsed） |
| **A / D**（仅底栏可见时） | 高亮左/右一格；第 8 格再 D 回第 1 格，第 1 格再 A 回第 8 格。关栏后 A/D 仍是走路 |
| 开栏时 **J** | 有物：开栏内菜单 / 菜单里确认。空格：无菜单。关栏后 J 才是场景交互 |
| 菜单打开时 **A / D** | 上下一项（Examine → Use → Combine → Discard）；不再换格 |
| **I** | 关栏时顺便关菜单 / 调查窗 |
| 调查开着时 **J** | 关调查窗，回到底栏；不要 Yes/No |

栏内调查正文来自钥匙 **`Examine Body`**（不是 `Item Description`）。`Item Description` 只给拾取 Yes/No 板。标题走 **`Examine Title`** → `SetupExamine` 的 `In Title`。

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

例：`[钥匙][电池][纸条]` → 用掉电池 → `[钥匙][空][纸条]` → 再捡 → `[钥匙][新物][纸条]`。手电不进这 8 格。

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
- 栏内菜单 Graph 未写前不要改 J 的 True 口；第三块只往 True 口接 `HandleInventoryJ`
- **不要**开栏时 SET `In Menu`（否则 I 会被忽略，关不了栏）
- **开局锁背包 / 引导按 I**：以后再做。现在 I 仍随时能开。做引导时只加开关，不要拆 `IA_Inventory` 的 Started
- **手电在左边圆格**：已记。不占 8 个方格；菜单壳不要改 `AddItem` / 选格 0–7

`DoYes` **只允许**加一颗 Branch：看 `AddItem` 的返回。其它关板逻辑不要拆。

---

## 资源

| 资源 | 职责 |
|------|------|
| `BP_Cha_01` | `InventoryItems` + `Inventory Images` + `Inventory Descs`（各 8 格）；`AddItem` / `HasItem` / `RemoveItem`；`TryInventoryNav`（走路口，勿接 In Menu） |
| `WBP_InventoryHUD` | 底栏；`Slot Texts` / `Slot Images` / `Slot Frames`；`RefreshInventory` 刷字+图；`Selected Slot` + `HandleInventoryNav` 选格；调查窗引用 `Inv Examine UI` |
| `WBP_PickupConfirm` | `DoYes`：`In Image` ← `Display Image`；`In Title` ← `Examine Title`；`In Desc` ← `Examine Body`。`SetupPrompt` 的 `In Desc` 仍是 `Item Description`。满包则 `DoNo` + `SayBagFull`。栏内调查**不要**开这张板 |
| `WBP_ExaminePanel` | 场景检视已测通；栏内调查同一套：左 `Img_Item`、右标题+正文、`J 返回`。**不要**调 `ShowPanel`（会 SET In Menu） |

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

**2026-09-15 改为循环：** 不要再用 Clamp 停住。`MoveSlotCursor` 里 `Selected Slot + Delta` 之后：`> 7` 写成 **0**，`< 0` 写成 **7**。第 8 格 D → 第 1 格；第 1 格 A → 第 8 格。不要改 `MoveSlotMenuCursor`。

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

## 第三块：栏内菜单壳（2026-09-10，**已测通**）

选中**有物**的格按 J → 弹出四项。空格 J 什么都不做。  
壳已通：能开、能关、A/D 换项、开着不换格。调查出图 / 使用 / Combine / 丢弃 **下一块**。

**踩坑：** `HandleSlotMenuNav` 的 `<` / `>` 上面必须接 **`Forward`**，不要写死 0.0。松手那条 SET `Slot Menu Latched` **不勾**。Show 末尾 Latched **不勾**。Completed 上 SET Menu Latched false（Target = HUD）。

接在已有的 J True 口（Inventory Visible）上。**不要** SET `In Menu`（否则 I 关不了栏）。不要改拾取 In Menu 口。

### 不要做（本块）

- 调查窗口、复用拾取板、Yes/No
- 使用 / Combine / 丢弃的实际效果（函数可以空着）
- 开局锁背包、引导
- 新 Widget Blueprint（菜单做在现有 `WBP_InventoryHUD` 里）

### 操作（本块测完应是）

| 操作 | 预期 |
|------|------|
| 空格按 J | 无菜单 |
| 有钥匙的格按 J | 底栏上方出现：Examine / Use / Combine / Discard；默认高亮 **Examine** |
| 菜单开着按 A / D | 高亮上下移；格子光标**不动** |
| 菜单开着按 J | 关菜单（对应项只进空函数，不崩） |
| 菜单开着按 I | 栏和菜单一起没；A/D 又能走 |
| 关栏后靠近门 / 钥匙按 J | 仍是场景交互 |

### Designer（`WBP_InventoryHUD`）

在底栏 **Border** 上面加（和格子平级、不要进 Horizontal Box）：

```
VB_SlotMenu          Vertical Box；默认 Collapsed
  Txt_Menu_0         「Examine」
  Txt_Menu_1         「Use」
  Txt_Menu_2         「Combine」
  Txt_Menu_3         「Discard」
```

四个 Text 都勾 **Is Variable**。锚在底栏上方（先屏幕底部居中即可，不必精确钉在选中格上）。  
四个 **Add 进数组 `Slot Menu Texts`**：Construct 里现有 Slot Images / Slot Frames 那串**不要拆**，在后面再 Clear + Add `Txt_Menu_0`～`3`。

### 变量（HUD）

| 名 | 类型 | 默认 | 说明 |
|----|------|------|------|
| `Slot Menu Visible` | Boolean | false | 菜单是否开着 |
| `Slot Menu Index` | Integer | 0 | 0 Examine / 1 Use / 2 Combine / 3 Discard |
| `Slot Menu Latched` | Boolean | false | 按住 A/D 只移一项 |
| `Slot Menu Texts` | Text 对象引用 **数组** | 空 | Construct 装 4 个菜单字 |

`Selected Slot` / `Slot Nav Latched` / `Inventory Visible` **不要改类型**。

### 函数（HUD）

都建在 `WBP_InventoryHUD`。无特殊说明就不要 Outputs。

**1. `IsSelectedSlotEmpty` → `b Empty`（Boolean）**

```
Get Owning Player Pawn → Cast BP_Cha_01
  失败 → Return（b Empty = true）
  成功 → Get InventoryItems[Selected Slot]
       → Return（这一格 == None）
```

**2. `RefreshSlotMenuCursor`**

```
For Loop 0–3
  Get Slot Menu Texts[i]
  Is Valid
    True → Branch（i == Slot Menu Index）
             True  → Set Render Opacity 1.0
             False → Set Render Opacity 0.45
```

不要 Print。

**3. `ShowSlotMenu`**

```
SET Slot Menu Index = 0
  → SET Slot Menu Visible = true
  → SET Slot Menu Latched = false
  → Set Visibility（VB_SlotMenu = Visible）
  → RefreshSlotMenuCursor
```
开菜单 Latched **不勾**（和 Show 底栏一样）。勾上会吃掉第一下 A/D。

**4. `HideSlotMenu`**

```
SET Slot Menu Visible = false
  → SET Slot Menu Latched = false
  → Set Visibility（VB_SlotMenu = Collapsed）
```

**5. `MoveSlotMenuCursor`** Inputs：`Delta`（Integer）

```
SET Slot Menu Index = Clamp(Index + Delta, 0, 3)
  → RefreshSlotMenuCursor
```

到头停住，不循环。

**6. `HandleSlotMenuNav`** Inputs：`Forward`（Float）

和 `HandleInventoryNav` 同一套 Latched：

```
Branch（Slot Menu Visible）
  False → Return
  True  → Forward < -0.5 → 未锁则 MoveSlotMenuCursor(-1)，SET Latched true
          Forward > 0.5  → 未锁则 MoveSlotMenuCursor(+1)，SET Latched true
          否则 SET Latched false
```

**7. `InvActionExamine` / `InvActionUse` / `InvActionCombine` / `InvActionDiscard`**

四个空函数，无输入。本块 **只 Return**。不要 Destroy、不要 RemoveItem。

**8. `ConfirmSlotMenu`**

```
Switch on Slot Menu Index
  0 → InvActionExamine
  1 → InvActionUse
  2 → InvActionCombine
  3 → InvActionDiscard
然后（四路都接到）HideSlotMenu
```

**9. `HandleInventoryJ`**

```
Branch（Slot Menu Visible）
  True  → ConfirmSlotMenu
  False → Branch（IsSelectedSlotEmpty）
            True  → 空着
            False → ShowSlotMenu
```

### 函数（角色，改现有）

**`TryInventoryNav`**（已有，只加一口）：

```
Inventory Visible == true 之后、HandleInventoryNav 之前：
  Branch（Get Slot Menu Visible）
    True  → HandleSlotMenuNav（Forward = Player Forward）
          → Return b Handled true
    False → 原来的 HandleInventoryNav
```

**`IA_Interactive` 的 True 口**（Inventory Visible，现在空着）：

```
True → HandleInventoryJ（Target = Inventory HUD）
```

不要接到 INT OBJ。

**`HideInventoryHUD`** 末尾加一颗 **`HideSlotMenu`**（现有 Set Visibility / SET Inventory Visible **不要拆**）。开着菜单按 I 才不会留下字。

**`IA_movement` Completed** 里现有的 SET Slot Nav Latched false 旁边，同样 SET **Slot Menu Latched** false（Target 都是 HUD）。否则菜单 A/D 会锁死，和选格同一原因。

### 调查（第四块）

`InvActionExamine`：走 **`WBP_ExaminePanel`**（左图右文、J 返回）。**不要 Yes/No**。图用 `Display Image`；标题/正文用 `Examine Title` / `Examine Body`。拾取短描述仍是 `Item Description`。步骤见文末「第四块」。

### 能用 / 不能用（已记，菜单壳先仍显示四项）

不要在菜单里写死 `Item_A`。钥匙开门仍走场景 J + `HasItem`，**不等于**栏内「使用」。

| 类型 | 菜单 | 默认（钥匙实例） | 例子 |
|------|------|------------------|------|
| **特殊物** | 只有 **调查 / 合成**。没有使用、没有丢弃 | `b Can Use` **不勾**；`b Can Discard` **不勾** | 钥匙、关卡关键物 |
| **一般物** | **调查 / 使用 / 合成 / 丢弃** 都有 | 两颗都勾上 | 药剂、电池 |

`AddItem` 把两颗 Bool 写入角色 `Inventory Can Use` / `Inventory Can Discard`（各 Bool×8），和 `Inventory Images` 同一格。  
第五块起按开关 **藏掉** 没有的项（不要只偏暗占着 A/D）。丢弃清的是**当前格**，不要走 `RemoveItem`（按 ID 会清错格）。不扔回场景。新道具只改实例 Details。

手电在左边圆格：可使用、不能丢，不进这 8 格。

### 手电 = 左边圆格（已记，菜单壳不要接）

你圈的那格：底栏**最左圆标**。右边 8 个白方格仍是拾取栏，**不是**手电。

| 项 | 定什么 |
|----|--------|
| 位置 | 圆格单独一块 UI，不进 `InventoryItems[0]` |
| 获得 | **场景捡**进圆格，不走 `AddItem`。不要 Duplicate 钥匙（Cast 会失败）；用 **Child** |
| 8 方格 | `AddItem` 仍从方格 0 填到 7。钥匙仍进**第一个方格** |
| 一直在 | 圆格不能丢、不能被捡来的东西盖掉 |
| `L` | 开局不能用。捡进圆格、`b Has Flashlight` 为 true 之后才走现有 `IA_Flashlight`。**不要拆** In Menu 判断 |
| 光标 | 以后 A/D 最左停在圆格，再 D 才到第一个方格。**现在**选格仍是方格 0–7 |

**2026-09-16 晚上停在这里：**

已接：

- 圆格 `SizeBox_SP` 已拖到 **Canvas** 与底栏 `Border` 平级（不在 8 格 HB 里）。圆：`Border_7` Rounded Box，半径为边长一半
- 捡手电进圆格、钥匙进方格仍通
- 菜单外框 **`Border_SlotMenu`**（Is Variable）：Canvas 直属，里面 `VB_SlotMenu` 四行字。Show/Hide 打 **Border** Visible/Collapsed；`VB_SlotMenu` 保持 Visible。`PlaceSlotMenuOverSelected` 的 Slot as Canvas Slot / Set Position 打 **Border_SlotMenu**（打 VB 会 Accessed None）
- 临时黑底：Border Brush Draw As Rounded Box，Tint 黑，不要贴图。X 微调：Make Vector 的 Add 第三口 ±10；Alignment 已是 0.5 / 1.0 不要改
- **菜单里头像：先不加**（可独立于格子，以后再说）

未做：

| 项 | 说明 |
|----|------|
| 开局锁 `L` | `IA_Flashlight` 最前 `b Has Flashlight`，False Return。In Menu 不要拆 |
| 菜单字有时被藏 | Hide 不要 Collapsed `VB_SlotMenu`；Show 可再 Visible 一次 VB |
| 使用 / Combine | 仍空 |

不要 SET In Menu。不要改 `AddItem`。A/D 选中圆格以后再说。

---

## 第三块步骤（接线）

一次一块。**不要** SET `In Menu`，不要改拾取 In Menu 口，不要改 `AddItem`。

### 不要改

- `Img_Dim`、底栏 Border、格子 Horizontal Box、`Slot Texts` / `Slot Images` / `Slot Frames` 现有 Construct
- `ShowInventoryHUD` 的 Set Visibility / SET Inventory Visible / Latched 不勾
- `IA_movement` Triggered 的 In Menu 口；Completed 上现有 SET Slot Nav Latched **不要拆**（后面只在旁边加一颗）
- 密码锁、拾取板

### 步骤 1 — Designer：加 `VB_SlotMenu`

打开 `WBP_InventoryHUD` → **Designer**。

Hierarchy 现在应是：`Canvas Panel` → `Img_Dim` → 底栏 `Border`（里面才是格子）。

Palette 拖 **Vertical Box** 到 Hierarchy 的 **`Canvas Panel` 名字上**（不要进 `Img_Dim`，不要进底栏 Border，不要进格子 Horizontal Box）。  
改名为 **`VB_SlotMenu`**。

Canvas Slot：

| 项 | 值 |
|----|-----|
| Anchors | 底中（九宫格最下一排中间；Min 0.5,1 / Max 0.5,1） |
| Alignment | X **0.5**，Y **1.0**（往上长） |
| Position X | **0** |
| Position Y | **-140**（先悬在底栏上方；被挡住再改） |
| Size X / Y | **200** / **160** |
| ZOrder | **2**（要比 `Img_Dim` 和底栏高） |

Details → Behavior → **Visibility = Collapsed**。

再 Pallete 拖 **Text** 到 Hierarchy 的 **`VB_SlotMenu` 名字上**，做四个。每个都勾 **Is Variable**。

| 名 | Text |
|----|------|
| `Txt_Menu_0` | Examine |
| `Txt_Menu_1` | Use |
| `Txt_Menu_2` | Combine |
| `Txt_Menu_3` | Discard |

字色白（Color 1,1,1,1）；字号约 **24**；Justification 居中。Vertical Box Slot Padding Bottom 约 **4**。

### 菜单对齐当前格（壳通了再做）

第三块先钉在屏幕底中。要对齐选中方格：改锚点 + `ShowSlotMenu` 末尾调一次位置。手电圆格以后再说。

**Designer：** 点 `VB_SlotMenu`。Anchors 改成 **左上角一个点**（Min 0,0 / Max 0,0）。Alignment 仍是 X **0.5**、Y **1.0**（以菜单底边中点为轴，往上长）。ZOrder 2 不要改。

根 `Canvas Panel` 勾 **Is Variable**（若还没有）。

**函数 `PlaceSlotMenuOverSelected`**（HUD，无输入）：

```
Get Slot Frames[Selected Slot]
  → Is Valid
       False → Return
       True  → Get Cached Geometry（格子）
            → Absolute Pos = Get Absolute Position
            → Size = Get Local Size
            → 中心上方 = Absolute Pos + (Size.X * 0.5, 0)
            → CanvasGeom = Get Cached Geometry（Canvas Panel）
            → Local = Absolute To Local（Geometry = CanvasGeom，Absolute = 中心上方）
            → Slot as Canvas Slot（VB_SlotMenu）→ Set Position
                 X = Local.X
                 Y = Local.Y - 8
```

`ShowSlotMenu` 在 Set Visibility **Visible 之后**、Refresh **之前**（或之后）调 `PlaceSlotMenuOverSelected`。格子几何一直有效，不必 Delay。

Compile。测：选格 0 出菜单应在钥匙上方；D 换到空格再 J，菜单应跟着那一格。开着菜单 A/D 只换项，菜单位置不用跟着动。

Compile。Designer 里能看到四行字属正常（Collapsed 在编辑器里仍会画）。**不要** Play 测菜单，现在还没有 Graph。

### 步骤 2 — HUD 变量

`WBP_InventoryHUD` → Variables **+**：

| 名 | 类型 | 默认 |
|----|------|------|
| `Slot Menu Visible` | Boolean | **false** |
| `Slot Menu Index` | Integer | **0** |
| `Slot Menu Latched` | Boolean | **false** |
| `Slot Menu Texts` | **Text** 对象引用的 **数组** | 空 |

`Slot Menu Visible` 勾 **Instance Editable**（或 Blueprint Read），角色以后要 Get。  
`Selected Slot` / `Slot Nav Latched` / `Inventory Visible` **不要改类型、不要清空**。

Compile → Save HUD。

### 步骤 3 — Construct 装满 `Slot Menu Texts`

打开 **Event Construct**。现有给 `Slot Texts` / `Slot Images` / `Slot Frames` Add 的那串 **一根都不要拆、不要插到中间**。

接到**最后一根白线后面**（Slot Frames 那个 For Loop 的 Completed 之后；没有 Completed 就接在最后一颗 Add 后面）：

```
Clear（数组 = Slot Menu Texts）
  → Add（数组 = Slot Menu Texts，Item = Txt_Menu_0）
  → Add（Item = Txt_Menu_1）
  → Add（Item = Txt_Menu_2）
  → Add（Item = Txt_Menu_3）
```

顺序必须是 0、1、2、3。Add 的数组必须是变量 **`Slot Menu Texts`**，Item 从变量面板拖对应 Text，不要用 Slot Texts 里的格子。

Compile。

### 步骤 4 — 四个空函数

`WBP_InventoryHUD` 新建，无输入、无输出，图里只有 **Return**：

- `InvActionExamine`
- `InvActionUse`
- `InvActionCombine`
- `InvActionDiscard`

不要 Destroy、不要 RemoveItem、不要 Print。Compile。

### 步骤 5 — `IsSelectedSlotEmpty`

新建函数。Outputs **+**：`b Empty`（Boolean）。

```
Get Owning Player Pawn
  → Cast To BP_Cha_01
       失败 → Return（b Empty = true）
       成功 → Get（数组 = InventoryItems，Index = Selected Slot）
            → Return（这一格 == None）
```

`InventoryItems` 从 **Cast 成功的角色**拖出，不要用 HUD self。`Selected Slot` 是 HUD 自己的整数。  
Name 空 = **None**（Equal (Name)）。

Compile。

### 步骤 6 — `RefreshSlotMenuCursor`

新建函数，无输入。

```
For Loop（First = 0，Last = 3）
  → Get（Slot Menu Texts，Index = Loop Index）
  → Is Valid
       False → 空着
       True  → Branch（Loop Index == Slot Menu Index）
                 True  → Set Render Opacity（1.0）
                 False → Set Render Opacity（0.45）
```

`Set Render Opacity` 的 Target 是 **Get 出来的那颗 Text**。不要 Print。

Compile。

### 步骤 7 — `ShowSlotMenu` / `HideSlotMenu`

**`ShowSlotMenu`：**

```
SET Slot Menu Index = 0
  → SET Slot Menu Visible = true（勾上）
  → SET Slot Menu Latched = false（不勾；勾上会吃掉第一下 A/D）
  → Set Visibility（Target = VB_SlotMenu，Visible）
  → RefreshSlotMenuCursor
```

**`HideSlotMenu`：**

```
SET Slot Menu Visible = false（不勾）
  → SET Slot Menu Latched = false（不勾）
  → Set Visibility（Target = VB_SlotMenu，Collapsed）
```

Set Visibility 的 Target 必须是 **`VB_SlotMenu`**，不要 self（self 会把整条底栏藏掉）。

Compile → Save HUD。

还不要接角色 J、不要 Play 测菜单。下一步才是 `MoveSlotMenuCursor` / `HandleSlotMenuNav` / `ConfirmSlotMenu` / `HandleInventoryJ`。

---

## 第四块：调查出图（2026-09-11，**已测通**）

选中有物的格 → J 出菜单 → 停在 Examine 再 J → **和墙上纸条同一套检视板**：左图、右描述、`1/1`、**J 返回**。没有 Yes/No。再 J 关窗，底栏还在。

使用 / Combine / 丢弃仍空。不要新建 Widget。不要开 `WBP_PickupConfirm` 做调查（那是捡东西的）。

若已经按上一版在拾取板上建了 `SetupExamineView`：**删掉或不要调**，改走 `WBP_ExaminePanel`。

### 不要改

- `WBP_ExaminePanel` 的 **`ShowPanel` / `CloseExamine` / `SetupExamine` 内部**、Hierarchy、`HandleExamine`
- `IA_movement` 的 **In Menu** 口（SelectYes / SelectNo）
- `SelectYes` 的 SET **勾**；`SetupPrompt` 内部
- `DoYes` 的 Branch / Destroy / 满包对话（只给 `AddItem` 补一针 `In Desc`）
- 密码锁 `ShowPanel` / Hierarchy
- `PlaceSlotMenuOverSelected`（已测通）
- 不要 SET `In Menu`；不要 Ignore Move
- 不要 SET 角色 **`Examine UI`**（否则会走场景 `CloseExamine`，Icon / Idle 会乱）
- 不要 SET 角色 **`Pickup Confirm UI`**
- `InvActionUse` / `Combine` / `Discard` 仍只 Return

### 操作（本块测完应是）

| 操作 | 预期 |
|------|------|
| 714 → 捡钥匙 → I → 格 0 J → Examine 再 J | **左**钥匙图，**右**描述（捡时那句）；无 Yes/No；底下有 J 返回 |
| 调查开着再 J | 窗关掉，底栏还在，菜单不要自动再开 |
| 调查开着 A / D | 格子**不动** |
| 调查开着 I | 栏和窗一起没；A/D 又能走 |
| 关栏后靠近钥匙 J | 仍是拾取 Yes/No，默认 No |
| 靠近墙上纸条 J | 场景检视仍和以前一样 |

### 步骤 1 — 角色：`Inventory Descs` + Resize

打开 `BP_Cha_01` → Variables **+**：

| 名 | 类型 | 默认 |
|----|------|------|
| `Inventory Descs` | **Text** 的 **数组** | 空 |

不要改 `InventoryItems` / `Inventory Images` 类型。

Event BeginPlay：找到已有的 **Resize** `InventoryItems`（Size=8）。旁边再一颗 Resize：

```
Resize Array（Target Array = Inventory Descs，Size = 8）
```

`Inventory Images` 若已经有 Resize 8，不要拆；Descs 跟它并列即可。

Compile。

### 步骤 2 — `AddItem` 加 `In Desc`

打开 **`AddItem`**。现有 **`ItemID`**、写图那针（常见名 **`In Image`**）不要改名、不要删。

函数 **Inputs +**：`In Desc`（Text）。必须是 **Inputs**，不要加成 Outputs。

找到写入 `InventoryItems` / `Inventory Images` 的那两颗 **Set Array Elem**（同一个 Loop Index，True 路、Return 之前）。旁边再一颗：

```
Set Array Elem
  Array = Inventory Descs
  Index = 同一颗 Loop Index
  Item = 入口针 In Desc
```

白线必须经过这颗。满包那条 False / Completed **不要**写 Descs。

Compile。`DoYes` 上 `AddItem` 会多一颗没接的 `In Desc`，下一步接。

### 步骤 3 — `RemoveItem` 清描述

打开 **`RemoveItem`**。找到清 `InventoryItems` 那颗 Set Array Elem（Item = None）。同一 Index 再清：

```
Set Array Elem（Inventory Descs，同一 Index，Item = 空 Text）
```

`Inventory Images` 若已经在这里清成 None，不要拆。不要用 Remove 缩短数组。

Compile。

### 步骤 4 — `DoYes` 只补一针

打开 `WBP_PickupConfirm` → **`DoYes`**。

现有 `AddItem`：**不要**改 Branch / Destroy。把新针接上：

```
In Desc ← Source Pickup 的 Item Description
```

`In Image` 仍接 `Display Image`。ItemID 不要改。

Compile → Save 拾取板 + 角色。钥匙实例 Details 里 `Item Description` / `Display Image` 本来就有，不用改文案。

### 步骤 5 — 检视板：只加 `ShowExamineView`

打开 `WBP_ExaminePanel`（`Content/Data/UMG/Examine/`）。

**不要动** `ShowPanel`、`CloseExamine`、`SetupExamine` 里已有的节点（场景纸条靠它们）。

新建函数 **`ShowExamineView`**（无输入）：

```
Set Visibility（Target = Canvas Panel，Visible）
```

只这一颗。不要 Ignore Move，不要 SET In Menu，不要 HideInteractIcons，不要鼠标 / UI Only。

`Canvas Panel` 须勾 **Is Variable**（`ShowPanel` 已经能设它，一般已勾）。

Compile → Save 检视板。

### 步骤 6 — HUD：`Inv Examine UI` + 开关

打开 `WBP_InventoryHUD` → Variables **+**：

| 名 | 类型 | 默认 |
|----|------|------|
| `Inv Examine UI` | **`WBP_ExaminePanel`** 对象引用 | None |

不要改 `Slot Menu Visible` / `Selected Slot`。若误加成了 `WBP_PickupConfirm`，改类型后 Compile。

**函数 `HideInvExamine`**（无输入）：

```
Is Valid（Inv Examine UI）
  False → Return
  True  → Remove from Parent（Target = Inv Examine UI）
        → SET Inv Examine UI = None
```

不要调 `CloseExamine`（那会 SET 角色 `Examine UI` / Idle）。不要 SET `Pickup Confirm UI`。

打开已有空函数 **`InvActionExamine`**，删掉光 Return，改成：

```
HideInvExamine
  → Get Owning Player Pawn → Cast BP_Cha_01
       失败 → Return
       成功 → Create Widget（Class = WBP_ExaminePanel，Owning Player = Get Player Controller Index 0）
            → SET Inv Examine UI = Create Return
            → SetupExamine
                 Target = Create Return
                 In Title = 空
                 In Body  = Get Inventory Descs[Selected Slot]（数组从 Cast 角色拖）
                 In Image = Get Inventory Images[Selected Slot]
            → Add to Viewport（Target = Create Return，ZOrder = 10）
            → ShowExamineView（Target = Create Return）
```

要点：

- `In Title` / `In Body` / `In Image` 是 **`SetupExamine` 的入口针**，不要用 Widget 变量
- 第一版标题空，右侧正文走描述。模型以后再接 `Display Mesh`
- Get 数组的 Target 是 **Cast 成功的角色**，Index 是 HUD 的 `Selected Slot`
- **不要**调 `ShowPanel`（会 SET In Menu + Ignore Move，I 关不了栏、A/D 会进拾取口）
- **不要** SET 角色 `Examine UI` / `Pickup Confirm UI`

`ConfirmSlotMenu` 不用改：0 口已经接 `InvActionExamine`，然后四路仍进 `HideSlotMenu`。

Compile → Save HUD。

### 步骤 7 — J / I / A/D 三口

**`HandleInventoryJ`** 最前面加一口（现有 Slot Menu Visible 那颗 Branch **不要拆**，整坨接到新 Branch 的 False）：

```
Is Valid（Inv Examine UI）
  True  → HideInvExamine
  False → 原来的 Branch（Slot Menu Visible）→ Confirm / 空格 / ShowSlotMenu
```

调查开着时 J 只关窗，不要再 `ShowSlotMenu`。

**`HideInventoryHUD`** 末尾：现有 `HideSlotMenu` 旁边再调 **`HideInvExamine`**。Set Visibility / SET Inventory Visible **不要拆**。开着调查按 I 才不会留下板。

**`TryInventoryNav`**：现有 `Slot Menu Visible` 的 True 口（`HandleSlotMenuNav`）不要拆。在这颗 Branch 的 **False** 上、`HandleInventoryNav` **之前**插入：

```
Is Valid（Inv Examine UI）
  True  → Return（b Handled = true）     // 调查开着 A/D 不换格
  False → 原来的 HandleInventoryNav
```

不要 SET In Menu。不要改 `IA_movement` 的 In Menu 口。

Compile 角色 + HUD + 检视板 + 拾取板 → Save。

### 这一块怎么测

Stop PIE → Compile 角色 + HUD + `WBP_ExaminePanel` + 拾取板 → Play。钥匙实例须有 `Display Image` 和 `Item Description`。

| 操作 | 预期 |
|------|------|
| 714 → 捡 Yes → I → 格 0 J → Examine J | 左大图、右描述；无 Yes/No；有 J 返回；人仍不能走 |
| 再 J | 窗关；底栏在；菜单不要自动弹出 |
| 再 J | 菜单再出（和以前一样） |
| 调查开着 D | 钥匙格仍是选中，不换格 |
| 调查开着 I | 全关；能走 |
| 关栏后捡的流程 | Yes/No 仍在，默认 No |
| 靠近纸条 J | 场景检视版式不变 |
| 出门耗钥 | 格清空；空格 J 仍无菜单 |

### 踩坑

| 现象 | 原因 |
|------|------|
| 调查变成拾取 Yes/No | Create 成了 `WBP_PickupConfirm`，或 SET 了 `Pickup Confirm UI` |
| 看不见板但仍锁着 / 出了板人不能走且 I 无效 | 调了 **`ShowPanel`**。须调 `ShowExamineView` |
| 关调查后场景 Icon / 状态乱 | SET 了角色 `Examine UI` 或调了 `CloseExamine`。只 Remove HUD 那份引用 |
| 开栏 A/D 变成 Yes/No | SET 了 `In Menu`。本块不要 SET |
| 调查无字 | `AddItem` 的 `In Desc` 没接；或 `SetupExamine` 接了 Widget 变量不是入口针；或钥匙实例描述空 |
| 调查无图、格子有图 | `In Image` 没接角色 `Inventory Images[Selected Slot]` |
| 再 J 立刻又出菜单 | `HandleInventoryJ` 没把 Is Valid 调查窗放在最前 |
| 按 I 留下检视板 | `HideInventoryHUD` 没调 `HideInvExamine` |
| 场景纸条坏了 | 改了 `ShowPanel` / `CloseExamine` / Hierarchy。本块只允许新建 `ShowExamineView` |

---

## 第五块：丢弃（2026-09-12）

一般物菜单有 **丢弃**；J 清空**当前格**（字/图/描述/标题/开关），后面的格不前挤。不 Spawn、不扔回场景。  
特殊物（本关钥匙）没有丢弃项、也丢不掉。使用仍空（只藏项）。合成仍空（J 只关菜单）。

不要写死 `Item_A`。不要走 `RemoveItem`（那是按 ID，两把同 ID 会清错格）。出门耗钥仍用原来的 `RemoveItem`。

### 不要改

- `IA_movement` 的 In Menu 口；`SelectYes` 的勾
- 密码锁；`ShowPanel` / `CloseExamine`
- `InvActionExamine` 开窗那串
- `DoYes` 的 Branch / Destroy
- 不要 SET `In Menu`

### 操作（本块测完应是）

| 操作 | 预期 |
|------|------|
| 钥匙默认（两颗 Bool 不勾）J 出菜单 | 只有 **Examine / Combine**。没有 Use、没有 Discard |
| 临时勾上钥匙 `b Can Discard`，再捡 → 菜单 | 有 Discard；J 后该格变空，其它格不动 |
| 不勾 `b Can Discard` 再捡 → 菜单点不到丢弃 | 格子还在 |
| 有钥匙出门 | 仍耗钥，和以前一样 |
| 调查 / 捡东西 Yes/No | 不受影响 |

本关没有药剂。测丢弃：钥匙实例 **临时勾** `b Can Discard`，测完再去掉。

### 步骤 1 — 钥匙两颗开关

打开 `BP_Item_Key` → Variables **+**（若已有就核对默认）：

| 名 | 类型 | 默认 | 勾上 |
|----|------|------|------|
| `b Can Use` | Boolean | **false**（不勾） | Instance Editable |
| `b Can Discard` | Boolean | **false**（不勾） | Instance Editable |

Compile → Save。关卡里钥匙实例确认两颗都**不勾**。

### 步骤 2 — 角色两数组 + Resize

`BP_Cha_01` Variables **+**：

| 名 | 类型 |
|----|------|
| `Inventory Can Use` | Boolean **数组** |
| `Inventory Can Discard` | Boolean **数组** |

BeginPlay 现有 Resize 8 旁边再两颗：Size 都是 **8**。

Compile。

### 步骤 3 — `AddItem` 两针

Inputs **+**：`In Can Use`（Boolean）、`In Can Discard`（Boolean）。必须是 Inputs。

写入 `InventoryItems` 的同一 Loop Index、True 路 Return 之前，再两颗 Set Array Elem：

- `Inventory Can Use` = 入口针 `In Can Use`
- `Inventory Can Discard` = 入口针 `In Can Discard`

满包那条不要写。Compile。

### 步骤 4 — `RemoveItem` 清开关

清格子的同一 Index 再两颗：两颗 Bool 都写成 **false**（不勾）。不要 Remove 缩短。

**2026-09-15 已测通（丢弃整条 + 菜单跳过藏项）：**

- 勾实例 `b Can Discard` → `DoYes` 接钥匙 `In Can Discard` → 菜单有 Discard → `ClearSlot` 清格、清图
- `ClearSlot` 末尾 Is Valid / RefreshInventory 的 Target = 角色 **`Inventory HUD`**（不要 self）
- 空图：Slot Image **Collapsed**，不要对空 Texture 走 Set Brush from Texture
- 有图：Set Brush 后 **Slot Text Collapsed**（藏 `Item_A`）
- `MoveSlotMenuCursor` 跳过藏项：一下 D 从 Examine 到 Combine；关菜单 A/D 换格仍走 `MoveSlotCursor`（0～7）
- 角色 `Inventory Can Use` / `Can Discard` 已是 Boolean 数组，不要改成 Text

测完把钥匙实例 **`b Can Discard` 去掉**（本关钥匙不能丢）。使用 / Combine 仍空。出门耗钥仍走 `RemoveItem`。不要 SET In Menu。

### 步骤 5 — 角色：`ClearSlot`（下次第一件）

新建函数 **`ClearSlot`**。Inputs **+**：`Slot Index`（Integer）。

不要用 `RemoveItem`。按格子号清：

```
Branch（Slot Index < 0 或 > 7）
  True  → Return
  False → Set Array Elem InventoryItems[Slot Index] = None
        → Inventory Images = None
        → Inventory Descs = 空 Text
        → Inventory Titles = 空 Text
        → Inventory Can Use = false
        → Inventory Can Discard = false
        → RefreshInventory（Target = Inventory HUD，先 Is Valid）
```

Compile。

### 步骤 6 — `DoYes` 只补两针

`WBP_PickupConfirm` → `DoYes` → 现有 `AddItem`：

- `In Can Use` ← Source Pickup 的 `b Can Use`
- `In Can Discard` ← Source Pickup 的 `b Can Discard`

其它针不要拆。Compile。

### 步骤 7 — HUD：菜单藏项

`WBP_InventoryHUD` 新建 **`IsMenuRowAvailable`**。Inputs：`Row`（Integer）。Outputs：`b Available`（Boolean）。

```
Branch（Row == 0）→ Return true          // Examine 总有
Branch（Row == 2）→ Return true          // Combine 总有
Branch（Row == 1）→ Cast 角色 → Return Inventory Can Use[Selected Slot]
Branch（Row == 3）→ Cast 角色 → Return Inventory Can Discard[Selected Slot]
其它 → Return false
```

Cast 失败当 false。

新建 **`RefreshSlotMenuOptions`**：

```
For Loop 0–3
  Get Slot Menu Texts[i]
  Is Valid
    True → Branch（IsMenuRowAvailable(i)）
             True  → Set Visibility Visible
             False → Set Visibility Collapsed
```

打开 **`ShowSlotMenu`**：Set Visibility `VB_SlotMenu` Visible **之后**、`PlaceSlotMenuOverSelected` / Refresh 之前（或之后）调 `RefreshSlotMenuOptions`。现有 SET Index=0、Latched 不勾 **不要拆**。

打开 **`MoveSlotMenuCursor`**：Clamp 之后不要直接 SET。改成：

```
Old = Slot Menu Index
Cand = Clamp(Old + Delta, 0, 3)
→ 最多试 4 次：
     IsMenuRowAvailable(Cand) 为 true → SET Index = Cand → RefreshSlotMenuCursor → Return
     否则 Next = Clamp(Cand + Delta, 0, 3)
     若 Next == Cand（到头）→ SET Index = Old → Refresh → Return
     否则 Cand = Next，继续
```

到头停在**上一档可见项**，不要停在藏着的 Use/Discard 上。

Compile HUD。

### 步骤 8 — `InvActionDiscard`

打开已有空函数，不要只 Return：

```
Get Owning Player Pawn → Cast BP_Cha_01
  失败 → Return
  成功 → Branch（Inventory Can Discard[Selected Slot]）
           False → Return
           True  → ClearSlot（Slot Index = Selected Slot）
```

`ConfirmSlotMenu` 不用改（3 口已经接它，然后 HideSlotMenu）。  
`InvActionUse` / `InvActionCombine` 仍只 Return。

Compile → Save。

### 这一块怎么测

Stop PIE → Compile 钥匙 + 角色 + HUD + 拾取板 → Play。

| 操作 | 预期 |
|------|------|
| 714 → 捡钥匙（默认不勾）→ I → J | 菜单只有 Investigate / Combine 两行 |
| A/D | 只在这两行之间，不会停在看不见的项上 |
| 停 PIE，钥匙勾上 `b Can Discard`，再 Play 捡 | 菜单多出 Discard；J 后格变空 |
| 勾上再去掉，再 Play 捡 | 又没有 Discard；格子丢不掉 |
| 出门 | 仍耗钥 |

### 踩坑

| 现象 | 原因 |
|------|------|
| 钥匙也能丢 | 实例勾了 `b Can Discard`，或 `AddItem` 没写这颗 Bool |
| 丢了两格 / 清错格 | 走了 `RemoveItem(ItemID)`。必须 `ClearSlot(Selected Slot)` |
| 菜单仍四项 | `RefreshSlotMenuOptions` 没在 `ShowSlotMenu` 里调 |
| A/D 停在空白处 | `MoveSlotMenuCursor` 没跳过 Collapsed |
| 出门坏了 | 改了 `RemoveItem` 的 ID 查找，或误把出门改成 ClearSlot |

# 背包栏（8 格）

> 固定 8 格；从左填第一个空格；中间清空不前挤。  
> 按 I 显隐 **已测通**，改多格时不要拆。  
> 工程：`D:\PN2D_Level_00_04`

最后更新：2026-09-05（8 格 + 满包 + 格子出图已测通；栏内菜单还没做）

---

## 操作（已有，不要改）

| 键 | 作用 |
|----|------|
| **I** | 显隐底栏。`IA_Inventory` 用 **Started**。In Menu 时忽略 |
| 开局 | 默认 **Hide**（Collapsed） |

栏内选格 / 调查 / 使用 / Combine / 丢弃：**还没做**。

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
满包：**已测通**。`AddItem` 失败 → `DoYes` 不 Destroy → `DoNo` 关板 → 角色 `SayBagFull`（对话：「我现在没有办法拿更多的东西了。」）。不必做 `WBP_ScreenPrompt`。新拾取物走同一块 `WBP_PickupConfirm`，实例填 `Display Image` 即可。

---

## 不要改

- `ShowInventoryHUD` / `HideInventoryHUD` / `ToggleInventoryHUD`
- `IA_Inventory` 的 **Started**；In Menu 时忽略 I
- BeginPlay 里背包 HUD 的 Create → SET → Add to Viewport → **Hide**
- 密码锁 `ShowPanel` / Hierarchy；`RefreshDigits`
- 拾取 A/D、默认 No、`SelectYes` 的 SET 勾
- 解锁直接 `AddItem`（`Grant Item ID`）
- 栏内菜单（调查 / 使用 / Combine / 丢弃）——下一块再做

`DoYes` **只允许**加一颗 Branch：看 `AddItem` 的返回。其它关板逻辑不要拆。

---

## 资源

| 资源 | 职责 |
|------|------|
| `BP_Cha_01` | `InventoryItems` + `Inventory Images`（各 8 格）；`AddItem(ItemID, In Image)` / `HasItem` / `RemoveItem`；`SayBagFull` |
| `WBP_InventoryHUD` | 底栏；`Slot Texts` / `Slot Images`；`RefreshInventory` 刷字+图（Brush 64×64）；按 I 显隐 |
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

## 下一块（先不要做）

1. Designer：底栏 8 个方格 `Txt_Slot0`…`Txt_Slot7`，`RefreshInventory` 循环 0–7  
2. 满包提示实机测（可临时 BeginPlay 塞满）  
3. 栏内选格 + 菜单：调查 / 使用 / Combine / 丢弃（丢弃只留口）  
4. 调查复用拾取板同一套图/描述，不要 Yes/No  

规格全文也在 `docs/TODO.md`「后续：背包栏」。

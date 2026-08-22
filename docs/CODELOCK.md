# 密码锁（WBP_CodeLock）

> 密码锁单独文档。改密码、换图、改按钮文案、后续接关卡，先看本文。  
> 还没做的功能总表见 `docs/TODO.md`。总览见 `docs/PROJECT_CONTEXT.md`。  
> 工程以 **`D:\PN2D_Level_00_04`** 为准（分支 `main`）。

最后更新：2026-08-22（Reveal **已测通**；本关捡出门已串；解锁进包先不做）

---

## 1. 当前状态

| 项 | 状态 |
|----|------|
| Designer 框架 | 已齐，**不要改 Hierarchy 名字 / 父子结构** |
| 临时 BeginPlay 出板 | **已测通**；测完应断开，否则开局就会弹锁（见第 6 节「关掉开局弹锁」） |
| 点数字填左三格 | **已测通**（Event Graph OnClicked 直接 SET `Txt_D0/D1/D2`） |
| Delete 删最后一位 | **已测通** |
| OK：对 `714` 关板；错了清空三格、板不关 | **已测通** |
| Cancel 关板、能走 | **已测通** |
| `BP_CodeLock` 触发器（靠近按 J 出板） | **已测通**（抄检视；见第 14、15 节） |
| 714 OK 后当场再 J | **已测通**：不出锁、不出调查 Icon |
| Cancel 后再 J | **已测通**：还能开锁 |
| 解开后 Reveal（Tag，任意 Actor，不 Spawn） | **已测通**（见第 17 节） |
| 三关切关 / 存档 | **后期** |

默认地图：`/Game/Maps/Level_00/Level_00_01/Level_00_01_P`

---

## 2. 资源位置

| 资源 | 路径 |
|------|------|
| Widget | `Content/Data/UMG/Puzzle/WBP_CodeLock` |
| 触发器 Actor | `Content/Data/Interactives/Puzzle/BP_CodeLock`（由 `BP_ExamineTrigger` 复制） |
| 墙上数字（谜题①） | **搁置**。Tag `PuzzleDigits` 已有实现先不动；测锁直接输 `714` |
| 解开后出现的物 | 场景里先摆好，默认 Hidden；Tag 与锁的 `Reveal Tag` 相同。本关可先放 `BP_Item_Key` |

贴图建议放到：

- `Content/Assests/`（项目拼写就是 `Assests`，不要改成 Assets）
- 或 `Content/Data/UMG/Puzzle/`（UI 专用图）

---

## 3. 已定玩法（不要改回 +/-）

- 全屏变暗 + 软暂停（In Menu、Ignore Move、显鼠标、Input Mode UI Only）
- 点数字从左往右填三格；满 3 位再点数字无效
- **Delete**：清最后一位
- **OK**：比对 `CorrectCode`（默认 **`714`**）。对了关板；错了清空三位、板不关
- **Cancel**：关板不提交，恢复走路
- 解开后：Get All Actors With Tag（锁上的 `Reveal Tag`）→ 每个 `Set Actor Hidden In Game(false)`，**不 Spawn、不 Cast 成钥匙**
- 功能键预览文案暂为英文 Delete / OK / Cancel，可改显示文字，**按钮控件名不要改**

默认密码仍是 `714`。关灯出墙上数字已搁置，测锁不用先关灯。以后接回谜题①时再让墙上数字与 `CorrectCode` 对齐。

---

## 4. 变量（沿用，勿强改名）

打开 `WBP_CodeLock` → Graph → Variables。

| 名 | 类型 | 默认 | 说明 |
|----|------|------|------|
| `InputCode` | String | **空** | 当前已输入。开局 / 清空后都是空，不要填 714 |
| `CorrectCode` | String | `714` | 正确答案。勾 Instance Editable，以后每把锁可不同 |
| `DigitCount` | Integer | **3** | 最多几位。必须和左三格数量一致 |

早期文档里的 `Entered` / `MaxDigits` 若工程里没有，以 **`InputCode` / `DigitCount`** 为准。

---

## 5. Hierarchy（已核对，勿再改结构）

Graph 按 **控件名字** 找按钮和格子。可以换图、换色、换字，**不要删、不要改名、不要把控件拖出当前父节点**。

```
Canvas Panel
├── Img_Dim                 Border；铺满；黑 A≈0.6；Draw As = Box/Rounded Box
└── Border_Panel            锚正中；Alignment 0.5,0.5；Size 1100×720；ZOrder 1
    └── HB_Main
        ├── SB_Left
        │   └── VB_Left
        │       ├── SizeBox_Lock → Img_Lock     约 320×320，锁图贴这里
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
                └── HB_Actions → SB_Delete / SB_OK / SB_Cancel → Btn_* → Text
```

数字键 Size Box 约 **96×96**；功能键约 **140×56**。UE5 Button **不自带 Text**，字是拖进去的子控件。

进 PIE 前：根 **Canvas Panel** 在 Designer 里默认 **Collapsed**；`ShowPanel` 再设 Visible。

---

## 6. Graph 接法（已测通，不要回退）

### 绑定链

`Event Construct` 一条白线串所有 Bind，**then 只接下一个 Bind**：

```
Construct → Bind Btn_7 → … → Bind Btn_0 → Bind Delete → Bind OK → Bind Cancel
```

最后 Cancel 的 then **空着**。

每颗 Bind：

- **Target** = 对应按钮
- **Event** 红针 = **该按钮自己的** OnClicked Custom Event（7 和 4 不要共用一个事件）
- **then 不要**接 Append / DeleteLast / TryConfirm / ClosePanel（Construct 时就会跑，进关会红字 Game Only）

### 显示规则（必须遵守）

改左三格 **只在 Event Graph 的 OnClicked**（或 TryConfirm 的 False 里直接 SET 三格）。

**不要用函数 `RefreshDigits` 改格子**（已证实会清空 / 不显示）。  
`ClearEntry` 如果内部还调 `RefreshDigits`，错码清空时也不要只调它。

数字键 OnClicked 模式（以 7 为准，其它键只改 Append 的 **B**）：

```
OnClicked
  → Branch（Len(InputCode) >= 3）  True 空着
       False → Append (String)  A=InputCode  B="7"
             → SET InputCode
             → SET Txt_D0 / D1 / D2
                  三个独立 Get Substring，Start = 0 / 1 / 2，Length = 1
```

- 用 **Append (String)**，不要数组 Append
- 三个 Substring **不要共用一颗**（否则三格会变成同一个字）
- 上限比的是 `Len(InputCode) >= DigitCount`（3），不要写成 `>= 2`

### 功能键 OnClicked

| 按钮 | OnClicked 白线接 |
|------|------------------|
| `Btn_0` … `Btn_9` | 各自抄 7，只改 B=`"0"`…`"9"` |
| `Btn_Delete` | `DeleteLast`，然后同样三格 SET（Substring 0/1/2）。不要 Append |
| `Btn_OK` | 只调 `TryConfirm` |
| `Btn_Cancel` | 只调 `ClosePanel` |

### `TryConfirm`

```
TryConfirm
  → Branch（Equal String：InputCode == CorrectCode）
       True  → ClosePanel
       False → SET InputCode（空）
             → SET Txt_D0 / D1 / D2 为空（Make Literal Text 空框，可共用）
```

- `==` 必须从 **字符串粉针**拖出 **Equal (String)**，不要空白搜整数 `==`
- `TryConfirm` True 里加 Reveal：见第 17 节（下一步）

### `ClosePanel`（已测通）

PC0：Ignore Move 不勾、鼠标不勾、Game Only → Cast `BP_Cha_01`：Status=Idle → INT OBJ Valid 则 ShowExamineIcon 否则 HideInteractIcons → **Remove from Parent(self)**。  
`Set Input Mode Game Only` 的 Player Controller 必须接 **Get Player Controller Index 0**。

### 临时出板（测 UI 用）

`BP_Cha_01` BeginPlay 末尾曾经接过：

```
Create Widget（Class = WBP_CodeLock，Owning Player = PC0）
  → SET CodeLock UI
  → Add to Viewport
  → Delay 0
  → ShowPanel
```

面板功能测通后 **必须断开这段**，否则每次进关都会弹锁。

### 关掉开局弹锁

打开 **`BP_Cha_01`**（`Content/Assests/Charactors/C_01/BP/`）→ Event Graph → **Event BeginPlay**。

1. 找到 **Create Widget**，Class 是 **`WBP_CodeLock`** 的那一串（后面接 SET `CodeLock UI`、Add to Viewport、Delay、`ShowPanel`）。
2. **只拆这一串**：从 BeginPlay 白线上断开；节点可删，也可先留着不接白线。
3. <span style="color:#e74c3c">不要动</span> 同一条 BeginPlay 里 **背包 HUD** 的 Create / SET / Add to Viewport / Hide。
4. **不要删** 变量 `CodeLock UI`，**不要删** `WBP_CodeLock`。

Compile → Save → Play：进关不应再出锁，能走路。

以后靠近按 J 出板，要等 `BP_CodeLock` 触发器接上。现在空地不会出锁是正常的。

改 Graph 时：**Stop PIE → Compile → Play**，不要一边 Simulating 一边改（图会 READ-ONLY）。

---

## 7. 以后改密码

1. 打开 `WBP_CodeLock` → Graph → 变量 **`Correct Code`**
2. Details → **Default Value** 改成新密码（String，不要空格）
3. 位数必须等于 **`Digit Count`**（现在是 3）
4. Compile → Stop PIE → Play，用新密码测 OK / 错码清空。墙上数字已搁置，先不用改 `PuzzleDigits`

现在还是 BeginPlay 临时出板，改 **Widget 默认值** 即可。

以后有 `BP_CodeLock` 之后：在关卡里选中那把锁，Details 改实例的 `Correct Code`（Instance Editable），每把锁可以不同。Create 后也可 SET Widget 的 `CorrectCode`。

---

## 8. 以后换美术 / 改资源

原则：**只换 Brush / Tint / Font / Style 图片**。不要改控件名，不要拆 Size Box 包层。

图导入 Content Browser 后，Texture 勾 **sRGB**。透明 PNG 的 Image 控件 **Draw As = Image**。

| 要换的 | 点谁 | 改哪 |
|--------|------|------|
| 左边大锁图 | `Img_Lock` | Appearance → Brush → **Image**。占位约 320×320，图比例接近即可。缩放改外层 **`SizeBox_Lock`** 的 Width/Height Override |
| 全屏变暗 | `Img_Dim` | 只改 **Tint / 透明度**。这是 **Border 纯色**。**不要改成空 Image（Image=None）**，Designer 会白光、Zoom 卡死 |
| 三格底框 | `Border_D0/D1/D2` | Brush：Draw As 用 **Rounded Box / Box**（不要 Draw As = Border，会变厚相框）。可换 Tint 或 Brush Image |
| 格子里的数字 | `Txt_D0/D1/D2` | Font、颜色、字号。Graph 只 SetText，换字体不影响接线 |
| 「CODE」标题 | `Txt_Label` | 文字 / 字体 |
| 数字键外观 | `Btn_0`～`Btn_9` | Style → **Normal / Hovered / Pressed** 的 Image。子 Text 可换字体 |
| Delete / OK / Cancel | `Btn_Delete` `Btn_OK` `Btn_Cancel` | 同上 |
| 整块面板底 | `Border_Panel` | Brush / Tint。面板大小改 **Slot Size X/Y**（约 1100×720）。**不要改 Image Size 32** |

### 换锁图步骤

1. 把 PNG 拖进 Content Browser
2. Designer 点 **`Img_Lock`**
3. Details → Brush → Image → 选这张 Texture
4. Draw As = **Image**
5. 太大/太小：改 **`SizeBox_Lock`**，不要改 Image Size

### 换按钮图步骤

1. 点 Button（不要点里面的 Text）
2. Style → **Normal** 展开 → Image 指定贴图
3. Hovered / Pressed 各做一张，或先三态共用一张
4. 按钮上的字仍是子 Text，换皮肤后确认字还在、没被挡住

建议先只换 **`Img_Lock`**，进 PIE 确认 714 仍通，再换按钮和底图。

---

## 9. 以后改按钮文案（中文等）

点 Button **里面的 Text**（不是 Button 本身），改 Text 内容，例如 Delete → 删除。

**不要改** Hierarchy 里的 `Btn_Delete` / `Btn_OK` / `Btn_Cancel` 名字。

---

## 10. 以后改成 4 位（现在不要做）

现在锁死 **3 位 + 三格**。若以后要 4 位，需要同时：

1. `DigitCount` 改 4
2. Hierarchy 加 `SizeBox_D3 → Border_D3 → Txt_D3`（名字稳定）
3. 每个数字键 / Delete / TryConfirm False 的 SET 格子补第四格，Substring Start=3
4. `CorrectCode` 改成 4 位
5. 墙上数字也改成 4 个

未做完不要只改 `DigitCount`。

---

## 11. 尚未做

已移到 **`docs/TODO.md`**。密码锁相关下次只做 **Reveal（第 17 节）**；三关切关、存档、每把锁一个密码、改成 4 位均 **延后**。

---

## 14. `BP_CodeLock` 触发器（抄检视）

就是 `BP_ExamineTrigger` 那套：靠近进 INT OBJ，按 **J** Create 面板。开板后 **仍用鼠标** 点数字 / OK / Cancel（UI Only）。以后若与拾取统一成键盘，见第 16 节预留，**现在不要改 ShowPanel**。

### 前提

- `WBP_CodeLock` 的 `ShowPanel` / `ClosePanel` 已通
- `BP_Cha_01` 已有变量 **`CodeLock UI`**（`WBP_CodeLock` 对象引用）
- BeginPlay 里 **不要再** Create 密码锁

### 1. 复制蓝图

1. Content Browser 打开 `Content/Data/Interactives/Examine/BP_ExamineTrigger`
2. 右键 **Duplicate**
3. 移到 `Content/Data/Interactives/Puzzle/`（没有就新建文件夹 Puzzle）
4. 改名 **`BP_CodeLock`**
5. 打开 → Compile

Overlap：Begin 里 **Add Interactive Obj 的 Target = Other Actor**（类型 `BP_Player`，不要另 Cast）；`INT OBJ` = self。  
`ShowExamineIcon` 要的是 **`BP_Cha_01`**，用图里 **已有的** `Cast To BP_Cha_01`（Object = Other Actor），Target = **As BP Cha 01**。不要接 self，不要再新建一颗 Cast，不要用 Get Player Character。  
End Overlap 清空 INT OBJ + Hide，不要改。  
**只用 Event Interactive**（接口），不要再加一个同名函数 `Interactive`。

删掉或断开 Interactive 里的 `SetupExamine`、SET `Examine UI`、Create `WBP_ExaminePanel`。标题/正文/图那些变量可先留着不用。

### 2. Event Interactive（开板）

**最前面**先判断 `Solved`（见第 15 节）。未解开才 Create：

```
Event Interactive
  → Branch（Get Solved，self）
       True  → 空着
       False → Cast 角色 → Is Valid（CodeLock UI）
                    Valid     → 空着
                    Not Valid → Create WBP_CodeLock（Owning = PC0）
                              → SET CodeLock UI（Target = 角色，值 = Create Return）
                              → Add to Viewport → Delay 0 → ShowPanel
```

- SET 的 Target 是 **角色**，值是 **Create 的 Return**，不要 self
- Delay / ShowPanel / Viewport 的 Target 都是 **Create Return**
- 不要 Cast To Class
- 密码今晚用 Widget 默认 `714`，触发器上先不 SET `CorrectCode`

### 3. `WBP_CodeLock`：`HandleCodeLock` + 关板清引用

Functions **+** → 改名 **`HandleCodeLock`**：

```
HandleCodeLock → ClosePanel
```

打开 **`ClosePanel`**，在 Remove from Parent **之前**加：

```
Cast To BP_Cha_01（已有）
  → SET CodeLock UI = None（Target = 角色）
  → Remove from Parent（self）
```

不清算第二次靠近 J 会走到「已 Valid」或打到已销毁的板。

### 4. `BP_Cha_01` 的 J 链

`IA_Interactive` 现有：Dialogue → Examine → INT OBJ。  
在 Examine 无效、INT OBJ 之前插入 CodeLock：

```
IA_Interactive
  → Is Valid (Dialogue UI)     有效 → Handle Interactive
  → Is Valid (Examine UI)      有效 → HandleExamine
  → Is Valid (CodeLock UI)     有效 → HandleCodeLock
  → Is Valid (INT OBJ)         有效 → Interactive
```

CodeLock 必须在 INT OBJ **前面**。否则板还开着时 J 会再进触发器 Interactive。

### 5. 关卡里摆一个

打开 `Level_00_01_P`（逻辑多半在 `Level_00_01_BP`）。

1. 把 `BP_CodeLock` 拖进关卡
2. 放在密码锁谜题附近（墙数字 / 以后放锁的位置），碰撞盒能碰到角色
3. 位置可先用检视触发器同款 Mesh 占位

Compile → Save → Play。

### 6. 验收

| 操作 | 预期 |
|------|------|
| 开局 | **不出锁**，能走 |
| 走到触发器 | 头顶 Examine Icon |
| 按 J | 出密码锁，鼠标，不能走 |
| 点 Cancel | 关板，能走；再 J 还能开 |
| 714 + OK | 关板、能走；**当场再 J 不出锁、不出 Icon** |
| 空地按 J | 不出锁 |

### 不要做（接触发器那晚）

- Reveal（见第 17 节，下一步再做）
- 改 Hierarchy
- 把 BeginPlay 临时 Create 接回去

踩坑：两个 `Interactive`（只留 Event）；SET `CodeLock UI` 的 Target 误接成触发器 self。

---

## 15. 解开后不再开锁（2026-08-17 已测通）

密码锁从 `BP_ExamineTrigger` 复制，**不必**另放检视触发器。头顶 Icon + 按 J 都是这把锁自己的 Overlap / Interactive，看起来会像「调查」。

### 为什么只改 Overlap 不够

人解开时 **还站在碰撞里**，不会再进一次 Begin Overlap。再按 J 走的是 **Event Interactive**。  
所以 `Solved` 必须在 **Interactive 最前面**也判断。Overlap 的 Branch 只挡「走开再走进来」。

### 变量

| 位置 | 名 | 说明 |
|------|----|------|
| `BP_CodeLock` | `Solved`（Bool，默认 false） | 只有 714 OK 才写成 true。Cancel / 输错不要写 |
| `WBP_CodeLock` | `OwnerLock` | 可留，**不要当主路径**（Create 时经常没赋值，SET 不到 Actor） |

### 谁在什么时候跑

```
靠近
  → Begin Overlap（Other Actor = 角色）
       有 Player Tag 且 Solved == false
         → Add Interactive Obj（Target = Other Actor，INT OBJ = self）
         → Cast Other Actor To BP_Cha_01（用已有那颗）
         → ShowExamineIcon（Target = As BP Cha 01）
         → Icon Mesh 可见

按 J（角色 IA_Interactive）
  → Dialogue / Examine / CodeLock UI 都无效
  → INT OBJ 有效 → 这把锁的 Event Interactive
       Solved == true  → 空（不再开板）
       Solved == false → Create WBP_CodeLock → ShowPanel

点 Cancel
  → ClosePanel（不写 Solved）→ 还能再 J 开锁

点 OK 且密码 == 714
  → 角色 INT OBJ 就是这把锁
  → Cast INT OBJ To BP_CodeLock
       → SET Solved = true（Target = 锁，不是面板 self）
       → 关碰撞
  → 角色 SET INT OBJ = None → HideInteractIcons
  → ClosePanel（SET CodeLock UI = None → Remove）
```

### `TryConfirm` True（已测通，不要改回 OwnerLock 主路径）

```
True
  → Get Player Character → Cast To BP_Cha_01
  → Get INT OBJ → Cast To BP_CodeLock
       成功 → SET Solved = true（Target = 锁）
            → Set Actor Enable Collision 不勾（Target = 锁）
  → SET INT OBJ = 空（Target = 角色）
  → HideInteractIcons（Target = 角色）
  → ClosePanel
```

Cast 失败也要接到 ClosePanel。False（输错）只清三格，不写 Solved。

`SET Solved` 的 Target 必须是 **Cast To BP_CodeLock 的出口**。接面板 self = 锁永远不知道已解开。

### Overlap 接线（不要加新 Cast）

| 节点 | Target |
|------|--------|
| `Actor Has Tag` | Begin Overlap 的 **Other Actor** |
| `Add Interactive Obj` | **Other Actor**（`BP_Player`）；INT OBJ = **self** |
| `ShowExamineIcon` | 已有 Cast 的 **As BP Cha 01**（不要 self、不要再 Cast 一次） |
| `Set Visibility` | **Icon Mesh** |

Solved Branch：**True 空着**，**False** 才 Add INT OBJ。

### `Img_Dim` 左上角白块

不是 Print。`Img_Dim` 曾是锚左上、Size 100×30、纯白。Anchors 铺满，Left/Top/Right/Bottom **全 0**，Tint 黑 A≈0.6，Draw As = Box / Rounded Box。

### 踩坑（解开）

| 问题 | 原因 |
|------|------|
| 714 关不了板 | True 上 SET Solved 在 OwnerLock 空时 Accessed None，白线到不了 ClosePanel |
| 关板后还能再开 / 像调查 | Interactive 没判断 Solved；或 SET Solved 写在面板 self 上 |
| ShowExamineIcon 红字 | Target 接了 self；它要 BP_Cha_01 |
| 乱加 Cast | Add 用 Other Actor 即可；ShowExamineIcon 用图里已有那颗 Cast |

---

## 12. 踩坑（已踩过，勿重蹈）

| 问题 | 原因 / 处理 |
|------|-------------|
| 格子无字 | 不要用 `RefreshDigits`。Event Graph OnClicked 硬 SET `Txt_D0`=`7` 能出则拼字/Len 错，不能出则 Bind/OnClicked 没接上 |
| 点一下三格都是同一个字 | 三个 SET 共用了一颗 Substring |
| 第 4 下还能输入 / 第 3 下就停 | 上限用 `Len(InputCode) >= 3`，不要 `>= 2` |
| 进关红字 Game Only / 板闪一下关掉 | Bind 的 **then** 误接了 ClosePanel / TryConfirm |
| 点 Cancel 没关板 | ClosePanel 必须接 **OnClicked** 白线，不是 Bind then |
| 显示 `Btn_77` | 不要用 Get Display Name |
| Designer 白光卡死 | `Img_Dim` 空 Image 铺满；变暗用 Border |
| Border 在 Horizontal Box 里拉成竖条 | 必须 Size Box 包住再放 Border/Button |
| 三框跑到锁图右边 | `HB_Digits` 须在 `VB_Left` 里、Spacer 下面 |
| CODE 和框挤一行 | `Txt_Label` 与 `HB_Digits` 平级，不要进 HB_Digits |
| 0 不对齐 8 | `Pad_L` → `SB_0` → `Pad_R` |
| 面板改不大 | 改 Slot Size X/Y，不要改 Image Size |
| 粉线插白口 | 白接白、粉接粉；Substring 无执行白线 |
| 空白搜 Length | 从 `InputCode` 粉针拖出 Len |
| 数组 Append | 要用 **Append (String)** A+B |
| 一边 Play 一边改 Graph | 先 Stop PIE，图是 READ-ONLY |

---

## 13. 回归测法

改完密码或换图后，Stop PIE → Compile → Play：

1. 进关板在（临时 BeginPlay 还在时）
2. 点 7、1、4，左三格依次有字；第 4 下数字无效
3. Delete 一次变 `71`
4. 乱输三位再 OK：格子清空，板还在
5. 再输正确密码 OK：关板、能走
6. Cancel：关板、能走，不提交

换图额外看：锁图没拉伸碎、按钮字还在、变暗没有白光。

---

## 16. 预留：不用鼠标（键盘输入）— **先不要做**

2026-08-21：拾取改成 A/D + J；密码锁 **继续鼠标**。以后若要统一，按本节改，不要现在动 `ShowPanel`。

不要在 12 颗键上走光标。数字键直接输入。按钮 OnClicked 留着当备用。

| 键 | 作用 |
|----|------|
| **0–9** | 和点对应按钮一样 |
| **Backspace** | 同 Delete |
| **Enter** | 同 OK → `TryConfirm` |
| **Esc** | 同 Cancel → `ClosePanel` |
| **J** | 仍 `HandleCodeLock` → `ClosePanel`（返回）。不要改成 OK |

以后改 `ShowPanel` 时：不出鼠标；**去掉 UI Only**，改 Game and UI / Game Only；`Set Keyboard Focus`（self）；Widget **Is Focusable**。

`Event On Key Down`：Key Equal `One`…`Zero` / `Backspace` / `Enter` / `Escape`，分别走现有数字 OnClicked / DeleteLast / TryConfirm / ClosePanel。不要调 `RefreshDigits`。不要空白搜字符串 `"1"`。

---

## 17. Reveal（任意物，按 Tag）— **已测通**（2026-08-22）

锁解开后：把场景里已摆好、带指定 Tag 的 Actor 显示出来。不 Spawn、不 Cast 成钥匙。换物只改关卡 Tag / Hidden。

搜 Actor 必须在 **`BP_CodeLock`** 上做。不要写在 `WBP_CodeLock` 里（面板当 World 会找到 0 个；也不要在面板上建 `RevealByTag`）。

### 正式接法

| 在哪 | 做什么 |
|------|--------|
| `BP_CodeLock` 变量 | `Reveal Tag`（Name，默认 `PuzzleReveal`，Instance Editable）。空 = 解开后不显示 |
| `BP_CodeLock` 函数 `RevealByTag` | 见下。**不要加函数 Inputs**；读 self 的变量 `Reveal Tag`（不要读 `Tag`，那是另一颗，关卡里常为 None） |
| `WBP_CodeLock` → `TryConfirm` | HideInteractIcons 之后：从 Cast **As BP Code Lock 蓝针**拖出 `RevealByTag` → ClosePanel |
| 关卡 | 要出现的 Actor：Hidden in Game + **Actor Tags**（不是 Component Tags）与锁实例 `Reveal Tag` 相同 |
| `BP_Item_Key` BeginPlay | `Get Actor Hidden In Game` → True 则 `Set Actor Enable Collision` 不勾。解开后由 `RevealByTag` 再打开 |

```
RevealByTag（BP_CodeLock，无输入）
  → Branch（Reveal Tag != None）
       False → Return
       True  → Get All Actors With Tag（Tag = self 的 Reveal Tag）
             → For Each
                  Array = Out Actors     ← 必须接，否则 Length 有数、循环不跑
                  Loop Body → Set Actor Hidden In Game（New Hidden = false）
                           → Set Actor Enable Collision（勾上，Target = Array Element）
```

`TryConfirm` True 已有 SET `Solved` / 关锁碰撞 / 清 INT OBJ / HideInteractIcons，不要拆。Cast Failed → ClosePanel。

临时 Print 测完删掉。

### 以后：解开直接进背包（2026-08-22 已记，先不做）

锁上加 `Grant Item ID`（Name，Instance Editable，空=不发）。`RevealByTag` 的 For Each **Completed** 后：ID 非空则 Cast 角色 → `AddItem`。不要和场景里同一件可捡物一起用（会进两次）。出门仍看背包 `HasItem`。

### 场景里

1. 摆要出现的 Actor（Cube / 钥匙 / 柜子，须是独立 Actor）
2. **Hidden in Game** 勾上
3. Actor **Tags** 加 `PuzzleReveal`
4. 锁实例 `Reveal Tag`=`PuzzleReveal`

### 踩坑

| 现象 | 原因 |
|------|------|
| 714 关板、物不出现；Print Length=1 但没名字 | For Each 的 **Array 没接 Out Actors** |
| 面板 Compile：self 不是 BP_CodeLock | `Get Reveal Tag` / `RevealByTag` 建在了 `WBP_CodeLock` 上 |
| 函数直接 Return | 读成了变量 `Tag`（None），或函数入口另有一颗空的 `Reveal Tag` 输入 |
| 柜子不出现 | 不是独立 Actor，或 Tag 加在 Component Tags |

### 验收

| 操作 | 预期 |
|------|------|
| 开局 | 物看不见（走近出 Icon 可忽略） |
| 714 + OK | 物出现；板关、能走 |
| 当场再 J | 不出锁 |

### 不要做

- Spawn、Cast 成具体物品类、为「不是钥匙」另写解锁
- 改 Hierarchy / ShowPanel / 键盘；不要改关灯 / `PuzzleDigits`（搁置）
- 不要在 Reveal 里关碰撞 / Delay；不要在面板上建 `RevealByTag` |


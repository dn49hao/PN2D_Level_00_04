# 拾取确认（键盘光标）

> 拾取 Yes/No **不用鼠标**，用左右光标 + J 确认。  
> 密码锁 **仍用鼠标**；键盘方案预留在 `docs/CODELOCK.md` 第 16 节。  
> 工程：`D:\PN2D_Level_00_04`

最后更新：2026-08-22（已测通；默认光标改为 **No**）

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

## 不要做（下次）

- 换密码锁图、拾取板 3D 旋转模型
- 改 Yes/No 按钮 Hierarchy 名字
- 密码锁改键盘
- 解锁直接进背包（已记 `TODO.md`，先不做）

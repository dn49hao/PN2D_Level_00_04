# 待做功能

> 还没做、以后要做的功能单独记在这里，方便查阅。  
> 已完成的系统细节不写这里：密码锁见 `docs/CODELOCK.md`，总览见 `docs/PROJECT_CONTEXT.md`。  
> 工程以 **`D:\PN2D_Level_00_04`** 为准。

最后更新：2026-08-17

---

## 下次做（本关谜题串完）

按顺序，一次只做一块。

| 优先级 | 项 | 说明 |
|--------|----|------|
| **1** | **Reveal 钥匙** | 714 OK 后不要 Spawn。场景里先放钥匙，默认 Hidden，Tag = `PuzzleKey`。解开：`Get All Actors With Tag` → `Set Actor Hidden In Game(false)`。写在 `TryConfirm` True、关板之前。见 `CODELOCK.md` |
| **2** | **捡钥匙出门** | 用现成 `BP_Item_Key` + `BP_Door_KeyTransport` 跑通：钥匙出现 → 捡 → 出门 |
| 确认 | BeginPlay 临时出板 | 开局不应再弹锁；若还在，断开角色 BeginPlay 里 Create `WBP_CodeLock` |

本关流程：关灯出数字 → 密码锁 → **钥匙出现** → 拾取 → 出门。

---

## 有空再做（不挡流程）

| 项 | 说明 |
|----|------|
| 密码锁换美术 | `Img_Lock`、按钮 Style、三格底。只换图，不改控件名。`CODELOCK.md` 第 8 节 |
| 按钮改中文 | 改 Button **里面的 Text**（Delete / OK / Cancel）。不要改 `Btn_OK` 等名字 |
| 改默认密码 | Widget 变量 `CorrectCode`；墙上 `PuzzleDigits` 一起改。仍是 3 位 |
| 拾取板增强 | 上模型可转、描述、Take it? 参考 Asleep；排在本关串通之后 |
| 背包多格 / 图标 | HUD Index、格子图标；按 I 显隐已通 |
| 开局自言自语 | BeginPlay 或区域自动对话 |
| 引导按 I、Toast、环境短提示 `WBP_ScreenPrompt` | 延后 |
| `Img_Dim` | 铺满 + 黑 A≈0.6；若左上角还有白条再改 Offset 全 0 |

---

## 明确延后（先不要做）

| 项 | 为什么延后 | 以后怎么做（备忘） |
|----|------------|-------------------|
| **三关切关** | 先做完本关一条线 | Level_00_01 → 02 → 03；GameInstance 进度；`Open Level`。可另建 `docs/CAMPAIGN_FLOW.md` |
| **存档 / 读档** | 和切关一起设计 | SaveGame：背包、旗标、当前关、门已开等 |
| **一把锁一个密码** | 现在全关一张锁、默认 `714` 即可 | 触发器 Instance Editable `CorrectCode`；Create 后 SET 到 Widget |
| **改成 4 位** | 现在锁死 3 格 | 加 `Txt_D3`、`DigitCount=4`、所有 SET/Substring 补第四格；不要只改 `DigitCount` |

不要把延后项和「下次做」混在一次改里。

---

## 查阅

| 文档 | 内容 |
|------|------|
| 本文 `docs/TODO.md` | 还要做什么 |
| `docs/CODELOCK.md` | 密码锁怎么改、怎么接线、踩坑 |
| `docs/PROJECT_CONTEXT.md` | 全项目背景、已测通系统 |

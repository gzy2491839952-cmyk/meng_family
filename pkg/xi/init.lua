-- SPDX-License-Identifier: GPL-3.0-or-later
local extension=Package:new("hanqing_xi")
extension.extensionName="meng_family"
require("packages.meng_family.pkg.xi.shared_hand").install()
extension:loadSkillSkelsByPath("./packages/meng_family/pkg/xi/skills")
local normal=General:new(extension,"xi__chengong","qun",3,3,General.Male)
normal:addSkills{"xi__mouzhi","xi__yinpan"}
local alternate=General:new(extension,"xi_state__chengong","qun",3,3,General.Male)
alternate.prefix="xi"
alternate.total_hidden=true
alternate:addSkills{"xi__mouzhi_xi","xi__yinpan"}
local zhangti=General:new(extension,"xi__zhangti","wu",3,3,General.Male)
zhangti:addSkills{"xi__youwei","xi__juedu"}
local zhangtiXi=General:new(extension,"xi_state__zhangti","wu",3,3,General.Male)
zhangtiXi.prefix="xi"
zhangtiXi.total_hidden=true
zhangtiXi:addSkills{"xi__youwei_xi","xi__juedu_xi"}
local guanyu=General:new(extension,"xi__guanyu","shu",4,5,General.Male)
guanyu:addSkills{"xi__jiyue","xi__gusui"}
local guanyuXi=General:new(extension,"xi_state__guanyu","shu",4,5,General.Male)
guanyuXi.prefix="xi"
guanyuXi.total_hidden=true
guanyuXi:addSkills{"xi__jiyue_xi","xi__gusui_xi"}
local yangjun=General:new(extension,"xi__yangjun","jin",3,3,General.Male)
yangjun:addSkills{"xi__judong","xi__xiongcou"}
local yangjunXi=General:new(extension,"xi_state__yangjun","jin",3,3,General.Male)
yangjunXi.prefix="xi"
yangjunXi.total_hidden=true
yangjunXi:addSkills{"xi__judong_xi","xi__xiongcou_xi"}
Fk:loadTranslationTable {
  ["jin"]="晋",
  ["xi__yangjun"]="夕杨骏", ["xi_state__yangjun"]="夕杨骏",
  ["#xi__yangjun"]="豺狼专辅", ["#xi_state__yangjun"]="祸咎自取",
  ["designer:xi__yangjun"]="头发好借好还", ["designer:xi_state__yangjun"]="头发好借好还",
  ["illustrator:xi__yangjun"]="摩羯", ["illustrator:xi_state__yangjun"]="摩羯",
  ["xi__judong"]="居栋", ["xi__judong_xi"]="居栋",
  ["xi__xiongcou"]="凶辏", ["xi__xiongcou_xi"]="凶辏",
  [":xi__judong"]="准备阶段，你可以将手牌数摸至全场最大，然后所有其他角色可依次明置一张【杀】并弃置你一张手牌；若你因此失去了所有手牌，你进入夕状态。",
  [":xi__judong_xi"]="准备阶段，你可以将手牌数摸至全场最大，然后所有其他角色可依次明置一张【杀】并视为对你使用之。",
  [":xi__xiongcou"]="你可以将任意名角色的任意张明置的伤害牌当等量牌名字数的伤害牌使用，因此失去牌的角色本轮下次受到的伤害+1。",
  [":xi__xiongcou_xi"]="你可以将任意名角色的任意张明置的伤害牌当等量牌名字数的牌使用，因此失去牌的角色可摸或弃置你等量牌。",
  ["@xi__judong_shown"]="明置", ["@xi__xiongcou-round"]="凶辏增伤",
  ["#xi__judong-invoke"]="居栋：将手牌摸至全场最多，然后其他角色可依次明置【杀】发动后续效果",
  ["#xi__judong-show"]="居栋：可明置一张尚未明置的手牌【杀】，然后弃置%dest一张手牌",
  ["#xi__judong-slash"]="居栋：可明置一张尚未明置的手牌【杀】，并视为对%dest使用同名【杀】（原牌保留）",
  ["#xi__xiongcou"]="凶辏：选择伤害牌牌名，再选择等于其中文牌名字数张明置伤害牌",
  ["#xi__xiongcou_xi"]="凶辏：选择牌名，再选择等于其中文牌名字数张明置伤害牌",
  ["#xi__xiongcou-choice"]="凶辏：你因此失去%arg张牌，可以摸等量牌或弃置%dest等量牌",
  ["xi__xiongcou_draw"]="自己摸等量牌", ["xi__xiongcou_discard"]="弃置杨骏等量牌",
  ["xi__guanyu"]="夕关羽", ["xi_state__guanyu"]="夕关羽",
  ["#xi__guanyu"]="勇如一国", ["#xi_state__guanyu"]="日暮途穷",
  ["designer:xi__guanyu"]="屑", ["designer:xi_state__guanyu"]="屑",
  ["illustrator:xi__guanyu"]="super庆", ["illustrator:xi_state__guanyu"]="super庆",
  ["xi__jiyue"]="霁月", ["xi__jiyue_xi"]="霁月",
  ["xi__gusui"]="孤睟", ["xi__gusui_xi"]="孤睟",
  [":xi__jiyue"]="你可以弃置任意张牌，并视为使用一张【无懈可击】，抵消此无懈的方式改为：目标重铸等量张红色牌，点数须均大于底牌。若未抵消，你可回复1点体力，再进入夕状态。",
  [":xi__jiyue_xi"]="你可以重铸任意张红色牌，并视为使用一张【杀】或【无懈可击】，抵消方式改为：目标弃置等量张牌。若点数均大于底牌，你须失去1点体力，或退出夕状态。",
  [":xi__gusui"]="当你体力值变化后，每满足一项便摸一张牌：无角色比你更多；无角色与你相同；首次变至此值。然后若发动前没有手牌，你可以分配1点伤害。",
  [":xi__gusui_xi"]="当你体力值变化后，每未满足一项便弃置一张牌：无角色比你更多；无角色与你相同；首次变至此值。若发动后没有手牌，你可以分配1点伤害。",
  ["#xi__jiyue"]="霁月：弃置至少一张牌，视为使用【无懈可击】（以所选牌最大点数为底牌点数）",
  ["#xi__jiyue_xi"]="霁月：重铸至少一张红色牌，视为使用【杀】或【无懈可击】",
  ["#xi__jiyue-recast"]="霁月：可重铸%arg张红色牌，且每张点数均须大于%arg2，抵消此【无懈可击】",
  ["#xi__jiyue-discard"]="霁月：可弃置%arg张牌抵消此牌；若每张点数均大于%arg2，关羽须失去体力或退出夕状态",
  ["#xi__jiyue-high"]="霁月：对方弃置牌点数均大于底牌，失去1点体力或退出夕状态",
  ["xi__jiyue_losehp"]="失去1点体力", ["xi__jiyue_exit"]="退出夕状态",
  ["#xi__jiyue-success"]="霁月：此无懈未被抵消，是否回复1点体力并进入夕状态？",
  ["xi__jiyue_recover"]="回复1点体力并进入夕状态",
  ["#xi__gusui-damage"]="孤睟：可以选择一名角色，对其造成1点伤害",
  ["xi__zhangti"]="夕张悌", ["xi_state__zhangti"]="夕张悌",
  ["#xi__zhangti"]="殊死一搏", ["#xi_state__zhangti"]="致命遂志",
  ["designer:xi__zhangti"]="食恶不赦", ["designer:xi_state__zhangti"]="食恶不赦",
  ["illustrator:xi__zhangti"]="sier", ["illustrator:xi_state__zhangti"]="sier",
  ["xi__youwei"]="宥围", ["xi__youwei_xi"]="宥围",
  ["xi__juedu"]="绝渡", ["xi__juedu_xi"]="绝渡",
  [":xi__youwei"]="每回合限一次，有角色成为伤害牌的目标后，你可重铸一张伤害牌或装备牌无效之，然后你获得其一张牌。若获得牌的牌面信息包含【杀】，你进入夕状态。",
  [":xi__youwei_xi"]="你成为伤害牌的目标后，其需交给你一张牌面信息包含【杀】的牌以令之结算两次；否则结算后你可对不同角色依次使用一张伤害牌或装备牌，被响应时你重铸一张非伤害牌或退出夕状态。",
  [":xi__juedu"]="准备阶段，你可弃置所有牌。然后直到此回合结束，你可如手牌般使用、打出或重铸本回合进入弃牌堆的牌（无距离限制）并置于牌堆底。",
  [":xi__juedu_xi"]="每名角色的准备阶段，你可废除一个区域直到你回合开始。然后直到此回合结束，你可如手牌般使用、打出或重铸本回合进入弃牌堆的牌（无次数限制）并置于牌堆底。",
  ["#xi__youwei-recast"]="宥围：重铸一张伤害牌或装备牌，令此牌对%dest无效，并获得用牌者一张牌",
  ["#xi__youwei-give"]="宥围：交给%dest一张牌面信息包含【杀】的牌，令此牌对其结算两次；或取消",
  ["#xi__youwei-chain"]="宥围：可继续对尚未选择的角色使用伤害牌或装备牌（取消结束）",
  ["#xi__youwei-responded"]="宥围：此牌被响应，重铸一张非伤害牌或退出夕状态",
  ["#xi__youwei-nondamage"]="宥围：重铸一张非伤害牌",
  ["xi__youwei_exit"]="退出夕状态", ["xi__youwei_recast"]="重铸非伤害牌",
  ["#xi__juedu-recast"]="绝渡：重铸一张本回合进入弃牌堆且自身可重铸的牌，摸一张牌后将原牌置底",
  ["#xi__juedu-invoke"]="绝渡：弃置所有手牌和装备牌，本回合借用本回合进入弃牌堆的牌（无距离限制）",
  ["#xi__juedu-area"]="绝渡：废除一个区域至你下回合开始，本回合借用弃牌堆牌（无次数限制）",
  ["xi__juedu_hand"]="废除手牌区", ["xi__juedu_equip"]="废除装备区", ["xi__juedu_judge"]="废除判定区",
  ["hanqing_xi"]="夕", ["xi"]="夕", ["xi_state"]="夕",
  ["xi__chengong"]="夕陈宫", ["xi_state__chengong"]="夕陈宫",
  ["#xi__chengong"]="鹘鸠窃巢", ["#xi_state__chengong"]="栋才空负",
  ["designer:xi__chengong"]="头发好借好还", ["designer:xi_state__chengong"]="头发好借好还",
  ["illustrator:xi__chengong"]="小猫°", ["illustrator:xi_state__chengong"]="小猫°",
  ["@@hanqing_xi"]="夕状态",
  ["xi__mouzhi"]="谋智", ["xi__mouzhi_xi"]="谋智",
  [":xi__mouzhi"]="出牌阶段，你可以将一张手牌当任意普通锦囊牌使用，然后本回合你无法使用此颜色的牌；你的回合结束时，你可令一名本回合成为过锦囊牌目标的角色使用一张【杀】，若其未使用，你进入夕状态。",
  [":xi__mouzhi_xi"]="出牌阶段，你可以将一张手牌当任意普通锦囊牌使用，然后本回合你无法使用此花色的牌；你使用的锦囊牌被抵消时，你失去1点体力值或退出夕状态。",
  ["#xi__mouzhi"]="谋智：将一张手牌当普通锦囊使用，结算后本回合禁用此颜色",
  ["#xi__mouzhi_xi"]="谋智：将一张手牌当普通锦囊使用，结算后本回合禁用此花色",
  ["#xi__mouzhi-target"]="谋智：可令一名本回合成为过锦囊目标的角色使用【杀】，其未使用则你进入夕状态",
  ["#xi__mouzhi-slash"]="谋智：你可以使用一张【杀】",
  ["#xi__mouzhi-cancelled"]="谋智：锦囊被抵消，失去1点体力或退出夕状态",
  ["xi__mouzhi_losehp"]="失去1点体力", ["xi__mouzhi_leave"]="退出夕状态",
}
return extension

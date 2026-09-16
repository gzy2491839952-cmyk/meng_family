local M=require "packages.meng_family.pkg.weekly.tiandan"
local skill=fk.CreateSkill{name="hqtiandan__chimai",tags={Skill.Compulsory}}
skill:addEffect(fk.GameStart,{
 can_trigger=function(self,e,t,p,d)return p:hasSkill(skill.name)end,
 on_use=function(self,e,t,p,d)
  local room=p.room;room:setBanner(M.active,true);M.watch(room);M.update(room)
  room:setBanner("@hqtd_batch",2+(room:getBanner(M.boost)or 0))
 end,
})
skill:addEffect(fk.Damaged,{
 can_trigger=function(self,e,t,p,d)return t==p and p:hasSkill(skill.name)end,
 on_use=function(self,e,t,p,d)M.erupt(p,skill.name)end,
})
Fk:loadTranslationTable{
 ["hqtiandan__chimai"]="炽脉",
 [":hqtiandan__chimai"]="锁定技，游戏开始时，将牌堆转为“火焰山”形态：牌堆顶牌始终明置，且于你受到伤害后“爆发”。<br/><b>爆发：</b>亮出牌堆顶两张牌并重复此流程，直到牌堆顶牌不为红色或牌堆洗切。“爆发”结束后，你弃置至多X名角色各一张牌（X为亮出的黑色牌数），使用或获得亮出牌中一张红色牌。然后若亮出牌中有能造成火属性伤害的牌，你分配1点火焰伤害。",
 ["@hqtd_mountain"]="火焰山·顶牌",["@hqtd_batch"]="爆发·每段",["hqtd_empty"]="牌堆为空",
 ["hqtd_cards"]="亮出牌",["hqtd_use"]="使用一张红色牌",["hqtd_obtain"]="获得一张红色牌",
 ["#hqtd-discard"]="爆发：可选择至多%arg名角色，各弃置其一张牌",
 ["#hqtd-red"]="爆发：使用或获得一张亮出的红色牌",
 ["#hqtd-use-red"]="爆发：可使用一张亮出的红色牌；取消则改为获得",
 ["#hqtd-obtain-red"]="爆发：获得一张亮出的红色牌",
 ["#hqtd-fire"]="爆发：选择一名角色，对其造成1点火焰伤害",
 ["#hqtd-use-equip"]="锻骨：你可以使用一张本次爆发亮出的装备牌",
}
return skill

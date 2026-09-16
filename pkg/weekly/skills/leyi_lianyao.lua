local M=require "packages.meng_family.pkg.weekly.leyi"
local skill=fk.CreateSkill{name="hqleyi__lianyao",tags={Skill.Compulsory}}
skill:addEffect(fk.DamageInflicted,{
 global=true,
 can_trigger=function(self,e,t,p,d)
  if d.extra_data and d.extra_data.hq_lianyao then return false end
  local pair=M.flank(d.to)
  if not pair then return false end
  local holder=table.find(pair,function(q)return q:hasSkill(skill.name)end)
  return holder==p
 end,
 on_use=function(self,e,t,p,d)
  local pair=M.flank(d.to);if not pair then return end
  local source=p.room:askToChoosePlayers(p,{targets=pair,min_num=1,max_num=1,cancelable=false,skill_name=skill.name,prompt="#hqlianyao-source"})[1]
  d.from=source or p;d.damageType=M.light
  d.extra_data=d.extra_data or {};d.extra_data.hq_lianyao=true
 end,
})
Fk:loadTranslationTable{
 ["hqleyi__lianyao"]="连耀",
 [":hqleyi__lianyao"]="锁定技，被两名“神乐毅”围攻的角色即将受到的伤害改为来源为其中一名神乐毅的光属性伤害（由你选择来源）。<br>围攻：一名角色的上家与下家势力相同且与该角色不同。<br>光属性伤害：造成伤害后，来源可以明置受伤角色至多两张暗置手牌，或弃置其至多两张明置手牌。",
 ["#hqlianyao-source"]="连耀：选择两侧神乐毅中的一名，作为此次光伤害来源",
}
return skill

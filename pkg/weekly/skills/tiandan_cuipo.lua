local M=require "packages.meng_family.pkg.weekly.tiandan"
local skill=fk.CreateSkill{name="hqtiandan__cuipo",tags={Skill.Limited}}
skill:addEffect(fk.TurnStart,{
 can_trigger=function(self,e,t,p,d)
  return t==p and not d.turn_end and p:hasSkill(skill.name) and p:usedSkillTimes(skill.name,Player.HistoryGame)==0 and #M.areas(p)>0
 end,
 on_cost=function(self,e,t,p,d)return p.room:askToSkillInvoke(p,{skill_name=skill.name})end,
 on_use=function(self,e,t,p,d)
  p.room:setPlayerMark(p,"hqtd_repeats",2);M.sacrifice(p)
  if p:getMark("@hqtd_ember")>0 then d.turn_end=true;M.erupt(p,skill.name)end
 end,
})
Fk:loadTranslationTable{
 ["hqtiandan__cuipo"]="焠魄",
 [":hqtiandan__cuipo"]="限定技，回合开始时，你可废除一个区域，然后获得弃牌堆中一张火属性牌并令此后的“爆发”每段亮出牌数+1。你之后的两个回合开始时重复以上效果，废除所有区域后将你的回合改为令牌堆“爆发”。",
 ["hqtd_hand"]="废除手牌区",["hqtd_equip"]="废除装备区",["hqtd_judge"]="废除判定区",
 ["#hqtd-seal"]="焠魄：选择一个尚未废除的区域",
 ["#hqtd-obtain-fire"]="焠魄：获得弃牌堆中一张火属性牌",
 ["@hqtd_ember"]="残炬",
}
return skill

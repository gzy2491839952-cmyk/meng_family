local M=require "packages.meng_family.pkg.zhulv.tiandi"
local skill=fk.CreateSkill{name="dream__pianxiang"}
skill:addEffect("active",{
 min_card_num=0,max_card_num=999,target_num=1,max_phase_use_time=1,
 can_use=function(self,p)return p.phase==Player.Play and p:usedSkillTimes(skill.name,Player.HistoryPhase)==0 end,
 card_filter=function(self,p,id,selected)return table.contains(p:getCardIds("h"),id) and not M.revealed.shown(p,id)end,
 target_filter=function(self,p,to,selected)
  return #selected==0 and p:canUseTo(Fk:cloneCard("fire_attack"),to,{bypass_times=true})
 end,
 on_use=function(self,room,effect)
  local p=effect.from;local to=effect.tos[1]
  M.revealed.reveal(p,effect.cards or {},skill.name)
  if p.dead or not to or to.dead then return end
  local c=Fk:cloneCard("fire_attack");c.skillName=skill.name
  if p:canUseTo(c,to,{bypass_times=true})then room:useCard{from=p,tos={to},card=c,extraUse=true,extra_data={dream_pianxiang=true}}end
 end,
})
Fk:loadTranslationTable{
 ["dream__pianxiang"]="偏袭",
 [":dream__pianxiang"]="出牌阶段限一次，你可以明置任意张手牌并视为使用【火攻】，若展示牌与弃置牌明暗置状态不同，此牌伤害+1。",
}
return skill

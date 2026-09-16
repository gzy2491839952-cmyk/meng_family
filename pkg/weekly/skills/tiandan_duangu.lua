local M=require "packages.meng_family.pkg.weekly.tiandan"
local skill=fk.CreateSkill{name="hqtiandan__duangu"}
skill:addEffect("active",{
 card_num=0,target_num=1,
 can_use=function(self,p)return p:usedSkillTimes(skill.name,Player.HistoryPhase)==0 end,
 target_filter=function(self,p,q,selected)return #selected==0 and not q.dead and #q:getCardIds("hej")>0 end,
 on_use=function(self,room,e)
  local p=e.from;local q=e.tos[1]
  local id=room:askToChooseCard(p,{target=q,flag="hej",skill_name=skill.name})
  if not id then return end
  local c=Fk:getCardById(id);local erupt=M.fire(c) or c.type==Card.TypeEquip
  room:recastCard({id},q,skill.name)
  if erupt and not p.dead then M.erupt(p,skill.name,q)end
 end,
})
Fk:loadTranslationTable{
 ["hqtiandan__duangu"]="锻骨",
 [":hqtiandan__duangu"]="出牌阶段限一次，你可重铸任意角色的一张牌。若此牌为火属性牌或装备牌，则令牌堆“爆发”，然后该角色可使用一张此次亮出的装备牌。",
}
return skill

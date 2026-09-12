local M=require "packages.meng_family.pkg.changping.zhaokuo_dream"
local skill=fk.CreateSkill{name="dream__xiwei",tags={Skill.Quest}}
local function available(p)
 return not p:isKongcheng()
  and not table.find(p:getCardIds("h"),function(id)return p:prohibitDiscard(id)end)
end
skill:addEffect("viewas",{
 pattern=".",
 interaction=function(self,p)
  local all=M.damageNames();local names=p:getViewAsCardNames(skill.name,all)
  if #names>0 then return UI.CardNameBox{choices=names,all_choices=all}end
 end,
 card_filter=function()return false end,
 view_as=function(self,p,cards)
  if #cards>0 or not self.interaction.data then return end
  local c=Fk:cloneCard(self.interaction.data);c.skillName=skill.name;return c
 end,
 enabled_at_play=function(self,p)
  return p.phase==Player.Play and available(p) and p:usedSkillTimes(skill.name,Player.HistoryPhase)==0
 end,
 enabled_at_response=function()return false end,
 before_use=function(self,p,use)
  if not available(p)then return skill.name end
  local ids=table.simpleClone(p:getCardIds("h"))
  use.extra_data=use.extra_data or {};use.extra_data.dream_xiwei_owner=p.id
  p.room:throwCard(ids,skill.name,p,p)
  if p.dead then return skill.name end
 end,
})
skill:addEffect(fk.Death,{
 can_trigger=function(self,event,target,p,data)
  if not p:hasSkill(skill.name) or p:getQuestSkillState(skill.name)~=nil or not data.damage then return false end
  local damage=data.damage
  if damage.from~=p or not damage.card then return false end
  local use=p.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
  return use and use.data.card==damage.card and use.data.extra_data and use.data.extra_data.dream_xiwei_owner==p.id
 end,
 on_cost=function()return true end,
 on_use=function(self,event,target,p,data)
  p.room:updateQuestSkillState(p,skill.name,false)
  p.room:handleAddLoseSkills(p,"dream__yiqi")
 end,
})
skill:addEffect(fk.TurnEnd,{
 can_trigger=function(self,event,target,p,data)
  return p:hasSkill(skill.name) and p:getQuestSkillState(skill.name)==nil and #p:getPile(M.pile)>=5
 end,
 on_cost=function()return true end,
 on_use=function(self,event,target,p,data)
  local room=p.room;room:updateQuestSkillState(p,skill.name,true)
  local ids=table.simpleClone(p:getPile(M.pile));local current=target or room.current
  for _,id in ipairs(ids)do
   if p.dead or not current or current.dead then break end
   if table.contains(p:getPile(M.pile),id)then
    local c=Fk:cloneCard(Fk:getCardById(id,true).name);c.skillName=skill.name
    if current:canUseTo(c,p,{bypass_times=true})then
     room:useCard{from=current,tos={p},card=c,extraUse=true,extra_data={dream_xiwei_failure=true}}
    end
   end
  end
  local rest=table.filter(ids,function(id)return table.contains(p:getPile(M.pile),id)end)
  if #rest>0 then room:moveCardTo(rest,Card.DiscardPile,nil,fk.ReasonPutIntoDiscardPile,skill.name,nil,true)end
 end,
})
Fk:loadTranslationTable{
 ["dream__xiwei"]="袭围",
 [":dream__xiwei"]="使命技，出牌阶段限一次，你可以弃置所有手牌并视为使用一张伤害牌。<br/>成功：当有角色因此死亡，你获得【刈旗】。<br/>失败：你成功达成使命前，因【披矢】置于武将牌上的牌不少于5，本回合结束时，当前回合角色依次视为对你使用这些牌，然后你将这些牌置入弃牌堆。",
}
return skill

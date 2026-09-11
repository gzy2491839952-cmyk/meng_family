local skill=fk.CreateSkill{name="weekly__jianmei"}
local heal="weekly_jianmei_heal-turn"
skill:addEffect(fk.CardUseFinished,{
 can_trigger=function(self,event,target,player,data)
  return target==player and player:hasSkill(skill.name) and data.card.trueName=="slash"
    and table.find(data.tos,function(p)return p~=player and not p.dead and (not p:isNude() or not player:isNude())end)~=nil
 end,
 on_cost=function(self,event,target,player,data)
  local targets=table.filter(data.tos,function(p)return p~=player and not p.dead and (not p:isNude() or not player:isNude())end)
  local to=player.room:askToChoosePlayers(player,{targets=targets,min_num=1,max_num=1,
   skill_name=skill.name,cancelable=true,prompt="#weekly__jianmei-target"})[1]
  if to then event:setCostData(self,{to=to});return true end
 end,
 on_use=function(self,event,target,player,data)
  local room=player.room;local to=event:getCostData(self).to
  local candidates=table.filter({player,to},function(p)return not p.dead and not p:isNude()end)
  local who=room:askToChoosePlayers(player,{targets=candidates,min_num=1,max_num=1,
   skill_name=skill.name,cancelable=false,prompt="#weekly__jianmei-discard"})[1]
  if not who then return end
  local ids=table.filter(who:getCardIds("he"),function(id)return not player:prohibitDiscard(id)end)
  if #ids==0 then return end
  local id=room:askToChooseCards(player,{target=who,flag="he",min=1,max=1,
   skill_name=skill.name,pattern=tostring(Exppattern{id=ids}),cancelable=false})[1]
  if not id then return end
  room:throwCard({id},skill.name,who,player)
  local other=who==player and to or player
  if who.dead or other.dead then return end
  local card=Fk:cloneCard("changping__sincere_treat");card.skillName=skill.name
  if not who:canUseTo(card,other,{bypass_distances=true,bypass_times=true})then return end
  room:useCard{from=who,tos={other},card=card,extraUse=true,
   extra_data={weekly_jianmei_owner=player.id,weekly_jianmei_pair={who.id,other.id},bypass_distances=true}}
 end,
})
local function context(player)
 local e=player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard,true)
 local use=e and e.data
 if use and use.extra_data and use.extra_data.weekly_jianmei_owner==player.id then return use.extra_data end
end
local function hearts(player,data,ctx)
 local results={}
 for _,m in ipairs(data)do
  if m.to and m.toArea==Card.PlayerHand and table.contains(ctx.weekly_jianmei_pair,m.to.id)then
   for _,i in ipairs(m.moveInfo)do
    if Fk:getCardById(i.cardId).suit==Card.Heart then
     table.insert(results,{who=m.to,id=i.cardId})
    end
   end
  end
 end
 return results
end
skill:addEffect(fk.AfterCardsMove,{
 global=true,
 can_trigger=function(self,event,target,player,data)
  local ctx=context(player)
  return not player.dead and player:getMark(heal)==0 and ctx and #hearts(player,data,ctx)>0
 end,
 on_cost=function(self,event,target,player,data)
  local ctx=context(player);if not ctx then return false end
  for _,r in ipairs(hearts(player,data,ctx))do
   local other=player.room:getPlayerById(ctx.weekly_jianmei_pair[1]==r.who.id and ctx.weekly_jianmei_pair[2] or ctx.weekly_jianmei_pair[1])
   if not r.who.dead and not other.dead and other:isWounded() and table.contains(r.who:getCardIds("h"),r.id)
    and player.room:askToSkillInvoke(r.who,{skill_name=skill.name,prompt="#weekly__jianmei-heal::"..other.id})then
    event:setCostData(self,{who=r.who,to=other,id=r.id});return true
   end
  end
 end,
 on_use=function(self,event,target,player,data)
  local r=event:getCostData(self)
  player.room:setPlayerMark(player,heal,1)
  r.who:showCards({r.id})
  if not r.to.dead then player.room:recover{who=r.to,num=1,recoverBy=r.who,skillName=skill.name}end
 end,
})
Fk:loadTranslationTable{
 ["weekly__jianmei"]="谏昧",
 [":weekly__jianmei"]="你使用【杀】结算结束后，可弃置你或目标角色一张牌，令弃置牌的角色视为对对方使用一张【推心置腹】。每回合限一次，有角色因此获得红桃牌时可展示之并令对方回复1点体力。",
 ["#weekly__jianmei-target"]="谏昧：选择此次杀的一名目标",
 ["#weekly__jianmei-discard"]="谏昧：选择弃置谁的一张牌，该角色对另一人使用推心置腹",
 ["#weekly__jianmei-heal"]="谏昧：展示获得的红桃牌，令 %dest 回复1点体力？",
}
return skill

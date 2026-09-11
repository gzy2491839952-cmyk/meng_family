local skill=fk.CreateSkill{name="weekly__zaowei"}
local mark="weekly_zaowei_suits-turn"
local function canRecast(player)
 return player:hasSkill(skill.name) and #player:getCardIds("he")>=3
end
local function cost(self,event,target,player,data)
 local ids=player.room:askToCards(player,{min_num=3,max_num=3,include_equip=true,cancelable=true,
  skill_name=skill.name,prompt="#weekly__zaowei-recast"})
 if #ids==3 then event:setCostData(self,{cards=ids});return true end
end
local function recast(self,event,target,player,data)
 local room=player.room
 local ids=event:getCostData(self).cards
 local count={}
 for _,id in ipairs(ids)do
  local suit=Fk:getCardById(id).suit
  if suit~=Card.NoSuit then count[suit]=(count[suit] or 0)+1 end
 end
 local repeats={}
 for suit,n in pairs(count)do if n>=2 then table.insert(repeats,suit)end end
 -- Register before the recast: nested card uses caused by losing/drawing cards count too.
 if #repeats==1 then
  local suits=player:getTableMark(mark)
  table.insertIfNeed(suits,repeats[1])
  room:setPlayerMark(player,mark,suits)
  local symbols={}
  for _,entry in ipairs{{Card.Spade,"♠"},{Card.Heart,"♥"},{Card.Club,"♣"},{Card.Diamond,"♦"}}do
   if table.contains(suits,entry[1])then table.insert(symbols,entry[2])end
  end
  room:setPlayerMark(player,"@weekly_zaowei-turn",table.concat(symbols," "))
 end
 room:recastCard(ids,player,skill.name)
end
skill:addEffect(fk.HpChanged,{
 anim_type="drawcard",
 audio_index={1,2},
 can_trigger=function(self,event,target,player,data)
  return target==player and canRecast(player) and data.num~=0 and not data.prevented
   and not(data.damageEvent and data.damageEvent.isVirtualDMG)
 end,
 on_cost=cost,on_use=recast,
})
-- Max-HP reduction can clamp HP without emitting HpChanged.
skill:addEffect(fk.BeforeMaxHpChanged,{
 can_refresh=function(self,event,target,player,data)return target==player end,
 on_refresh=function(self,event,target,player,data)data.weekly_zaowei_old_hp=player.hp end,
})
skill:addEffect(fk.MaxHpChanged,{
 anim_type="drawcard",
 audio_index={1,2},
 can_trigger=function(self,event,target,player,data)
  return target==player and canRecast(player) and data.weekly_zaowei_old_hp~=nil and data.weekly_zaowei_old_hp~=player.hp
 end,
 on_cost=cost,on_use=recast,
})
skill:addEffect(fk.CardUsing,{
 anim_type="control",
 audio_index={1,2},
 can_trigger=function(self,event,target,player,data)
  return player:hasSkill(skill.name) and table.contains(player:getTableMark(mark),data.card.suit)
   and table.find(player.room.alive_players,function(p)return not p:isNude()end)~=nil
 end,
 on_cost=function()return true end,
 on_use=function(self,event,target,player,data)
  local room=player.room
  local suit=data.card.suit
  local useEvent=room.logic:getCurrentEvent():findParent(GameEvent.UseCard,true)
  local tos=room:askToChoosePlayers(player,{targets=table.filter(room.alive_players,function(p)return not p:isNude()end),
   min_num=1,max_num=1,cancelable=false,skill_name=skill.name,prompt="#weekly__zaowei-discard"})
  if #tos==0 then return end
  local to=tos[1]
  local id=room:askToChooseCard(player,{target=to,flag="he",skill_name=skill.name})
  if not id then return end
  local matches=Fk:getCardById(id).suit==suit
  room:throwCard({id},skill.name,to,player)
  if matches and useEvent then
   useEvent:addExitFunc(function()
    if player.dead or room:getCardArea(id)~=Card.DiscardPile then return end
    room:askToUseRealCard(player,{pattern={id},expand_pile={id},skill_name=skill.name,cancelable=true,
     extra_data={bypass_distances=true,bypass_times=true,extraUse=true},prompt="#weekly__zaowei-use"})
   end)
  end
 end,
})
Fk:loadTranslationTable{
 ["$weekly__zaowei1"]="此刻予汝，来日要汝连城以偿！",
 ["$weekly__zaowei2"]="函谷虽险，亦难阻齐军！",
 ["weekly__zaowei"]="凿威",
 ["@weekly_zaowei-turn"]="凿威",
 [":weekly__zaowei"]="当你体力值变化后，你可以重铸三张牌。若其中仅有一种重复的花色，本回合有此花色的牌被使用时，你弃置一名角色一张牌。若弃置的牌仍为此花色，你可以于该次用牌全部结算结束后使用此牌（无距离限制）。",
 ["#weekly__zaowei-recast"]="凿威：你可以重铸三张手牌或装备牌",
 ["#weekly__zaowei-discard"]="凿威：选择一名角色，弃置其一张牌",
 ["#weekly__zaowei-use"]="凿威：你可以使用这张弃牌（无距离限制）",
}
return skill

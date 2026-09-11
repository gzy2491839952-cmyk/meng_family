local skill=fk.CreateSkill{name="weekly__jieming"}
local shown="@weekly_jieming_shown"
local used="weekly_jieming_used-round"
local function names(player)
 return player:getViewAsCardNames(skill.name,Fk:getAllCardNames("bt"))
end
local function eligible(player,id,name)
 local c=Fk:getCardById(id)
 return name and table.contains(player:getCardIds("h"),id) and c:getMark(shown)==0
   and c.type==Fk:cloneCard(name).type
end
skill:addEffect("viewas",{
 audio_index={1,2},
 pattern=".|.|.|.|.|basic,trick",
 prompt="#weekly__jieming",
 interaction=function(self,player)
  local choices=table.filter(names(player),function(n)
    return table.find(player:getCardIds("h"),function(id)return eligible(player,id,n)end)~=nil
  end)
  if #choices>0 then return UI.CardNameBox{choices=choices,all_choices=Fk:getAllCardNames("bt")}end
 end,
 card_filter=function(self,player,to_select,selected)
  return #selected==0 and eligible(player,to_select,self.interaction.data)
 end,
 view_as=function(self,player,cards)
  if #cards~=1 or not eligible(player,cards[1],self.interaction.data)then return end
  local c=Fk:cloneCard(self.interaction.data);c.skillName=skill.name
  c:addFakeSubcard(cards[1])
  return c
 end,
 enabled_at_play=function(self,player)return player:getMark(used)==0 and not player:isKongcheng()end,
 enabled_at_response=function(self,player,response)
  return not response and player:getMark(used)==0 and not player:isKongcheng()
 end,
 before_use=function(self,player,use)
  local id=(use.card.fake_subcards or {})[1]
  if player:getMark(used)>0 or not id or not eligible(player,id,use.card.name)then return skill.name end
  local room=player.room
  room:setPlayerMark(player,used,1)
  room:setCardMark(Fk:getCardById(id),shown,player.id)
  player:showCards({id})
 end,
})
skill:addEffect("visibility",{
 card_visible=function(self,viewer,card)
  local owner=card:getMark(shown)
  if owner==0 then return end
  local room=Fk:currentRoom();local p=room:getCardOwner(card.id)
  if p and p.id==owner and room:getCardArea(card.id)==Card.PlayerHand then return true end
 end,
})
skill:addEffect(fk.AfterCardsMove,{
 audio_index=0,
 global=true,
 can_refresh=function(self,event,target,player,data)
  return table.find(data,function(move)
   return move.from==player and table.find(move.moveInfo,function(info)
    return info.fromArea==Card.PlayerHand and Fk:getCardById(info.cardId):getMark(shown)==player.id
   end)
  end)~=nil
 end,
 on_refresh=function(self,event,target,player,data)
  local lost={}
  for _,move in ipairs(data)do
   if move.from==player then
    for _,info in ipairs(move.moveInfo)do
     local card=Fk:getCardById(info.cardId)
     if info.fromArea==Card.PlayerHand and card:getMark(shown)==player.id then
      player.room:setCardMark(card,shown,0)
      table.insertIfNeed(lost,info.cardId)
     end
    end
   end
  end
  -- Capture before clearing; no stale tracking after a transfer or a nested move.
  event:setSkillData(self,"weekly_jieming_lost_"..player.id,lost)
 end,
 can_trigger=function(self,event,target,player,data)
  return player:hasSkill(skill.name) and not player.dead
   and #(event:getSkillData(self,"weekly_jieming_lost_"..player.id)or{})>0
 end,
 on_cost=function()return true end,
 on_use=function(self,event,target,player,data)
  for _ in ipairs(event:getSkillData(self,"weekly_jieming_lost_"..player.id)or{})do
   if player.dead then break end
   player:drawCards(2,skill.name)
   if not player.dead and player:getHandcardNum()<=player.maxHp then
    player.room:setPlayerMark(player,used,0)
   end
  end
 end,
})
Fk:loadTranslationTable{
 ["weekly__jieming"]="藉命",
 [":weekly__jieming"]="每轮限一次，当你需要使用基本牌或普通锦囊牌时，你可以明置一张同类型牌视为使用之；当你失去此牌时，你摸两张牌，若此时你手牌数不大于体力上限，重置此技能使用次数。",
 ["#weekly__jieming"]="藉命：明置一张同类型手牌，视为使用所选牌（明置牌不消耗）",
 [shown]="藉命明置",
}
return skill

local skill=fk.CreateSkill{name="weekly__suiwan"}
local used="weekly_suiwan_used-phase"
local pending="weekly_suiwan_pending-phase"
local function eligible(player,data)
 local gain,loss={},{}
 for _,m in ipairs(data)do
  if m.to==player and m.from~=player then
   for _,i in ipairs(m.moveInfo)do table.insertIfNeed(gain,i.cardId)end
  end
  if m.from==player and m.to~=player then
   for _,i in ipairs(m.moveInfo)do table.insertIfNeed(loss,i.cardId)end
  end
 end
 local ids={}
 for _,list in ipairs({gain,loss})do
  if #list>=2 then
   for _,id in ipairs(list)do
    local c=Fk:getCardById(id)
    if c.type==Card.TypeBasic or c:isCommonTrick() then table.insertIfNeed(ids,id)end
   end
  end
 end
 return ids
end
skill:addEffect(fk.AfterCardsMove,{
 can_trigger=function(self,event,target,player,data)
  return player:hasSkill(skill.name) and player:getMark(used)==0
   and player.room.current and player.room.current.phase~=Player.NotActive and #eligible(player,data)>0
 end,
 on_cost=function(self,event,target,player,data)
  local ids=eligible(player,data)
  local picked=player.room:askToChooseCards(player,{target=player,
   flag={card_data={{skill.name,ids}}},min=1,max=1,skill_name=skill.name,
   cancelable=true,prompt="#weekly__suiwan-show"})
  if #picked>0 then event:setCostData(self,{cards=picked});return true end
 end,
 on_use=function(self,event,target,player,data)
  local id=event:getCostData(self).cards[1]
  local room=player.room
  room:setPlayerMark(player,used,1)
  room:setPlayerMark(player,pending,Fk:getCardById(id).name)
  player:showCards({id})
 end,
})
skill:addEffect(fk.EventPhaseEnd,{
 global=true,
 can_refresh=function(self,event,target,player,data)return player:getMark(pending)~=0 end,
 on_refresh=function(self,event,target,player,data)
  local name=player:getMark(pending)
  player.room:setPlayerMark(player,pending,0)
  if not player.dead then
   player.room:askToUseVirtualCard(player,{name=name,skill_name=skill.name,cancelable=false,
    extra_data={bypass_times=true,bypass_distances=true,extraUse=true},prompt="#weekly__suiwan-use"})
  end
 end,
})
-- Virtual axe: preserve the real weapon slot and its effects.
skill:addEffect("atkrange",{
 virtual_weapon_func=function(self,player)if player:hasSkill(skill.name)then return 3 end end,
})
skill:addEffect(fk.CardEffectCancelledOut,{
 can_trigger=function(self,event,target,player,data)
  return player:hasSkill(skill.name) and data.from==player and data.card.trueName=="slash"
    and not data.to.dead and data.isCancellOut~=false and #player:getCardIds("he")>1
    and not table.find(player:getEquipments(Card.SubtypeWeapon),function(id)
      return (player:getVirtualEquip(id) or Fk:getCardById(id)).name=="axe"
    end)
 end,
 on_cost=function(self,event,target,player,data)
  local ids=table.filter(player:getCardIds("he"),function(id)
   return not player:prohibitDiscard(id) and not(table.contains(player:getEquipments(Card.SubtypeWeapon),id)
    and (player:getVirtualEquip(id) or Fk:getCardById(id)).name=="axe")
  end)
  if #ids<2 then return false end
  local cards=player.room:askToDiscard(player,{min_num=2,max_num=2,include_equip=true,
   skill_name=skill.name,cancelable=true,pattern=tostring(Exppattern{id=ids}),prompt="#axe-invoke::"..data.to.id,skip=true})
  if #cards==2 then event:setCostData(self,{cards=cards});return true end
 end,
 on_use=function(self,event,target,player,data)
  player.room:throwCard(event:getCostData(self).cards,skill.name,player,player)
  data.isCancellOut=false;data.disresponsive=true
 end,
})
Fk:loadTranslationTable{
 ["weekly__suiwan"]="碎顽",
 [":weekly__suiwan"]="你视为装备着【贯石斧】；每阶段限一次，你一次性得到或失去至少两张牌后，你可以展示其中一张基本牌或普通锦囊牌，于本阶段结束时视为使用之（无次数距离限制）。",
 ["#weekly__suiwan-show"]="碎顽：展示其中一张基本牌或普通锦囊牌，阶段结束时视为使用",
 ["#weekly__suiwan-use"]="碎顽：视为使用记录的牌（无次数、距离限制）",
}
return skill

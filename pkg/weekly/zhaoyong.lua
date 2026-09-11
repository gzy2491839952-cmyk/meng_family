local M={}
M.name="weekly__yifu"
M.slots={Card.SubtypeWeapon,Card.SubtypeArmor,Card.SubtypeDefensiveRide,Card.SubtypeOffensiveRide,Card.SubtypeTreasure}
function M.equip(id,subtype)
 local c=Fk:cloneCard("weekly__yifu_slot"..subtype)
 c:addSubcard(id);c.skillName=M.name
 return c
end
function M.slotsFor(player,id)
 return table.filter(M.slots,function(subtype)return player:canMoveCardIntoEquip(M.equip(id,subtype),true)end)
end
function M.basics(player)
 return table.filter(player:getCardIds("h"),function(id)
  return Fk:getCardById(id).type==Card.TypeBasic and #M.slotsFor(player,id)>0
 end)
end
-- An entry qualifies only when its actual discard entry came from Zhao Yong.
-- Re-check the current area: retrieved cards are no longer in the central area.
function M.slashes(player)
 local records={};local room=player.room
 room.logic:getEventsOfScope(GameEvent.MoveCards,1,function(e)
  for _,m in ipairs(e.data)do
   if m.toArea==Card.DiscardPile then
    local response=e.findParent and e:findParent(GameEvent.RespondCard,true)
    for _,i in ipairs(m.moveInfo)do
     local own=m.from==player
     if not m.from and i.fromArea==Card.Processing and m.moveReason==fk.ReasonResponse
       and response and response.data.from==player then
      own=table.contains(Card:getIdList(response.data.card),i.cardId)
      if response.data.subcardsFromInfo then
       own=table.find(response.data.subcardsFromInfo,function(info)
        return info.cardId==i.cardId and info.from==player
       end)~=nil
      end
     end
     local old=records[i.cardId]
     if not old or old.event<=(e.id or 0)then
      records[i.cardId]={event=e.id or 0,eligible=own and m.moveReason~=fk.ReasonUse}
     end
    end
   end
  end
  return false
 end,Player.HistoryTurn)
 local ids={}
 for id,r in pairs(records)do
  if r.eligible and room:getCardArea(id)==Card.DiscardPile and Fk:getCardById(id).trueName=="slash"then
   table.insert(ids,id)
  end
 end
 table.sort(ids)
 return ids
end
function M.matching(player,card)
 if not card or card.type~=Card.TypeBasic then return {}end
 return table.filter(player:getCardIds("e"),function(id)
  return Fk:getCardById(id,true).trueName==card.trueName
 end)
end
return M

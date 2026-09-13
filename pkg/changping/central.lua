local M = {}
-- Current-turn discard entries, deduplicated and filtered by current area.
-- Querying history also handles gaining the skill midway through a turn.
function M.cards(room)
  local ids, seen = {}, {}
  local consumed=room:getTag("hqcentral_consumed") or {}
  local removed=room:getTag("hqcentral_removed") or {}
  for _,id in ipairs(M.fixed(room))do table.insert(ids,id);seen[id]=true end
  room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
    for _, move in ipairs(e.data) do
      if move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          local id = info.cardId
          if not seen[id] and not consumed[id] and e.id>(removed[id] or 0) and room:getCardArea(id) == Card.DiscardPile then
            seen[id] = true
            table.insert(ids, id)
          end
        end
      end
    end
    return false -- Visit all moves, not just the first matching event.
  end, Player.HistoryTurn)
  return ids
end
function M.conditions(player, card)
  local ids = M.cards(player.room)
  local sameSuit = false
  if card.suit ~= Card.NoSuit then
    for _, id in ipairs(ids) do
      if Fk:getCardById(id).suit == card.suit then
        sameSuit = true
        break
      end
    end
  end
  return { sameSuit = sameSuit, lowHand = player:getHandcardNum() <= #ids }
end
function M.fixed(room)
 return table.filter(room:getTag("hqcentral_fixed") or {},function(id)return room:getCardArea(id)==Card.DiscardPile end)
end
function M.remove(room,ids)
 local removed=room:getTag("hqcentral_removed") or {};local fixed=M.fixed(room)
 local cutoff=room.logic:getCurrentEvent().id
 room.logic:getEventsOfScope(GameEvent.MoveCards,1,function(e)cutoff=math.max(cutoff,e.id);return false end,Player.HistoryTurn)
 for _,id in ipairs(ids)do removed[id]=cutoff;table.removeOne(fixed,id);room:setCardMark(Fk:getCardById(id),"@hqfixed",0)end
 room:setTag("hqcentral_removed",removed);room:setTag("hqcentral_fixed",fixed)
end
function M.fix(room,ids)
 local fixed=M.fixed(room)
 for _,id in ipairs(ids)do table.insertIfNeed(fixed,id);room:setCardMark(Fk:getCardById(id),"@hqfixed",1)end
 room:setTag("hqcentral_fixed",fixed)
end
return M

local M = {}
-- Current-turn discard entries, deduplicated and filtered by current area.
-- Querying history also handles gaining the skill midway through a turn.
function M.cards(room)
  local ids, seen = {}, {}
  room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
    for _, move in ipairs(e.data) do
      if move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          local id = info.cardId
          if not seen[id] and room:getCardArea(id) == Card.DiscardPile then
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
return M

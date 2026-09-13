local M={}
function M.losses(room)
 local map={};local lost={}
 room.logic:getEventsOfScope(GameEvent.MoveCards,1,function(e)
  for _,move in ipairs(e.data)do
   local from=move.from
   if from and not(move.to==from and (move.toArea==Card.PlayerHand or move.toArea==Card.PlayerEquip or move.toArea==Card.PlayerJudge))then
    for _,info in ipairs(move.moveInfo)do
     if info.fromArea==Card.PlayerHand or info.fromArea==Card.PlayerEquip or info.fromArea==Card.PlayerJudge then
      map[info.cardId]=map[info.cardId] or {};table.insertIfNeed(map[info.cardId],from);lost[from]=true
     end
    end
   end
  end
  return false
 end,Player.HistoryTurn)
 return map,lost
end
return M

local C=require "packages.meng_family.pkg.changping.central"
local skill=fk.CreateSkill{name="hqgod_central"}
skill:addEffect(fk.AfterCardsMove,{
 global=true,can_refresh=function(self,e,t,p,d)return p==p.room.players[1]end,
 on_refresh=function(self,e,t,p,d)
  local room=p.room;local fixed=room:getTag("hqcentral_fixed") or {}
  local consumed=room:getTag("hqcentral_consumed") or {}
  for _,move in ipairs(d)do
   for _,info in ipairs(move.moveInfo)do
    if info.fromArea==Card.DiscardPile and move.moveReason==fk.ReasonUse then consumed[info.cardId]=true
    elseif move.toArea==Card.DiscardPile and move.moveReason~=fk.ReasonUse then consumed[info.cardId]=nil end
   end
   if move.toArea~=Card.DiscardPile then
    for _,info in ipairs(move.moveInfo)do
     if table.contains(fixed,info.cardId)then table.removeOne(fixed,info.cardId);room:setCardMark(Fk:getCardById(info.cardId),"@hqfixed",0)end
    end
   end
  end
  room:setTag("hqcentral_fixed",fixed);room:setTag("hqcentral_consumed",consumed)
 end,
})
skill:addEffect(fk.TurnEnd,{
 global=true,can_refresh=function(self,e,t,p,d)return p==p.room.players[1]end,
 on_refresh=function(self,e,t,p,d)
  local room=p.room
  room.logic:getCurrentEvent():addExitFunc(function()
   local fixed=C.fixed(room)
   C.remove(room,table.filter(C.cards(room),function(id)return not table.contains(fixed,id)end))
  end)
 end,
})
Fk:loadTranslationTable{["hqgod_central"]="中央区规则",["@hqfixed"]="固定"}
return skill

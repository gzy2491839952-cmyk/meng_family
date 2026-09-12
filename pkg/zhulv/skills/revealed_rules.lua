local M=require "packages.meng_family.pkg.zhulv.revealed"
local skill=fk.CreateSkill{name="zhulv__revealed_rules"}
skill:addEffect("visibility",{
 global=true,
 card_visible=function(self,viewer,card)
  local room=Fk:currentRoom();local owner=room:getCardOwner(card.id)
  if owner and room:getCardArea(card.id)==Card.PlayerHand and card:getMark(M.mark)==owner.id then return true end
 end,
})
skill:addEffect(fk.AfterCardsMove,{
 global=true,
 can_refresh=function(self,event,target,player,data)
  return table.find(data,function(m)
   return m.from==player and not(m.to==player and m.toArea==Card.PlayerHand) and table.find(m.moveInfo,function(i)
    return i.fromArea==Card.PlayerHand and Fk:getCardById(i.cardId):getMark(M.mark)==player.id
   end)
  end)~=nil
 end,
 on_refresh=function(self,event,target,player,data)
  for _,m in ipairs(data)do
   if m.from==player and not(m.to==player and m.toArea==Card.PlayerHand)then
    for _,i in ipairs(m.moveInfo)do
     local c=Fk:getCardById(i.cardId)
     if i.fromArea==Card.PlayerHand and c:getMark(M.mark)==player.id then player.room:setCardMark(c,M.mark,0)end
    end
   end
  end
 end,
})
Fk:loadTranslationTable{["zhulv__revealed_rules"]="珠履明置规则"}
return skill

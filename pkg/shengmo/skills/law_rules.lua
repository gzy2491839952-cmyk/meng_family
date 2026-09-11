local U=require "packages.meng_family.pkg.shengmo.law"
local skill=fk.CreateSkill{name="#shengmo_law_rules"}
-- A law card is never a playable card, but may be discarded, given or stolen.
skill:addEffect("prohibit",{
 prohibit_use=function(self,player,card)return card.name==U.book end,
 prohibit_response=function(self,player,card)return card.name==U.book end,
})
skill:addEffect("visibility",{
 card_visible=function(self,viewer,card)
   if card.name==U.book then return true end
 end,
})
skill:addEffect(fk.BeforeCardsMove,{
 global=true,
 can_refresh=function(self,event,target,player,data)return not event:getSkillData(self,"law_redirected") end,
 on_refresh=function(self,event,target,player,data)
   event:setSkillData(self,"law_redirected",true)
   local extra={}
   for _,move in ipairs(data) do
     local keep,removed={},{}
     for _,info in ipairs(move.moveInfo) do
       local c=Fk:getCardById(info.cardId,true)
       local origin=c:getMark(U.owner)
       if c.name==U.book and origin~=0 and move.from and move.from.id==origin
         and info.fromArea==Card.PlayerHand
         and not (move.to==move.from and move.toArea==Card.PlayerHand) then
         table.insert(removed,info)
       else table.insert(keep,info) end
     end
     if #removed>0 then
       move.moveInfo=keep
       table.insert(extra,{moveInfo=removed,from=move.from,toArea=Card.Void,moveReason=move.moveReason,
         skillName=move.skillName,proposer=move.proposer,moveVisible=true})
     end
   end
   for _,m in ipairs(extra) do table.insert(data,m) end
 end,
})
skill:addEffect(fk.AfterCardsMove,{
 global=true,
 can_refresh=function(self,event,target,player,data)return not event:getSkillData(self,"law_ordered") end,
 on_refresh=function(self,event,target,player,data)
   event:setSkillData(self,"law_ordered",true)
   local room=player.room
   for _,p in ipairs(room.players) do
     local book=U.holderBook(p)
     if not book then
       if p:getMark(MarkEnum.SortProhibited..U.lock)~=0 then room:unbanSortingHandcards(p,U.lock) end
     else
       local hand=p:getCardIds("h");local left={};local rest={}
       for _,id in ipairs(hand) do
         local card=Fk:getCardById(id,true)
         if card:getMark(U.left)==p.id then table.insert(left,id);room:setCardMark(card,U.left,0)
         else table.insert(rest,id) end
       end
       if #left>0 then
         local order={}
         for _,id in ipairs(rest) do
           if id==book then for _,cid in ipairs(left) do table.insert(order,cid) end end
           table.insert(order,id)
         end
         U.sync(p,order)
       end
     end
   end
   for _,move in ipairs(data) do for _,info in ipairs(move.moveInfo) do
     local c=Fk:getCardById(info.cardId,true)
     if c.name==U.book and room:getCardArea(info.cardId)==Card.Void then room:setCardMark(c,U.owner,0) end
     if c:getMark(U.left)~=0 then room:setCardMark(c,U.left,0) end
   end end
 end,
})
skill:addEffect(fk.PreCardUse,{
 global=true,
 can_refresh=function(self,event,target,player,data)return target==player and U.holderBook(player)~=nil end,
 on_refresh=function(self,event,target,player,data)
   data.extra_data=data.extra_data or {}
   data.extra_data.shengmo_law=U.snapshot(player,data.card)
 end,
})
skill:addEffect(fk.CardUsing,{
 global=true,audio_index=0,
 can_refresh=function(self,event,target,player,data)
   return target==player and data.extra_data and data.extra_data.shengmo_law~=nil
     and not data.extra_data.shengmo_law_done
 end,
 on_refresh=function(self,event,target,player,data)
   data.extra_data.shengmo_law_done=true
   U.apply(player,data,data.extra_data.shengmo_law)
 end,
})
-- Also nullify uses aimed at cards (Nullification etc.), which have no player target.
skill:addEffect(fk.PreCardEffect,{
 global=true,
 can_refresh=function(self,event,target,player,data)
   return target==player and data.extra_data and data.extra_data.shengmo_law_nullified
 end,
 on_refresh=function(self,event,target,player,data)data.nullified=true end,
})
-- The engine ignores additionalEffect for responses aimed at a card. Repeat
-- that one effect explicitly, with a guard so the copy cannot repeat itself.
skill:addEffect(fk.CardEffectFinished,{
 global=true,
 can_refresh=function(self,event,target,player,data)
   return data.from==player and data.toCard~=nil and data.use and data.use.extra_data
     and data.use.extra_data.shengmo_law and data.use.extra_data.shengmo_law.mode=="repeat"
     and not data.use.extra_data.shengmo_law_response_repeated
 end,
 on_refresh=function(self,event,target,player,data)
   data.use.extra_data.shengmo_law_response_repeated=true
   -- doCardEffect expects a CardEffectData instance, not a plain table.
   -- Construct a fresh effect so cancellation state from the first resolution
   -- is not reused, while preserving the enclosing use and response target.
   player.room:doCardEffect(CardEffectData:new{
     from=data.from,tos=data.tos,subTos=data.subTos,card=data.card,toCard=data.toCard,use=data.use,
     responseToEvent=data.responseToEvent,extra_data=data.extra_data,
     additionalDamage=data.additionalDamage,additionalRecover=data.additionalRecover,
     cardsResponded=data.cardsResponded,prohibitedCardNames=data.prohibitedCardNames,
   })
 end,
})
return skill

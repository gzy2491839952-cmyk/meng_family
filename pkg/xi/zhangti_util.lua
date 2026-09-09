-- SPDX-License-Identifier: GPL-3.0-or-later
local M={seen='xi__juedu_seen-turn',modes='xi__juedu_modes-turn',restore='xi__juedu_restore'}
function M.mentionsSlash(card)
  if card.trueName=='slash' then return true end
  local text=Fk:translate(card.name,'zh_CN')..Fk:translate(':'..card.name,'zh_CN')
  text=text:gsub('<[^>]*>','')
  return text:find('【杀】',1,true)~=nil
end
function M.change(player,enabled)
  local room=player.room
  if player.dead or (player:getMark('@@hanqing_xi')~=0)==enabled then return end
  room:setPlayerMark(player,'@@hanqing_xi',enabled and 1 or 0)
  local old=enabled and 'xi__zhangti' or 'xi_state__zhangti'
  local new=enabled and 'xi_state__zhangti' or 'xi__zhangti'
  for _,prop in ipairs{'general','deputyGeneral'} do
    if player[prop]==old then room:setPlayerProperty(player,prop,new) end
  end
  room:handleAddLoseSkills(player,enabled and '-xi__youwei|-xi__juedu|xi__youwei_xi|xi__juedu_xi'
    or '-xi__youwei_xi|-xi__juedu_xi|xi__youwei|xi__juedu')
end
function M.available(player)
  local room=player.room or Fk:currentRoom()
  if player.dead or #player:getTableMark(M.modes)==0 then return {} end
  return table.filter(player:getTableMark(M.seen),function(id)return room:getCardArea(id)==Card.DiscardPile end)
end
function M.borrowed(player,card)
  if not card then return false end
  return table.find(Card:getIdList(card),function(id)
    return table.contains(M.available(player),id) or Fk:getCardById(id):getMark('xi__juedu_using')==player.id
  end)~=nil
end
function M.bottom(room,ids,who)
  local moves={}
  for _,id in ipairs(ids) do
    local area=room:getCardArea(id)
    if area~=Card.DrawPile and area~=Card.Void then
      table.insert(moves,{ids={id},from=room:getCardOwner(id),toArea=Card.DrawPile,
        drawPilePosition=-1,moveReason=fk.ReasonJustMove,skillName='xi__juedu',proposer=who,moveVisible=true})
    end
  end
  if #moves>0 then room:moveCards(table.unpack(moves)) end
end
function M.installRoom(room)
  if room.__xi_juedu_recast then return end
  room.__xi_juedu_recast=true
  local original=room.recastCard
  function room:recastCard(cards,who,name,moveMark)
    local ids=Card:getIdList(cards)
    local available=M.available(who)
    local borrowed=table.filter(ids,function(id)return table.contains(available,id)end)
    if #borrowed==0 then return original(self,cards,who,name,moveMark) end
    -- This handles a legal recast requested by the card itself or another skill.
    -- It never gives arbitrary cards a new recast button.
    local moves={}
    for _,id in ipairs(ids) do
      table.insert(moves,{ids={id},from=self:getCardOwner(id),
        toArea=table.contains(borrowed,id) and Card.Processing or Card.DiscardPile,
        moveReason=fk.ReasonRecast,proposer=who,skillName=name or 'recast',moveVisible=true})
    end
    self:moveCards(table.unpack(moves))
    self:sendLog{type='#RecastBySkill',from=who.id,card=ids,arg=name or 'xi__juedu'}
    local drawn=not who.dead and self:drawCards(who,#ids,name or 'recast','top',moveMark) or {}
    M.bottom(self,borrowed,who)
    return drawn
  end
end
function M.enable(player,mode)
  M.installRoom(player.room)
  local modes=player:getTableMark(M.modes);table.insertIfNeed(modes,mode)
  player.room:setPlayerMark(player,M.modes,modes)
end
function M.areas(player)
  local ret={}
  if not table.contains(player.sealedSlots,Player.HandSlot) then table.insert(ret,'xi__juedu_hand') end
  if #player:getAvailableEquipSlots()>0 then table.insert(ret,'xi__juedu_equip') end
  if not table.contains(player.sealedSlots,Player.JudgeSlot) then table.insert(ret,'xi__juedu_judge') end
  return ret
end
return M

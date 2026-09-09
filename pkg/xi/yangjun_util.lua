-- SPDX-License-Identifier: GPL-3.0-or-later
local M={shown='@xi__judong_shown',pending='@xi__xiongcou-round'}
function M.change(p,enabled)
  if p.dead or (p:getMark('@@hanqing_xi')~=0)==enabled then return end
  local room=p.room
  room:setPlayerMark(p,'@@hanqing_xi',enabled and 1 or 0)
  local old=enabled and 'xi__yangjun' or 'xi_state__yangjun'
  local new=enabled and 'xi_state__yangjun' or 'xi__yangjun'
  for _,prop in ipairs{'general','deputyGeneral'} do if p[prop]==old then room:setPlayerProperty(p,prop,new) end end
  room:handleAddLoseSkills(p,enabled and '-xi__judong|-xi__xiongcou|xi__judong_xi|xi__xiongcou_xi'
    or '-xi__judong_xi|-xi__xiongcou_xi|xi__judong|xi__xiongcou')
end
function M.isShown(room,id)
  local c=Fk:getCardById(id);local owner=room:getCardOwner(id)
  return owner and not owner.dead and room:getCardArea(id)==Card.PlayerHand
    and (c:getMark(M.shown)==owner.id or c:getMark('@daxi__shewei')==owner.id)
end
function M.materials(p)
  local room=p.room or Fk:currentRoom();local ids={}
  for _,owner in ipairs(room.alive_players) do
    for _,id in ipairs(owner:getCardIds('h')) do
      if M.isShown(room,id) and Fk:getCardById(id).is_damage_card then table.insertIfNeed(ids,id) end
    end
  end
  return ids
end
function M.nameLength(name)
  local text=Fk:translate(name,'zh_CN'):gsub('<[^>]*>',''):gsub('%s','')
  return utf8.len(text) or 0
end
function M.names(p,alternate)
  local n=#M.materials(p)
  return table.filter(Fk:getAllCardNames('btde'),function(name)
    local length=M.nameLength(name)
    return length>0 and length<=n and (alternate or Fk:cloneCard(name).is_damage_card)
  end)
end
function M.discardBy(actor,owner,n,handOnly,skill)
  local room=owner.room;local flag=handOnly and 'h' or 'he'
  local legal=table.filter(owner:getCardIds(flag),function(id)return not owner:prohibitDiscard(id)end)
  n=math.min(n,#legal)
  if n<1 then return {} end
  -- Use the native hand/equipment chooser so unrevealed hands stay hidden.
  local ids=room:askToChooseCards(actor,{target=owner,flag=flag,min=n,max=n,cancelable=false,skill_name=skill})
  ids=table.filter(ids,function(id)return table.contains(legal,id)end)
  if #ids<n then
    local rest=table.filter(legal,function(id)return not table.contains(ids,id)end)
    table.insertTableIfNeed(ids,room:tableRandomPick(rest,n-#ids))
  end
  room:throwCard(ids,skill,owner,actor)
  return ids
end
return M

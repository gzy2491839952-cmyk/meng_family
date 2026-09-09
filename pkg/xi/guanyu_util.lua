-- SPDX-License-Identifier: GPL-3.0-or-later
local M={history='xi__gusui_hp_history'}
function M.change(player,enabled)
  local room=player.room
  if player.dead or (player:getMark('@@hanqing_xi')~=0)==enabled then return end
  room:setPlayerMark(player,'@@hanqing_xi',enabled and 1 or 0)
  local old=enabled and 'xi__guanyu' or 'xi_state__guanyu'
  local new=enabled and 'xi_state__guanyu' or 'xi__guanyu'
  for _,prop in ipairs{'general','deputyGeneral'} do
    if player[prop]==old then room:setPlayerProperty(player,prop,new) end
  end
  room:handleAddLoseSkills(player,enabled and '-xi__jiyue|-xi__gusui|xi__jiyue_xi|xi__gusui_xi'
    or '-xi__jiyue_xi|-xi__gusui_xi|xi__jiyue|xi__gusui')
end
function M.costs(player,alternate)
  return table.filter(player:getCardIds('he'),function(id)
    local c=Fk:getCardById(id)
    if alternate then return c.color==Card.Red end
    return not player:prohibitDiscard(id)
  end)
end
function M.threshold(ids)
  local max=0
  for _,id in ipairs(ids) do max=math.max(max,Fk:getCardById(id).number) end
  return max
end
function M.offset(room,effect,paid)
  -- Only the original trick's user answers Nullification, not the trick's
  -- recipient or every player. Each Slash target answers their own effect.
  local defender=effect.card.trueName=='nullification'
    and (effect.responseToEvent and effect.responseToEvent.from) or effect.to
  if not defender or defender.dead then return false end
  local legal=table.filter(defender:getCardIds('he'),function(id)
    local c=Fk:getCardById(id)
    if paid.alternate then return not defender:prohibitDiscard(id) end
    return c.color==Card.Red and c.number>paid.max
  end)
  if #legal<paid.n then return false end
  local chosen=room:askToCards(defender,{
    min_num=paid.n,max_num=paid.n,include_equip=true,cancelable=true,
    pattern=tostring(Exppattern{id=legal}),skill_name=paid.skill,
    prompt=(paid.alternate and '#xi__jiyue-discard:::' or '#xi__jiyue-recast:::')..paid.n..':'..paid.max,
  })
  if #chosen~=paid.n or not table.every(chosen,function(id)return table.contains(legal,id)end) then return false end
  local high=table.every(chosen,function(id)return Fk:getCardById(id).number>paid.max end)
  if paid.alternate then
    room:throwCard(chosen,paid.skill,defender,defender)
    local owner=effect.from
    if high and not owner.dead then
      local choice=room:askToChoice(owner,{
        choices={'xi__jiyue_losehp','xi__jiyue_exit'},skill_name=paid.skill,prompt='#xi__jiyue-high',
      })
      if choice=='xi__jiyue_losehp' then room:loseHp(owner,1,paid.skill) else M.change(owner,false) end
    end
  else
    room:recastCard(chosen,defender,paid.skill)
  end
  return true
end
function M.damage(player,skill)
  if player.dead then return end
  local room=player.room
  local tos=room:askToChoosePlayers(player,{
    targets=room.alive_players,min_num=1,max_num=1,cancelable=true,
    skill_name=skill,prompt='#xi__gusui-damage',
  })
  if #tos>0 then room:damage{from=player,to=tos[1],damage=1,skillName=skill} end
end
return M

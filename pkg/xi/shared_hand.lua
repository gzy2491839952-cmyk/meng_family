-- SPDX-License-Identifier: GPL-3.0-or-later
-- Keep physical ownership intact. getHandlyIds handles use/response; the bridge
-- below adds shared cards to hand-count and empty-hand checks on both sides.
local M = {sources = "xi__yinpan_sources-phase", display = "@xi__yinpan-phase"}
function M.extra(player)
  local room = player.room or Fk:currentRoom()
  local sources = player:getMark(M.sources)
  local ids = {}
  if not room or type(sources) ~= "table" or player.dead then return ids end
  for _, id in ipairs(sources) do
    local source = room:getPlayerById(id)
    if source and source ~= player and not source.dead then
      -- Read physical hands only: two Chen Gongs must not recurse into each other.
      table.insertTableIfNeed(ids, source:getCardIds("h"))
    end
  end
  return ids
end
function M.all(player)
  local ids = player:getCardIds("h")
  table.insertTableIfNeed(ids, M.extra(player))
  return ids
end
function M.update(player)
  local n = #M.extra(player)
  player.room:setPlayerMark(player, M.display,
    type(player:getMark(M.sources)) == "table" and ("共享"..n.."／合计"..#M.all(player)) or 0)
end
function M.install()
  if Player.__hanqing_shared_hand then return end
  Player.__hanqing_shared_hand = true
  local count, empty, nude, allnude = Player.getHandcardNum, Player.isKongcheng, Player.isNude, Player.isAllNude
  function Player:getHandcardNum() return count(self) + #M.extra(self) end
  function Player:isKongcheng() return empty(self) and #M.extra(self) == 0 end
  function Player:isNude() return nude(self) and #M.extra(self) == 0 end
  function Player:isAllNude() return allnude(self) and #M.extra(self) == 0 end
end
function M.discardPhase(player)
  local room = player.room
  local counted = table.filter(M.all(player), function(id)
    return table.every(room.status_skills[MaxCardsSkill] or {}, function(s)
      return not s:excludeFrom(player, Fk:getCardById(id))
    end)
  end)
  local n = #counted - player:getMaxCards()
  room:broadcastProperty(player, "MaxCards")
  if n <= 0 then return end
  local legal = table.filter(counted, function(id) return not player:prohibitDiscard(id) end)
  n = math.min(n, #legal)
  if n == 0 then return end
  local ids = room:askToCards(player, {
    min_num=n, max_num=n, include_equip=false, cancelable=false,
    skill_name="phase_discard", expand_pile=M.extra(player),
    pattern=tostring(Exppattern{id=legal}), prompt="#xi__yinpan-discard:::"..n,
  })
  -- Mixed-owner moves must not be passed to throwCard(..., player).
  local moves, byOwner = {}, {}
  for _, id in ipairs(ids) do
    local owner = room:getCardOwner(id)
    if owner and table.contains(legal, id) then
      if not byOwner[owner.id] then
        local move = {ids={}, from=owner, toArea=Card.DiscardPile,
          moveReason=fk.ReasonDiscard, proposer=player, skillName="phase_discard"}
        byOwner[owner.id] = move
        table.insert(moves, move)
      end
      table.insert(byOwner[owner.id].ids, id)
    end
  end
  if #moves > 0 then room:moveCards(table.unpack(moves)) end
end
return M

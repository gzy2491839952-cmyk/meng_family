local M = {}
M.excluded = "@daxi__jihui_excluded"
-- The next actual ranking calculation consumes the exclusion once.
function M.pool(player)
  local room = player.room
  local id = player:getMark(M.excluded)
  if id ~= 0 then room:setPlayerMark(player, M.excluded, 0) end
  return table.filter(room.alive_players, function(p) return p.id ~= id and not p.dead end)
end
function M.handRank(players, x)
  local values = {}
  for _, p in ipairs(players) do table.insertIfNeed(values, p:getHandcardNum()) end
  table.sort(values, function(a,b) return a>b end)
  local value = values[x]
  if value == nil then return {} end
  return table.filter(players, function(p) return p:getHandcardNum()==value end)
end
return M

-- SPDX-License-Identifier: GPL-3.0-or-later
local M = {}
M.mark = "@@hanqing_xi"
function M.isXi(player)
  return player:getMark(M.mark) ~= 0
end
function M.change(player, enabled)
  local room = player.room
  if player.dead or M.isXi(player) == enabled then return end
  room:setPlayerMark(player, M.mark, enabled and 1 or 0)
  local old = enabled and "xi__chengong" or "xi_state__chengong"
  local new = enabled and "xi_state__chengong" or "xi__chengong"
  for _, prop in ipairs {"general", "deputyGeneral"} do
    if player[prop] == old then room:setPlayerProperty(player, prop, new) end
  end
  room:handleAddLoseSkills(player, enabled and "-xi__mouzhi|xi__mouzhi_xi" or "-xi__mouzhi_xi|xi__mouzhi")
end
return M

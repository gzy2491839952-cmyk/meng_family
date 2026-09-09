-- SPDX-License-Identifier: GPL-3.0-or-later
-- The stock UI hides prohibition reasons when a card cannot be played anyway
-- (Jink, exhausted Slash quota, etc.). Show Mouzhi's use ban in that case too.
local M = {}
local function installOn(ui)
  if ui.__hanqing_mouzhi_reason then return end
  ui.__hanqing_mouzhi_reason = true
  local original = ui.getCardProhibitReason
  function ui:getCardProhibitReason(cid)
    local handler = ClientInstance and ClientInstance.current_request_handler
    local class = handler and handler.class and handler.class.name
    if Self and (class == "ReqPlayCard" or class == "ReqUseCard") then
      local card = Fk:getCardById(cid)
      if card and (table.contains(Self:getTableMark("xi__mouzhi_colors-turn"), card.color)
        or table.contains(Self:getTableMark("xi__mouzhi_suits-turn"), card.suit)) then
        return Fk:translate("xi__mouzhi") .. Fk:translate("prohibit") .. Fk:translate("method_use")
      end
    end
    -- In particular, a use ban is NOT a response/discard prohibition.
    return original(self, cid)
  end
end
function M.install()
  -- QML uses the fully qualified module; older clients use the short alias.
  -- Lua may cache these as separate tables even when they point to one file.
  local installed = false
  for _, path in ipairs {"packages.freekill-core.ltk.client.util", "ltk.client.util"} do
    local ok, ui = pcall(require, path)
    if ok and type(ui) == "table" and type(ui.getCardProhibitReason) == "function" then
      installOn(ui)
      installed = true
    end
  end
  assert(installed, "Mouzhi: cannot load client card-tip API")
end
return M

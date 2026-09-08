-- SPDX-License-Identifier: GPL-3.0-or-later
local shared = require "packages.meng_family.pkg.xi.shared_hand"
local skill = fk.CreateSkill {name="xi__yinpan"}
skill:addEffect(fk.Damaged, {
  can_trigger=function(self,event,target,player,data)
    return target==player and player:hasSkill(skill.name) and data.from
      and data.from~=player and not data.from.dead
  end,
  on_cost=function() return true end,
  on_use=function(self,event,target,player,data)
    local ids = player:getTableMark(shared.sources)
    table.insertIfNeed(ids, data.from.id)
    player.room:setPlayerMark(player, shared.sources, ids)
    shared.update(player)
  end,
})
skill:addEffect("filter", {
  handly_cards=function(self,player) return shared.extra(player) end,
})
skill:addEffect("visibility", {
  card_visible=function(self,player,card)
    if table.contains(shared.extra(player),card.id) then return true end
  end,
})
skill:addEffect(fk.AfterCardsMove, {
  global=true,
  can_refresh=function(self,event,target,player)
    return type(player:getMark(shared.sources))=="table"
  end,
  on_refresh=function(self,event,target,player) shared.update(player) end,
})
skill:addEffect(fk.EventPhaseProceeding, {
  global=true, priority=-1000,
  can_trigger=function(self,event,target,player,data)
    return target==player and player.phase==Player.Discard
      and type(player:getMark(shared.sources))=="table" and not data.phase_end
  end,
  on_cost=function() return true end,
  mute=true,
  on_use=function(self,event,target,player,data)
    shared.discardPhase(player)
    -- Replace only this phase's standard discard; Phase:clear still runs and
    -- clears every -phase mark even when a phase is interrupted.
    data.phase_end=true
  end,
})
Fk:loadTranslationTable {
  ["xi__yinpan"]="引叛",
  [":xi__yinpan"]="当你受到伤害后，伤害来源的手牌亦视为你的手牌，直到此阶段结束。",
  [shared.display]="引叛",
  ["#xi__yinpan-discard"]="引叛：弃置%arg张手牌（可以选择本阶段共享的手牌）",
}
return skill

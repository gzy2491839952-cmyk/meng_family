local skill = fk.CreateSkill { name = "meng__siyu" }
local changed = "meng__siyu_changed-turn"

skill:addEffect(fk.HpChanged, {
  can_refresh = function(self, event, target, player, data)
    return target == player and data.num ~= 0 and not data.prevented
      and not (data.damageEvent and data.damageEvent.isVirtualDMG)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, changed, 1)
  end,
})

-- Lowering max HP can directly clamp HP without emitting HpChanged.
skill:addEffect(fk.BeforeMaxHpChanged, {
  can_refresh = function(self, event, target, player, data) return target == player end,
  on_refresh = function(self, event, target, player, data) data.meng__siyu_old_hp = player.hp end,
})
skill:addEffect(fk.MaxHpChanged, {
  can_refresh = function(self, event, target, player, data)
    return target == player and data.meng__siyu_old_hp ~= nil and data.meng__siyu_old_hp ~= player.hp
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, changed, 1)
  end,
})

skill:addEffect(fk.TurnEnd, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skill.name) and player:getMark(changed) > 0 and player:isWounded()
  end,
  -- The wording is mandatory, though it does not label the skill as compulsory.
  on_cost = function() return true end,
  on_use = function(self, event, target, player, data)
    player:drawCards(player:getLostHp(), skill.name)
  end,
})

Fk:loadTranslationTable {
  ["meng__siyu"] = "肆欲",
  [":meng__siyu"] = "每个回合结束时，若此回合你的体力值发生过变化，你摸x张牌。（x为你已损失的体力值）",
}
return skill

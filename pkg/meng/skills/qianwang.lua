local skill = fk.CreateSkill { name = "meng__qianwang", tags = { Skill.Lord } }

-- This event precedes the normal lord-death victory check in FreeKill 0.5.21.
skill:addEffect(fk.BeforeGameOverJudge, {
  priority = 10,
  audio_index={1,2},
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    local killer = data.killer
    return target == player and player:hasSkill(skill.name, false, true)
      and player.role == "lord" and player.rest == 0
      and killer ~= nil and killer ~= player and not killer.dead
      and killer.kingdom == "meng_qin" and killer.role ~= "rebel" and killer.role ~= "rebel_chief"
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(data.killer, {
      skill_name = skill.name, prompt = "#meng__qianwang-invoke::" .. player.id,
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local killer = data.killer
    if killer.dead then return end
    -- Use the same role/visibility properties as the built-in succession rule.
    room:setPlayerProperty(killer, "role", "lord")
    room:setPlayerProperty(killer, "role_shown", true)
    if killer:isWounded() then
      room:recover { who = killer, num = killer:getLostHp(), recoverBy = killer, skillName = skill.name }
    end
    if not killer.dead then killer:drawCards(3, skill.name) end
  end,
})

Fk:loadTranslationTable {
  ["$meng__qianwang1"]="丞相！丞相何在？替朕传诏，我不当这皇帝了！",
  ["$meng__qianwang2"]="愿与妻子为黔首，只求留我一命……",

  ["meng__qianwang"] = "黔亡",
  [":meng__qianwang"] = "主公技，其他秦势力角色击杀你后，若其不为反贼，其可以明置身份牌并成为主公，回复所有体力值并摸三张牌。",
  ["#meng__qianwang-invoke"] = "黔亡：是否明置身份牌并成为主公，回复所有体力值并摸三张牌？",
}
return skill

local skill = fk.CreateSkill { name = "daxi__jianxi", tags = { Skill.Limited } }
local used = "daxi__jianxi_used"
local empowered = "@@daxi__jianxi"
skill:addEffect(fk.Death, {
  anim_type = "special",
  audio_index = { 1, 2 },
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skill.name) and data.killer == player and target ~= player
      and player:getMark(used) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, used, 1)
    local role = player.role
    room:setPlayerProperty(player, "role_shown", true)
    player:drawCards(3, skill.name)
    for _, p in ipairs(room:getOtherPlayers(player, false)) do
      if p.role == role and room:askToSkillInvoke(p, {
        skill_name = skill.name, prompt = "#daxi__jianxi-follow::" .. player.id,
      }) then
        room:setPlayerProperty(p, "role_shown", true)
        p:drawCards(3, skill.name)
      end
    end
    if player.dead then return end
    local all_shown = true
    for _, p in ipairs(room.players) do
      if p.role == role and not p.role_shown then all_shown = false; break end
    end
    if all_shown or player.role == "lord" then
      room:setPlayerMark(player, empowered, 1)
      player:broadcastSkillInvoke(skill.name, 3)
    end
  end,
})

skill:addEffect(fk.CardUsing, {
  global = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark(empowered) > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.disresponsiveList = table.simpleClone(player.room.players)
    data.extra_data = data.extra_data or {}
    data.extra_data.daxi__jianxi = true
  end,
})
-- Use the engine's winner list, including winners who have already died.
-- Audio only: no identity, victory condition or skill effect is changed.
skill:addEffect(fk.GameFinished, {
  global = true,
  can_refresh = function(self, event, target, player, data)
    return (player.general == "daxi__zhangxianzhong" or player.deputyGeneral == "daxi__zhangxianzhong")
      and table.contains(data.players or {}, player)
      and player:getMark("daxi__zhangxianzhong_victory_voice") == 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "daxi__zhangxianzhong_victory_voice", 1)
    player.room:broadcastPlaySound("./packages/meng_family/audio/win/daxi__zhangxianzhong")
  end,
})

Fk:loadTranslationTable {
  ["$daxi__jianxi1"] = "这龙椅，老朱家坐得，老张家亦坐得！",
  ["$daxi__jianxi2"] = "小的们，又该我们造反了！",
  ["$daxi__jianxi3"] = "还有哪个不服？站出来，让朕瞧瞧！",
  ["~daxi__zhangxianzhong"] = "哪里来的……暗箭",
  ["!daxi__zhangxianzhong"] = "都说我不配坐这天下，如今，怎么没人开口了？",
  ["daxi__jianxi"] = "僭西",
  [":daxi__jianxi"] = "限定技，当你杀死角色后，你可以亮出身份，摸三张牌，令同身份者也可以如此做，然后若此身份已全部出现或你的身份为主公，你使用牌不可响应。",
  [empowered] = "僭西",
  ["#daxi__jianxi-follow"] = "僭西：是否明置身份牌并摸三张牌？",
}
return skill

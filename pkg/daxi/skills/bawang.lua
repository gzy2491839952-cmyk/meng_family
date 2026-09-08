local skill = fk.CreateSkill { name = "daxi__bawang" }
local granted_mark = "daxi__bawang_granted"
local times_mark = "@daxi__bawang_discarded"
local all_mark = "@@daxi__bawang_all"

-- Physical equipment remains with its owner. Borrow its skill definitions instead.
local function equipment(player)
  local list = {}
  -- Attack-range queries also run on ClientPlayer, which has no .room.
  -- ClientInstance exposes alive_players, but not the server getAlivePlayers method.
  local room = player.room or Fk:currentRoom()
  for _, owner in ipairs(room and room.alive_players or {}) do
    if not owner.dead then
      for _, card in ipairs(owner:getEquipCards()) do
        if player:getMark(all_mark) > 0 or card.sub_type == Card.SubtypeWeapon then
          table.insert(list, { owner = owner, card = card })
        end
      end
    end
  end
  return list
end

local function equip_names(player)
  local names = {}
  for _, item in ipairs(equipment(player)) do
    if item.owner ~= player then
      for _, s in ipairs(item.card:getEquipSkills(player)) do table.insertIfNeed(names, s.name) end
    end
  end
  return names
end

local function own_names(player)
  local names = {}
  for _, card in ipairs(player:getEquipCards()) do
    for _, s in ipairs(card:getEquipSkills(player)) do table.insertIfNeed(names, s.name) end
  end
  return names
end

local function sync(player)
  local room = player.room
  if player.daxi__bawang_syncing then return end
  player.daxi__bawang_syncing = true
  local wanted = {}
  if not player.dead and player:hasSkill(skill.name, true) then wanted = equip_names(player) end
  local old = player:getTableMark(granted_mark)
  local own = own_names(player)
  for _, name in ipairs(old) do
    if not table.contains(wanted, name) then
      -- A borrowed skill might also have been installed physically meanwhile.
      if table.contains(own, name) then player:addSkill(name) end
      local lost = player:loseSkill(name, skill.name)
      for _, s in ipairs(lost) do room:doBroadcastNotify("LoseSkill", {player.id, s.name}) end
      if table.contains(own, name) then
        local restored = player:addSkill(name)
        for _, s in ipairs(restored) do room:doBroadcastNotify("AddSkill", {player.id, s.name}) end
      end
    end
  end
  for _, name in ipairs(wanted) do
    -- addSkill establishes the derivative source even if another source already owns it.
    local got = player:addSkill(name, skill.name)
    for _, s in ipairs(got) do room:doBroadcastNotify("AddSkill", {player.id, s.name}) end
  end
  room:setPlayerMark(player, granted_mark, wanted)
  player.daxi__bawang_syncing = nil
end

local function owners_of_effect(player, effect)
  local names = {}
  local skeleton = effect:getSkeleton()
  if not skeleton then return names end
  for _, item in ipairs(equipment(player)) do
    for _, equip_skill in ipairs(item.card:getEquipSkills(player)) do
      if equip_skill == effect or equip_skill:getSkeleton() == skeleton
        or (equip_skill:getSkeleton() and equip_skill:getSkeleton().name == skeleton.name) then
        table.insertIfNeed(names, item.owner.id)
      end
    end
  end
  return names
end

local function charge(player, owners)
  local room = player.room
  local voiced = false
  for _, id in ipairs(owners) do
    if player.dead or player:isNude() then break end
    local owner = room:getPlayerById(id)
    if owner and not owner.dead then
      local card = room:askToChooseCard(owner, {
        target = player, flag = "he", skill_name = skill.name,
        prompt = "#daxi__bawang-discard::" .. player.id,
      })
      if card and room:getCardOwner(card) == player then
        if not voiced then
          player:broadcastSkillInvoke(skill.name, math.random(2))
          voiced = true
        end
        room:throwCard(card, skill.name, player, owner)
      end
    end
  end
end

skill:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(skill.name, true, true) or #player:getTableMark(granted_mark) > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local times = 0
    for _, move in ipairs(data) do
      if move.from == player and move.moveReason == fk.ReasonDiscard
        and move.skillName == skill.name and #move.moveInfo > 0 then times = times + 1 end
    end
    if times > 0 then
      room:addPlayerMark(player, times_mark, times)
      if player:getMark(times_mark) >= 8 then room:setPlayerMark(player, all_mark, 1) end
    end
    sync(player)
  end,
})

for _, timing in ipairs { fk.GameStart, fk.EventAcquireSkill, fk.EventLoseSkill, fk.Deathed } do
  skill:addEffect(timing, {
    can_refresh = function(self, event, target, player, data)
      return player:hasSkill(skill.name, true, true) or #player:getTableMark(granted_mark) > 0
    end,
    on_refresh = function(self, event, target, player, data) sync(player) end,
  })
end

skill:addEffect("atkrange", {
  virtual_weapon_func = function(self, player)
    if not player:hasSkill(skill.name) then return end
    local range = 0
    for _, item in ipairs(equipment(player)) do
      local card = item.card
      if card.sub_type == Card.SubtypeWeapon and card:AvailableAttackRange(player) then
        range = math.max(range, card:getAttackRange(player) or 1)
      end
    end
    return range
  end,
})

-- Nullifying Bawang must also disable borrowed effects, without disabling actual equipment.
skill:addEffect("invalidity", {
  invalidity_func = function(self, player, effect)
    local skeleton = effect:getSkeleton()
    if not skeleton or skeleton.name == skill.name then return end
    local names = player:getTableMark(granted_mark)
    if not table.contains(names, skeleton.name) then return end
    if table.contains(own_names(player), skeleton.name) then return end
    if not player:hasSkill(skill.name) then return true end
  end,
})

-- Capture owners before effects that might move or destroy their source equipment.
skill:addEffect(fk.SkillEffect, {
  global = true,
  can_refresh = function(self, event, target, player, data)
    return data.who == player and player:hasSkill(skill.name) and data.skill ~= nil
      and data.skill:getSkeleton() ~= skill
  end,
  on_refresh = function(self, event, target, player, data)
    data.daxi__bawang_owners = owners_of_effect(player, data.skill)
  end,
})
skill:addEffect(fk.AfterSkillEffect, {
  global = true,
  late_refresh = true,
  can_refresh = function(self, event, target, player, data)
    return data.who == player and not data.prevented and not data.daxi__bawang_paid
      and data.daxi__bawang_owners and #data.daxi__bawang_owners > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.daxi__bawang_paid = true
    charge(player, data.daxi__bawang_owners)
  end,
})

-- Crossbow and Halberd announce their activation in CardUsing.refresh;
-- they do not emit SkillEffect/AfterSkillEffect. Mirror those activation
-- conditions only, never charge for querying range, distance or target limits.
local function refresh_equipment_effects(player, data)
  local names = {}
  if data.card.trueName ~= "slash" then return names end
  if player:hasSkill("#crossbow_skill") and player.phase == Player.Play
    and not data.extraUse and player:usedCardTimes("slash", Player.HistoryPhase) > 1 then
    table.insert(names, "#crossbow_skill")
  end
  if player:hasSkill("#halberd_skill") and #(data.tos or {}) > 1 then
    table.insert(names, "#halberd_skill")
  end
  return names
end

skill:addEffect(fk.CardUsing, {
  global = true,
  late_refresh = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name)
      and not data.daxi__bawang_refresh_paid and #refresh_equipment_effects(player, data) > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.daxi__bawang_refresh_paid = true
    -- Snapshot both sources before the first payment can remove equipment.
    local payments = {}
    for _, name in ipairs(refresh_equipment_effects(player, data)) do
      local effect = Fk.skills[name]
      if effect then table.insert(payments, owners_of_effect(player, effect)) end
    end
    for _, owners in ipairs(payments) do charge(player, owners) end
  end,
})

Fk:loadTranslationTable {
  ["$daxi__bawang1"] = "谁不识我八大王威名！",
  ["$daxi__bawang2"] = "是把杀人的好刀",
  ["daxi__bawang"] = "八王",
  [":daxi__bawang"] = "你视为装备场上所有武器牌，且装备特效触发后，对应角色弃置你一张牌；因此八次弃置牌后，此技能补齐所有副类别。",
  [times_mark] = "八王弃牌",
  [all_mark] = "八王全装备",
  ["#daxi__bawang-discard"] = "八王：弃置%dest的一张手牌或装备牌",
}
return skill

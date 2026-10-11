-- SPDX-License-Identifier: GPL-3.0-or-later
local M = { skill = "hqchuliji__nangzhi", recast = "hqchuliji_nangzhi_recast-turn" }
M.slots = { Player.WeaponSlot, Player.ArmorSlot, Player.OffensiveRideSlot,
  Player.DefensiveRideSlot, Player.TreasureSlot }
M.types = { Card.SubtypeWeapon, Card.SubtypeArmor, Card.SubtypeOffensiveRide,
  Card.SubtypeDefensiveRide, Card.SubtypeTreasure }

-- The physical trick stays a trick. Only its board representation occupies a slot.
function M.isTrick(id)
  return Fk:getCardById(id, true).type == Card.TypeTrick
end
function M.tricks(p, area)
  return table.filter(p:getCardIds(area or "hej"), M.isTrick)
end
function M.allAreas(p)
  return #M.tricks(p, "h") > 0 and #M.tricks(p, "e") > 0 and #M.tricks(p, "j") > 0
end
function M.canRecast(p)
  return not p.dead and p:hasSkill(M.skill) and (p.room or Fk:currentRoom()).current == p
    and p:getMark(M.recast) == 0 and #M.tricks(p) == 0 and #p:getCardIds("hej") > 0
end
function M.recastArea(room, p, area)
  if not M.canRecast(p) then return end
  local ids = p:getCardIds(area)
  if #ids == 0 then return end
  room:setPlayerMark(p, M.recast, 1)
  room:recastCard(ids, p, M.skill)
end
function M.recastChoices(p)
  return table.filter({"h", "e", "j"}, function(a) return #p:getCardIds(a) > 0 end)
end
function M.nameLength(card)
  local text = Fk:translate(card.name, "zh_CN"):gsub("<[^>]*>", ""):gsub("%s", "")
  return utf8.len(text) or 0
end
function M.names(n)
  return table.filter(Fk:getAllCardNames("t"), function(name)
    local card = Fk:cloneCard(name)
    return card:isCommonTrick() and M.nameLength(card) == n
  end)
end
function M.equipSlots(p)
  return table.filter(M.slots, function(slot)
    return table.contains(p:getAvailableEquipSlots(), slot)
  end)
end
function M.destinations(p, id)
  local area = p.room:getCardArea(id)
  local choices = {}
  if area ~= Card.PlayerHand and not p:isHandAreaSealed() then table.insert(choices, "h") end
  if area ~= Card.PlayerEquip and #M.equipSlots(p) > 0 then table.insert(choices, "e") end
  if area ~= Card.PlayerJudge and not p:isJudgeAreaSealed() then table.insert(choices, "j") end
  return choices
end
function M.selfMovable(p)
  return table.filter(M.tricks(p), function(id) return #M.destinations(p, id) > 0 end)
end
-- One chooser owns both hidden hand selection and public board selection.
-- Never pass real hidden hand IDs in a public card_data panel.
function M.choose(room, p, owner, ids, name)
  local areas = table.filter({"h", "e", "j"}, function(a)
    return table.find(owner:getCardIds(a), function(id) return table.contains(ids, id) end) ~= nil
  end)
  if #areas == 0 then return end
  local area = #areas == 1 and areas[1] or room:askToChoice(p, {
    choices = areas, skill_name = name, prompt = "#hqchuliji-source" })
  if area == "h" and p ~= owner then
    -- In this branch every hand card is eligible; native UI hides identities.
    return room:askToChooseCard(p, {target = owner, flag = "h", skill_name = name})
  end
  local legal = table.filter(owner:getCardIds(area), function(id) return table.contains(ids, id) end)
  return room:askToChooseCard(p, { target = owner,
    flag = {card_data = {{({h = "$Hand", e = "$Equip", j = "$Judge"})[area], legal}}}, skill_name = name })
end
function M.put(room, p, id, area, name)
  local from = room:getCardOwner(id)
  if not from or p.dead then return false end
  local moves, virtual = {}, nil
  if area == Card.PlayerEquip then
    local card = from:getVirtualEquip(id) or Fk:getCardById(id)
    local index
    if room:getCardArea(id) == Card.PlayerEquip then
      for i, subtype in ipairs(M.types) do if card.sub_type == subtype then index = i end end
      if not index or #p:getAvailableEquipSlots(M.types[index]) == 0 then return false end
      virtual = from:getVirtualEquip(id)
    else
      local choices = M.equipSlots(p)
      if #choices == 0 then return false end
      local slot = room:askToChoice(p, { choices = choices, skill_name = name, prompt = "#hqchuliji-slot" })
      for i, s in ipairs(M.slots) do if s == slot then index = i end end
      local real = Fk:getCardById(id, true)
      virtual = Fk:cloneCard("hqchuliji_equip" .. index, real.suit, real.number)
      virtual:addSubcard(id)
    end
    local old = p:getEquipments(M.types[index])
    if #old >= #p:getAvailableEquipSlots(M.types[index]) and #old > 0 then
      local replaced = old[1]
      if #old > 1 then
        replaced = room:askToChooseCard(p, { target = p, flag = {card_data = {{"equip", old}}}, skill_name = name })
      end
      table.insert(moves, { ids = {replaced}, from = p, toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile, skillName = name })
    end
  elseif area == Card.PlayerJudge then
    if p:isJudgeAreaSealed() then return false end
    local real = Fk:getCardById(id, true)
    if room:getCardArea(id) == Card.PlayerJudge then
      virtual = from:getVirtualEquip(id)
    elseif real.sub_type ~= Card.SubtypeDelayedTrick then
      virtual = Fk:cloneCard("hqchuliji_stored_trick", real.suit, real.number)
      virtual:addSubcard(id)
    end
  elseif area == Card.PlayerHand and p:isHandAreaSealed() then return false end
  table.insert(moves, { ids = {id}, from = from, to = p, toArea = area,
    moveReason = fk.ReasonJustMove, skillName = name, proposer = p,
    moveVisible = area ~= Card.PlayerHand or room:getCardArea(id) ~= Card.PlayerHand,
    virtualEquip = virtual })
  room:moveCards(table.unpack(moves))
  return room:getCardOwner(id) == p and room:getCardArea(id) == area
end
function M.otherMovable(p, other)
  if not other or other == p or other.dead then return {} end
  return table.filter(other:getCardIds("hej"), function(id)
    local area = p.room:getCardArea(id)
    if area == Card.PlayerHand then return not p:isHandAreaSealed() end
    if area == Card.PlayerJudge then
      local c = other:getVirtualEquip(id) or Fk:getCardById(id)
      return not p:isJudgeAreaSealed() and not p:isProhibitedTarget(c)
    end
    local c = other:getVirtualEquip(id) or Fk:getCardById(id)
    return #p:getAvailableEquipSlots(c.sub_type) > 0
  end)
end
function M.judge(room, p)
  local ids = table.reverse(M.tricks(p, "j"))
  for _, id in ipairs(ids) do
    if p.dead or not p:hasSkill(M.skill) then break end
    if room:getCardOwner(id) == p and room:getCardArea(id) == Card.PlayerJudge then
      local card = Fk:getCardById(id, true)
      local suit, number, n = card.suit, card.number, M.nameLength(card)
      room:moveCardTo(id, Card.Processing, nil, fk.ReasonPut, M.skill)
      local judge = { who = p, reason = M.skill, pattern = "." }
      room:judge(judge)
      local matched = judge.card and (judge.card.suit == suit or judge.card.number == number)
      if room:getCardArea(id) == Card.Processing then
        room:moveCardTo(id, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, M.skill)
      end
      if matched and not p.dead then
        local use = room:askToUseVirtualCard(p, { name = M.names(n), skill_name = M.skill,
          cancelable = true, prompt = "#hqchuliji-judge-use:::" .. n })
        if use and not p.dead then p:drawCards(n, M.skill) end
      end
    end
  end
end
-- The filter must not call hasSkill: hasSkill itself enumerates filters.
function M.ownsNangzhi(p)
  local sk = Fk.skills[M.skill]
  if not sk or p.dead or not sk:isEffectable(p) then return false end
  if table.contains(p.player_skills, sk) then return true end
  for _, list in pairs(p.derivative_skills) do if table.contains(list, sk) then return true end end
  return false
end
function M.install(extension)
  for i, subtype in ipairs(M.types) do
    extension:loadCardSkels { fk.CreateCard {
      name = "hqchuliji_equip" .. i, type = Card.TypeEquip, sub_type = subtype, attack_range = 1,
      dynamic_name = function(self)
        local id = self:getEffectiveId()
        return id and id >= 0 and Fk:translate(Fk:getCardById(id, true).name) or "囊智"
      end,
    } }
    Fk:loadTranslationTable { ["hqchuliji_equip" .. i] = "囊智",
      [":hqchuliji_equip" .. i] = "锦囊占据此装备栏，不提供装备效果。樗里疾可将其当【无懈可击】使用。" }
  end
  extension:loadCardSkels { fk.CreateCard { name = "hqchuliji_stored_trick", type = Card.TypeTrick,
    sub_type = Card.SubtypeDelayedTrick, skill = "hqchuliji_stored_trick_skill",
    dynamic_name = function(self)
      local id = self:getEffectiveId()
      return id and id >= 0 and Fk:translate(Fk:getCardById(id, true).name) or "囊智"
    end,
  } }
  Fk:loadTranslationTable { ["hqchuliji_stored_trick"] = "囊智",
    [":hqchuliji_stored_trick"] = "置于判定区的锦囊：由【囊智】判定后弃置；不结算原牌效果。" }
end
return M

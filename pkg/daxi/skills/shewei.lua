local skill = fk.CreateSkill { name = "daxi__shewei" }
local mark = "@daxi__shewei"
local liegong = "daxi__shewei_liegong"

local function shown(player)
  return table.filter(player:getCardIds("h"), function(id)
    return Fk:getCardById(id):getMark(mark) == player.id
      and Fk:getCardById(id).trueName == "slash"
  end)
end
local function candidates(player)
  return table.filter(player:getCardIds("h"), function(id)
    local card = Fk:getCardById(id)
    return card.trueName == "slash" and card:getMark(mark) == 0
  end)
end
local function grant(player)
  if not player:hasSkill(skill.name, true) then return end
  local got = player:addSkill(liegong, skill.name)
  for _, s in ipairs(got) do
    player.room:doBroadcastNotify("AddSkill", {player.id, s.name})
  end
end
skill:addAcquireEffect(function(self, player) grant(player) end)
skill:addEffect(fk.GameStart, {
  can_refresh = function(self, event, target, player)
    return player:hasSkill(skill.name, true)
  end,
  on_refresh = function(self, event, target, player) grant(player) end,
})

for _, timing in ipairs { fk.Damage, fk.Damaged } do
  skill:addEffect(timing, {
    can_trigger = function(self, event, target, player, data)
      return target == player and player:hasSkill(skill.name) and not player.dead
    end,
    on_cost = function(self, event, target, player, data)
      local choices = { "daxi__shewei_draw" }
      if #candidates(player) > 0 then table.insert(choices, "daxi__shewei_show") end
      table.insert(choices, "Cancel")
      local choice = player.room:askToChoice(player, {
        choices = choices, skill_name = skill.name, prompt = "#daxi__shewei-choice",
      })
      if choice == "Cancel" then return false end
      local cards = {}
      if choice == "daxi__shewei_show" then
        cards = player.room:askToCards(player, {
          min_num = 1, max_num = 1, include_equip = false, cancelable = true,
          pattern = tostring(Exppattern { id = candidates(player) }),
          skill_name = skill.name, prompt = "#daxi__shewei-show",
        })
        if #cards == 0 then return false end
      end
      event:setCostData(self, { choice = choice, cards = cards,
        audio_index = choice == "daxi__shewei_draw" and { 1, 2 } or 3 })
      return true
    end,
    on_use = function(self, event, target, player, data)
      local cost = event:getCostData(self)
      if cost.choice == "daxi__shewei_draw" then
        player:drawCards(1, skill.name)
      else
        local id = cost.cards[1]
        if table.contains(candidates(player), id) then
          player.room:setCardMark(Fk:getCardById(id), mark, player.id)
          player:showCards({id})
        end
      end
    end,
  })
end

-- Count before the used Slash leaves the hand; include that Slash itself.
-- Only the actual revealed Slash qualifies, not a different virtual card made
-- with it. additionalDamage is carried by this use, including all its targets.
skill:addEffect(fk.PreCardUse, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name)
      and data.card.trueName == "slash" and not data.card:isVirtual()
      and table.contains(shown(player), data.card.id)
      and not (data.extra_data and data.extra_data.daxi__shewei)
  end,
  on_refresh = function(self, event, target, player, data)
    local x = #shown(player)
    data.extra_data = data.extra_data or {}
    data.extra_data.daxi__shewei = x
    data.additionalDamage = (data.additionalDamage or 0) + x
    player:broadcastSkillInvoke(skill.name, 4)
  end,
})

-- Revealed cards stay public while they remain in that player's hand.
skill:addEffect("visibility", {
  card_visible = function(self, viewer, card)
    local owner_id = card:getMark(mark)
    if owner_id == 0 then return end
    local room = Fk:currentRoom()
    local owner = room:getCardOwner(card.id)
    if room:getCardArea(card.id) == Card.PlayerHand and owner and owner.id == owner_id then return true end
  end,
})
skill:addEffect(fk.AfterCardsMove, {
  global = true,
  can_refresh = function(self, event, target, player, data)
    return table.find(data, function(move)
      return move.from == player and table.find(move.moveInfo, function(info)
        return info.fromArea == Card.PlayerHand and Fk:getCardById(info.cardId):getMark(mark) == player.id
      end)
    end)
  end,
  on_refresh = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          local card = Fk:getCardById(info.cardId)
          if info.fromArea == Card.PlayerHand and card:getMark(mark) == player.id then
            player.room:setCardMark(card, mark, 0)
          end
        end
      end
    end
  end,
})

skill:addEffect("invalidity", {
  invalidity_func = function(self, player, effect)
    local skel = effect:getSkeleton()
    if skel and skel.name == liegong and not player:hasSkill(skill.name) then return true end
  end,
})
-- Audio only: use the authoritative winner list and play once per winner.
skill:addEffect(fk.GameFinished, {
  global = true,
  can_refresh = function(self, event, target, player, data)
    return (player.general == "daxi__ainengqi" or player.deputyGeneral == "daxi__ainengqi")
      and table.contains(data.players or {}, player)
      and player:getMark("daxi__ainengqi_victory_voice") == 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "daxi__ainengqi_victory_voice", 1)
    player.room:broadcastPlaySound("./packages/meng_family/audio/win/daxi__ainengqi")
  end,
})
Fk:loadTranslationTable {
  ["$daxi__shewei1"] = "纵陷重围，犹可挽弓！",
  ["$daxi__shewei2"] = "身经百战，未折锋镝！",
  ["$daxi__shewei3"] = "且留此矢，待取敌酋！",
  ["$daxi__shewei4"] = "弦上杀机已满，尔等何处藏身？",
  ["!daxi__ainengqi"] = "曾英授首，川东胆寒，何人敢阻大西兵锋！",
  ["~daxi__ainengqi"] = "征衣未解……壮志先折……",
  ["daxi__shewei"] = "射围",
  [":daxi__shewei"] = "你视为拥有“烈弓”，当你造成或受到伤害后，你可以摸一张牌或明置一张【杀】；你明置【杀】的伤害＋X（X为你明置的杀数）。",
  [mark] = "射围明置",
  ["daxi__shewei_draw"] = "摸一张牌",
  ["daxi__shewei_show"] = "明置一张【杀】",
  ["#daxi__shewei-choice"] = "射围：摸一张牌，或明置一张尚未明置的手牌【杀】",
  ["#daxi__shewei-show"] = "射围：选择一张手牌【杀】持续明置",
}
return skill

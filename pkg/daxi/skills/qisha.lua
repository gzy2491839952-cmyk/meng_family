-- Hanqing Qisha patch v4: defender recast unlocks normal responses.
local skill = fk.CreateSkill { name = "daxi__qisha" }
local count = "@daxi__qisha_total"
local history = "daxi__qisha_cards"
local exhausted = "daxi__qisha_exhausted-turn"

skill:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  audio_index = { 1, 2 },
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and not player:isKongcheng()
      and player:getMark(exhausted) == 0 and data:isOnlyTarget(data.to)
  end,
  on_cost = function(self, event, target, player, data)
    local invoke = player.room:askToChoice(player, {
      skill_name = skill.name,
      prompt = "#daxi__qisha-invoke::" .. data.to.id,
      choices = { "daxi__qisha_recast", "Cancel" },
    }) == "daxi__qisha_recast"
    if invoke then
      local old = player:getMark(count)
      local reaches_seven = math.floor((old + #player:getCardIds("h")) / 7) > math.floor(old / 7)
      -- Pick the milestone line instead of playing two voices simultaneously.
      event:setCostData(self, { audio_index = reaches_seven and 3 or { 1, 2 } })
    end
    return invoke
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player:getCardIds("h")
    if #cards == 0 then return end
    local old = player:getMark(count)
    local recorded = player:getTableMark(history)
    for _, id in ipairs(cards) do table.insertIfNeed(recorded, id) end
    room:setPlayerMark(player, history, recorded)
    room:setPlayerMark(player, count, old + #cards)
    -- Mark the specific use/target before recasting can start nested events.
    data.use.extra_data = data.use.extra_data or {}
    -- AimData.extra_data is written back to UseCardData after this stage.
    data.extra_data = data.use.extra_data
    local extra = data.use.extra_data
    extra.daxi__qisha = extra.daxi__qisha or {}
    local blocked = table.contains(data.use.disresponsiveList or {}, data.to)
    local entry = { owner = player.id, originally_blocked = blocked }
    extra.daxi__qisha[data.to.id] = entry
    data.currentExtraData = data.currentExtraData or {}
    data.currentExtraData.daxi__qisha = entry
    local reached = math.floor((old + #cards) / 7) > math.floor(old / 7)
    if reached then
      room:setPlayerMark(player, exhausted, 1)
      room:invalidateSkill(player, skill.name, "-turn")
    end
    room:recastCard(cards, player, skill.name)
    -- Resolve the defender's alternative response in the SAME invocation.
    -- It must not depend on owning Qisha or on a later skill-invocation prompt.
    local defender = data.to
    if not defender.dead and not defender:isKongcheng()
      and not blocked and not data.disresponsive and not extra.daxi__jianxi
      and not data:isUnoffsetable(defender) then
      local choice = room:askToChoice(defender, {
        skill_name = skill.name,
        prompt = "#daxi__qisha-recast::" .. player.id,
        choices = { "daxi__qisha_recast", "daxi__qisha_no_response" },
      })
      if choice == "daxi__qisha_recast" and not defender.dead then
        local response_cards = defender:getCardIds("h")
        if #response_cards > 0 then
          entry.paid = true
          room:recastCard(response_cards, defender, skill.name)
        end
      end
    end
    -- Only impose Qisha's restriction if the defender did not pay.
    -- Never remove a shared disresponsiveList entry: another skill may own it.
    if not entry.paid then data:setDisresponsive(defender) end
    room:sendLog {
      type = entry.paid and "#daxi__qisha-responded" or "#daxi__qisha-unanswered",
      from = defender.id, to = { player.id }, arg = skill.name,
    }
    if not reached or player.dead then return end
    -- Snapshot eligible physical Slashes. Each is used at most once in this burst.
    local slashes = {}
    for _, id in ipairs(player:getTableMark(history)) do
      if room:getCardArea(id) == Card.DiscardPile and Fk:getCardById(id).trueName == "slash" then
        table.insert(slashes, id)
      end
    end
    for _, id in ipairs(slashes) do
      if player.dead then break end
      if room:getCardArea(id) == Card.DiscardPile then
        room:askToUseRealCard(player, {
          pattern = { id }, expand_pile = { id }, skill_name = skill.name,
          prompt = "#daxi__qisha-slash", cancelable = false,
          extra_data = { bypass_times = true, extraUse = true },
        })
      end
    end
  end,
})

Fk:loadTranslationTable {
  ["$daxi__qisha1"] = "杀！杀出个朗朗乾坤！",
  ["$daxi__qisha2"] = "不忠不孝之人，杀了解闷！",
  ["$daxi__qisha3"] = "把刀捡起来！把刀捡起来！爷们还没杀够！",
  ["daxi__qisha"] = "七杀",
  [":daxi__qisha"] = "你使用牌指定唯一目标后，可以重铸所有手牌，令其只能以此法响应此牌；因此重铸七张牌后，你令此技能失效直到回合结束并使用此前因此技能失去牌中所有在弃牌堆中的【杀】。",
  [count] = "七杀累计",
  ["daxi__qisha_recast"] = "重铸全部手牌",
  ["daxi__qisha_no_response"] = "不响应",
  ["#daxi__qisha-invoke"] = "七杀：是否重铸全部手牌，令%dest须先重铸全部手牌才能正常响应此牌？",
  ["#daxi__qisha-responded"] = "%from 因“%arg”重铸了全部手牌，可以正常响应 %to 使用的此牌",
  ["#daxi__qisha-unanswered"] = "%from 未因“%arg”重铸全部手牌，不能响应 %to 使用的此牌",
  ["#daxi__qisha-recast"] = "七杀：是否重铸全部手牌，以获得正常响应此牌的资格？重铸后仍须正常出牌响应。",
  ["#daxi__qisha-slash"] = "七杀：使用此前重铸且仍在弃牌堆中的这张【杀】",
}
return skill

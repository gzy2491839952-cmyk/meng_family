local central = require "packages.meng_family.pkg.changping.central"
local skill = fk.CreateSkill { name = "weekly__zaoqu" }
local active = "weekly_zaoqu_active"
local nulls = "weekly_zaoqu_nulls"
local function refresh(room, p)
  for _, id in ipairs(p:getCardIds("h")) do room:filterCard(id, p) end
end
skill:addEffect("active", {
 audio_index={1,2},
  anim_type = "control", card_num = 0, target_num = 0, max_phase_use_time = 1,
  can_use = function(self, player)
    return player.phase == Player.Play and player:usedSkillTimes(skill.name, Player.HistoryPhase) == 0
      and player:canUse(Fk:cloneCard("amazing_grace"))
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local people = table.simpleClone(room.alive_players)
    room:sortByAction(people)
    for _, p in ipairs(people) do
      if not p.dead and not p:isNude() then
        local ids = room:askToCards(p, {min_num=1, max_num=1, include_equip=true,
          skill_name=skill.name, cancelable=false, prompt="#weekly__zaoqu-put"})
        if #ids > 0 and room:getCardOwner(ids[1]) == p
          and table.contains(p:getCardIds("he"), ids[1]) then
          room:moveCards{ids=ids, from=p, toArea=Card.DrawPile, drawPilePosition=1,
            moveReason=fk.ReasonPut, skillName=skill.name, proposer=player}
        end
      end
    end
    if player.dead then return end
    local card = Fk:cloneCard("amazing_grace")
    card.skillName = skill.name
    if not player:canUse(card) then return end
    local snapshots, enabled = {}, {}
    for _, p in ipairs(room.alive_players) do
      snapshots[p.id] = p:getMark(nulls)
      table.insert(enabled, p)
      room:addPlayerMark(p, active, 1)
      refresh(room, p)
    end
    -- Idempotent fallback also restores cards if the enclosing skill is interrupted.
    local cleaned = false
    local function cleanup()
      if cleaned then return end
      cleaned = true
      for _, p in ipairs(enabled) do
        room:removePlayerMark(p, active, 1)
        refresh(room, p)
      end
    end
    room.logic:getCurrentEvent():addExitFunc(cleanup)
    local use = {from=player, tos={}, card=card, extraUse=true,
      extra_data={weekly_zaoqu_gained={}}}
    room:useCard(use)
    cleanup()
    local gained = use.extra_data.weekly_zaoqu_gained
    -- Eligibility is frozen before any bonus acquisition / its nested effects.
    local bonus, lose = {}, {}
    for _, p in ipairs(enabled) do
      if not p.dead then
        if table.contains(gained, p.id) then
          if p:getMark(nulls) == snapshots[p.id] then table.insert(bonus, p) end
        else
          table.insert(lose, p)
        end
      end
    end
    room:sortByAction(bonus)
    for _, p in ipairs(bonus) do
      if not p.dead then
        local ids = central.cards(room)
        if #ids > 0 then
          room:fillAG(p, ids)
          local id = room:askToAG(p, {id_list=ids, cancelable=true, skill_name=skill.name})
          room:closeAG(p)
          if id and table.contains(ids, id) and room:getCardArea(id) == Card.DiscardPile then
            room:obtainCard(p, id, true, fk.ReasonPrey, p, skill.name)
          end
        end
      end
    end
    room:sortByAction(lose)
    for _, p in ipairs(lose) do
      if not p.dead then room:loseHp(p, 1, skill.name) end
    end
  end,
})
skill:addEffect("filter", {
  mute = true,
  card_filter = function(self, card, player, isJudge)
    return player and not isJudge and player:getMark(active) > 0
      and table.contains(player:getCardIds("h"), card.id)
  end,
  view_as = function(self, player, card)
    return Fk:cloneCard("nullification", card.suit, card.number)
  end,
})
skill:addEffect(fk.CardUsing, {
  global=true,
  can_refresh=function(self, event, target, player, data)
    return target == player and player:getMark(active) > 0 and data.card.trueName == "nullification"
  end,
  on_refresh=function(self, event, target, player, data)
    player.room:addPlayerMark(player, nulls, 1)
  end,
})
skill:addEffect(fk.AfterCardsMove, {
  global=true,
  can_refresh=function(self, event, target, player, data)
    if player:getMark(active) == 0 then return false end
    local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true)
    return e and e.data.card.trueName == "amazing_grace" and e.data.extra_data
      and e.data.extra_data.weekly_zaoqu_gained ~= nil
  end,
  on_refresh=function(self, event, target, player, data)
    local room = player.room
    local e = room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true)
    for _, move in ipairs(data) do
      if move.to == player and move.toArea == Card.PlayerHand and move.skillName == "amazing_grace_skill" then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.Processing then
            table.insertIfNeed(e.data.extra_data.weekly_zaoqu_gained, player.id)
            break
          end
        end
      end
    end
  end,
})
Fk:loadTranslationTable {
  ["weekly__zaoqu"]="凿渠",
  [":weekly__zaoqu"]="出牌阶段限一次，你可以令所有角色各将一张牌置于牌堆顶，然后视为使用一张【五谷丰登】。结算期间，所有角色的当前手牌均视为【无懈可击】。结算完成后，获得过牌且未使用过【无懈可击】的角色可以从中央区获得一张牌，没有获得过牌的角色则失去1点体力。<br><font color='gray'>获得过牌：指从此次【五谷丰登】获得牌。中央区：本回合进入弃牌堆且当前仍在弃牌堆中的牌，不含处理区。</font>",
  ["#weekly__zaoqu-put"]="凿渠：将一张手牌或装备牌置于牌堆顶",
}
return skill

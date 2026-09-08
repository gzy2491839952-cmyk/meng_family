local skill = fk.CreateSkill { name = "daxi__xuanshi" }
local function movable(player)
  local room = player.room or Fk:currentRoom()
  for _, from in ipairs(room.alive_players) do
    for _, to in ipairs(room.alive_players) do
      if from ~= to and from:canMoveCardsInBoardTo(to, "e") then return true end
    end
  end
  return false
end
local function settle(room, user, recipient, records)
  if recipient.dead then return end
  local cards = recipient:getCardIds("h")
  local trick = Fk:cloneCard("ex_nihilo")
  trick:addSubcards(cards)
  trick.skillName = skill.name
  local choices = { "daxi__xuanshi_damage" }
  if #cards > 0 and recipient:canUseTo(trick, recipient, {bypass_times=true}) then
    table.insert(choices, 1, "daxi__xuanshi_trick")
  end
  local choice = room:askToChoice(recipient, {
    choices = choices, skill_name = skill.name, prompt = "#daxi__xuanshi-choice",
  })
  table.insert(records, {player=recipient, choice=choice})
  if choice == "daxi__xuanshi_trick" then
    room:useCard {from=recipient, tos={recipient}, card=trick, extraUse=true}
  else
    -- The text does not assign a damage source.
    room:damage {to=recipient, damage=1, skillName=skill.name}
  end
end
skill:addEffect("active", {
  anim_type = "control",
  audio_index = { 1, 2 },
  prompt = "#daxi__xuanshi",
  max_phase_use_time = 1,
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player.phase == Player.Play and player:usedSkillTimes(skill.name, Player.HistoryPhase) == 0
      and movable(player)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local targets = room:askToChooseToMoveCardInBoard(player, {
      flag="e", skill_name=skill.name, cancelable=false,
    })
    if #targets ~= 2 then return end
    local result = room:askToMoveCardInBoard(player, {
      target_one=targets[1], target_two=targets[2], flag="e", skill_name=skill.name,
    })
    if not result then return end
    local ids = Card:getIdList(result.card)
    if #ids == 0 then return end
    local records = {}
    settle(room, player, result.to, records)
    for step=2,4 do
      if player.dead then break end
      local owner = room:getCardOwner(ids[1])
      if not owner or owner.dead then break end
      if not table.every(ids, function(id)
        return room:getCardArea(id)==Card.PlayerEquip and room:getCardOwner(id)==owner
      end) then break end
      local tos = table.filter(room.alive_players, function(to)
        return owner:canMoveCardInBoardTo(to, ids[1])
      end)
      if #tos == 0 then break end
      local chosen = room:askToChoosePlayers(player, {
        targets=tos, min_num=1, max_num=1, cancelable=false,
        skill_name=skill.name, prompt="#daxi__xuanshi-move:::"..step,
      })
      if #chosen == 0 then break end
      local to = chosen[1]
      local card = owner:getVirtualEquip(ids[1]) or Fk:getCardById(ids[1])
      room:moveCardTo(card, Card.PlayerEquip, to, fk.ReasonPut, skill.name, nil, true, player)
      if room:getCardOwner(ids[1]) ~= to or room:getCardArea(ids[1]) ~= Card.PlayerEquip then break end
      settle(room, player, to, records)
    end
    -- A unique different choice among four records is a 3:1 split.
    local receiver = player
    local no_unique_choice = true
    if #records == 4 then
      local n = 0
      for _, record in ipairs(records) do
        if record.choice == "daxi__xuanshi_trick" then n=n+1 end
      end
      if n==1 or n==3 then
        no_unique_choice = false
        for _, record in ipairs(records) do
          if (record.choice=="daxi__xuanshi_trick") == (n==1) then receiver=record.player;break end
        end
      end
    end
    if receiver.dead then receiver=player end
    if not receiver.dead then
      if no_unique_choice then player:broadcastSkillInvoke(skill.name, 3) end
      room:askToUseVirtualCard(receiver, {
        name=Fk:getAllCardNames("b"), skill_name=skill.name,
        prompt="#daxi__xuanshi-basic", cancelable=false,
        extra_data={bypass_times=true, extraUse=true},
      })
    end
  end,
})
Fk:loadTranslationTable {
  ["$daxi__xuanshi1"] = "爵禄刀兵，皆悬孤手；诸君所择，亦各有报。",
  ["$daxi__xuanshi2"] = "四镇纵有异志，兵柄须归一人！",
  ["$daxi__xuanshi3"] = "诸将既无异议，此权便由孤暂管",
  ["daxi__xuanshi"]="旋势",
  [":daxi__xuanshi"]="出牌阶段限一次，你可以选择装备区中的一张牌并移动此牌四次，每次获得者须选择一项：1.将所有手牌当【无中生有】使用；2.受到1点伤害。最后唯一选择不同者视为使用一张基本牌，且若其不存在，改为你。",
  ["#daxi__xuanshi"]="旋势：选择一张场上装备并连续移动四次",
  ["#daxi__xuanshi-choice"]="旋势：将全部手牌当【无中生有】使用，或受到1点无来源伤害",
  ["#daxi__xuanshi-move"]="旋势：选择这张装备第%arg次移动的获得者",
  ["#daxi__xuanshi-basic"]="旋势：视为使用一张基本牌",
  ["daxi__xuanshi_trick"]="将所有手牌当【无中生有】使用",
  ["daxi__xuanshi_damage"]="受到1点伤害",
}
return skill

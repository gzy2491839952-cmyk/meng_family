local skill = fk.CreateSkill { name = "meng__diewang" }
local times_mark = "meng__diewang_times-turn"
local last_mark = "@meng__diewang_last"
local recover_choice = "meng__diewang_recover"
local lose_choice = "meng__diewang_lose"

local function can_trigger(self, event, target, player, data)
  return target == player and player:hasSkill(skill.name) and not player.dead
    and player:getMark(times_mark) < 2 and data.from ~= nil and not data.from.dead
end

local function on_cost(self, event, target, player, data)
  -- 选择权属于伤害来源，而不是技能拥有者。
  local choice = player.room:askToChoice(data.from, {
    choices = { recover_choice, lose_choice, "Cancel" },
    skill_name = skill.name,
    prompt = "#meng__diewang-choice::" .. player.id,
  })
  if choice == recover_choice or choice == lose_choice then
    event:setCostData(self, { choice = choice })
    return true
  end
  return false
end

local function on_use(self, event, target, player, data)
  local room = player.room
  local choice = event:getCostData(self).choice
  local same = player:getMark(last_mark) == choice
  -- 在体力变化之前记录，保证嵌套结算也受每回合两次的限制。
  room:addPlayerMark(player, times_mark, 1)
  room:setPlayerMark(player, last_mark, choice)
  if choice == recover_choice then
    room:recover { who = player, num = 1, recoverBy = data.from, skillName = skill.name }
  else
    room:loseHp(player, 1, skill.name)
  end
  -- 先完成体力变化及濒死结算，再执行奖励。
  if same and not player.dead then
    room:changeMaxHp(player, 1)
    if not player.dead then player:drawCards(2, skill.name) end
  end
end

-- 两种伤害时机共用次数和上次选择记录。
for _, timing in ipairs { fk.Damage, fk.Damaged } do
  skill:addEffect(timing, {
    anim_type = "special",
    can_trigger = can_trigger,
    on_cost = on_cost,
    on_use = on_use,
  })
end

Fk:loadTranslationTable {
  ["meng__diewang"] = "迭亡",
  [":meng__diewang"] = "每回合限两次，当你造成或受到伤害后，伤害来源可令你回复或流失一点体力值，若与上次的选择一致，你加一点体力上限并摸两张牌。",
  [recover_choice] = "回复1点体力",
  [lose_choice] = "流失1点体力",
  [last_mark] = "迭亡上次",
  ["#meng__diewang-choice"] = "迭亡：你可令 %dest 回复或流失1点体力（与上次选择一致则其加1点体力上限并摸两张牌）",
}
return skill

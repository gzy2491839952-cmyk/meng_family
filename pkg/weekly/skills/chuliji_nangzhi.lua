local U = require "packages.meng_family.pkg.weekly.chuliji"
local skill = fk.CreateSkill { name = U.skill, related_skills = {"jizhi", "hqchuliji__recast"}, add_skills = {"jizhi"} }
skill:addEffect("viewas", {
  pattern = "nullification",
  card_filter = function(self, p, id, selected)
    return #selected == 0 and table.contains(U.tricks(p, "e"), id)
  end,
  view_as = function(self, p, ids)
    if #ids ~= 1 then return end
    local c = Fk:cloneCard("nullification")
    c.skillName = skill.name; c:addSubcard(ids[1]); return c
  end,
  enabled_at_play = Util.FalseFunc,
  enabled_at_response = function(self, p, responding) return not responding and #U.tricks(p, "e") > 0 end,
  enabled_at_nullification = function(self, p) return #U.tricks(p, "e") > 0 end,
})
skill:addEffect(fk.PreCardUse, {
  can_trigger = function(self, event, target, p, data)
    local ids = Card:getIdList(data.card)
    return target == p and p:hasSkill(skill.name) and data.card.type == Card.TypeTrick and #ids > 0
      and table.every(ids, function(id) return table.contains(p:getCardIds("h"), id) and U.isTrick(id) end)
  end,
  on_cost = function(self, event, target, p)
    local choice = p.room:askToChoice(p, { choices = {"hqchuliji_no_response", "hqchuliji_repeat", "Cancel"},
      skill_name = skill.name, prompt = "#hqchuliji-hand" })
    if choice == "Cancel" then return false end
    event:setCostData(self, choice); return true
  end,
  on_use = function(self, event, target, p, data)
    if event:getCostData(self) == "hqchuliji_no_response" then
      data.disresponsiveList = table.simpleClone(p.room.players)
    else
      data.additionalEffect = (data.additionalEffect or 0) + 1
      data.extra_data = data.extra_data or {}; data.extra_data.hqchuliji_repeat = true
    end
  end,
})
-- toCard responses use an engine branch which does not read additionalEffect.
skill:addEffect(fk.CardEffectFinished, {
  global = true,
  can_refresh = function(self, event, target, p, data)
    return data.from == p and data.toCard and data.use and data.use.extra_data
      and data.use.extra_data.hqchuliji_repeat and not data.use.extra_data.hqchuliji_repeated
  end,
  on_refresh = function(self, event, target, p, data)
    data.use.extra_data.hqchuliji_repeated = true
    p.room:doCardEffect(CardEffectData:new { from = p, card = data.card, tos = data.tos,
      subTos = data.subTos, toCard = data.toCard, use = data.use,
      responseToEvent = data.responseToEvent, extra_data = data.extra_data,
      additionalDamage = data.additionalDamage, additionalRecover = data.additionalRecover })
  end,
})
skill:addEffect(fk.EventPhaseProceeding, {
  can_trigger = function(self, event, target, p)
    return target == p and p:hasSkill(skill.name) and p.phase == Player.Judge and #U.tricks(p, "j") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, p) U.judge(p.room, p) end,
})
skill:addEffect("filter", {
  skill_filter = function(self, p)
    if U.ownsNangzhi(p) and U.allAreas(p) then return {"jizhi"} end
    return {}
  end,
})
-- Outside the play phase, expose the turn-limited recast at phase boundaries.
skill:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, p)
    return target == p and p.phase ~= Player.Play and p.phase ~= Player.NotActive and U.canRecast(p)
  end,
  on_cost = function(self, event, target, p)
    local choices = U.recastChoices(p); table.insert(choices, "Cancel")
    local c = p.room:askToChoice(p, { choices = choices, skill_name = skill.name, prompt = "#hqchuliji-recast" })
    if c == "Cancel" then return false end
    event:setCostData(self, c); return true
  end,
  on_use = function(self, event, target, p) U.recastArea(p.room, p, event:getCostData(self)) end,
})
Fk:loadTranslationTable {
  [U.skill] = "囊智",
  [":" .. U.skill] = "锦囊牌在你的区域内，获得以下效果：<br>手牌：使用之可使其无法被响应或额外结算一次。<br>装备：可将其当【无懈可击】使用。<br>判定：你的判定阶段，依次为这些牌进行判定，然后弃置之（不结算原效果）。若花色或点数与该锦囊相同，你可视为使用一张X字牌名的非延时锦囊牌并摸X张牌（X为该判定区锦囊的牌名字数）。<br>若你的手牌区、装备区、判定区均有锦囊牌，你视为拥有“集智”；若三个区域均无锦囊牌，回合内限一次，你可重铸你的一个区域内的所有牌。",
  ["hqchuliji_no_response"] = "此牌无法被响应", ["hqchuliji_repeat"] = "此牌额外结算一次",
  ["#hqchuliji-hand"] = "囊智：你可以强化此手牌锦囊",
  ["#hqchuliji-slot"] = "运策：选择锦囊占据的装备栏（替换该栏原装备）",
  ["#hqchuliji-judge-use"] = "囊智：你可以视为使用一张%arg字普通锦囊，然后摸%arg张牌",
  ["#hqchuliji-recast"] = "囊智：你可以重铸一个区域内的所有牌（回合内限一次）",
  ["#hqchuliji-source"] = "运策：选择取牌区域",
}
return skill

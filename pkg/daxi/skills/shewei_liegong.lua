-- Namespaced implementation: does not depend on whichever Huang Zhong package
-- happens to be installed on the client.
local skill = fk.CreateSkill { name = "daxi__shewei_liegong" }
skill:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  audio_index = { 1, 2 },
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and data.card.trueName == "slash"
      and (data.to:getHandcardNum() <= player:getHandcardNum() or data.to.hp >= player.hp)
  end,
  on_use = function(self, event, target, player, data)
    if data.to:getHandcardNum() <= player:getHandcardNum() then data.disresponsive = true end
    if data.to.hp >= player.hp then data.additionalDamage = (data.additionalDamage or 0) + 1 end
  end,
})
skill:addEffect("targetmod", {
  bypass_distances = function(self, player, card_skill, card, to)
    return player:hasSkill(skill.name) and card and card.trueName == "slash" and to
      and player:distanceTo(to) <= card.number
  end,
})
Fk:loadTranslationTable {
  ["$daxi__shewei_liegong1"] = "纵有重甲千层，难挡此矢一贯！",
  ["$daxi__shewei_liegong2"] = "弦开如满月，矢过断长风！",
  ["daxi__shewei_liegong"] = "烈弓",
  [":daxi__shewei_liegong"] = "你使用【杀】可选择在此【杀】点数距离内的角色为目标。当你使用【杀】指定目标后，你可以根据下列条件执行相应的效果：1.若你的手牌数大于等于其手牌数，其不能使用【闪】响应此【杀】；2.若你的体力值小于等于其体力值，此【杀】伤害+1。",
}
return skill

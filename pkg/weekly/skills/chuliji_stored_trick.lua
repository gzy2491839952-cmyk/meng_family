-- Safe board representation if a stored common trick leaves its Nangzhi owner.
local skill = fk.CreateSkill { name = "hqchuliji_stored_trick_skill" }
local function discard(self, room, effect)
  local ids = room:getSubcardsByRule(effect.card, {Card.Processing})
  if #ids > 0 then room:moveCardTo(ids, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, skill.name) end
end
skill:addEffect("cardskill", { can_use = Util.FalseFunc, on_effect = discard, on_nullified = discard })
return skill

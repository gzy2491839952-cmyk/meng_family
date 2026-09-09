local skill = fk.CreateSkill {name="meng__fenyi",tags={Skill.Compulsory}}
skill:addEffect(fk.PreHpLost, {
  can_trigger=function(self,event,target,player,data)
    return target==player and player:hasSkill(skill.name) and player:isWounded() and data.num>0
  end,
  on_cost=function() return true end,
  on_use=function(self,event,target,player,data)
    data:preventHpLost()
  end,
})
skill:addEffect("prohibit", {
  is_prohibited=function(self,from,to,card)
    return to and to:hasSkill(skill.name) and not to:isWounded() and card
      and card.type==Card.TypeTrick and card.is_damage_card
  end,
})
Fk:loadTranslationTable {
  ["meng__fenyi"]="奋毅",
  [":meng__fenyi"]="若你已/未受伤，你无法失去体力值/成为伤害类锦囊牌的目标。",
}
return skill

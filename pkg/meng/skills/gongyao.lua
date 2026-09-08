local skill = fk.CreateSkill {
  name = "meng__gongyao",
  tags = { Skill.Compulsory },
}

-- 当前体力的第2、4、6……点分别增加一次出杀次数。
skill:addEffect("targetmod", {
  residue_func = function(self, player, card_skill, scope, card)
    if player:hasSkill(skill.name) and card and card.trueName == "slash"
      and scope == Player.HistoryPhase then
      return math.floor(math.max(player.hp, 0) / 2)
    end
  end,
})

-- 当前体力的第1、3、5……点分别增加两张手牌上限。
skill:addEffect("maxcards", {
  correct_func = function(self, player)
    if player:hasSkill(skill.name) then
      return 2 * math.ceil(math.max(player.hp, 0) / 2)
    end
  end,
})

Fk:loadTranslationTable {
  ["meng__gongyao"] = "共耀",
  [":meng__gongyao"] = "锁定技，你每有一点偶数体力值，额定出杀次数便+1；每有一点奇数体力值，手牌上限便+2。",
}
return skill

local U = require "packages.meng_family.pkg.weekly.chuliji"
local skill = fk.CreateSkill { name = "hqchuliji__recast" }
skill:addEffect("active", {
  card_num = 0, target_num = 0,
  can_use = function(self, p) return U.canRecast(p) end,
  on_use = function(self, room, effect)
    local p = effect.from
    if not U.canRecast(p) then return end
    local choices = U.recastChoices(p)
    local area = room:askToChoice(p, { choices = choices, skill_name = U.skill, prompt = "#hqchuliji-recast" })
    U.recastArea(room, p, area)
  end,
})
Fk:loadTranslationTable { [skill.name] = "囊智·重铸", [":" .. skill.name] = "回合内限一次，若你的手牌区、装备区、判定区均无锦囊牌，你可重铸一个区域内的所有牌。" }
return skill

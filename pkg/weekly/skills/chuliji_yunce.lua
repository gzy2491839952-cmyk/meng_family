local U = require "packages.meng_family.pkg.weekly.chuliji"
local C = require "packages.meng_family.pkg.changping.central"
local skill = fk.CreateSkill { name = "hqchuliji__yunce", tags = {Skill.Compulsory} }
local function central(room) return table.filter(C.cards(room), U.isTrick) end
skill:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, p)
    if not p:hasSkill(skill.name) then return false end
    if #central(p.room) > 0 then
      return not p:isHandAreaSealed() or #U.otherMovable(p, target) > 0
    end
    return #U.selfMovable(p) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, p)
    local room = p.room
    local ids = central(room)
    if #ids > 0 then
      local choices = {}
      if not p:isHandAreaSealed() then table.insert(choices, "hqchuliji_obtain") end
      local movable = U.otherMovable(p, target)
      if #movable > 0 then table.insert(choices, "hqchuliji_take") end
      if #choices == 0 then return end
      local choice = room:askToChoice(p, { choices = choices, skill_name = skill.name, prompt = "#hqchuliji-yunce" })
      if choice == "hqchuliji_obtain" then
        local id = room:askToChooseCard(p, { target = p, flag = {card_data = {{"中央区", ids}}}, skill_name = skill.name })
        if table.contains(central(room), id) then room:obtainCard(p, id, true, fk.ReasonPrey, p, skill.name) end
      else
        local id = U.choose(room, p, target, movable, skill.name)
        if table.contains(U.otherMovable(p, target), id) then U.put(room, p, id, room:getCardArea(id), skill.name) end
      end
    else
      local movable = U.selfMovable(p)
      if #movable == 0 then return end
      local id = U.choose(room, p, p, movable, skill.name)
      if not table.contains(U.selfMovable(p), id) then return end
      local area = room:askToChoice(p, { choices = U.destinations(p, id), skill_name = skill.name, prompt = "#hqchuliji-transfer" })
      U.put(room, p, id, ({h = Card.PlayerHand, e = Card.PlayerEquip, j = Card.PlayerJudge})[area], skill.name)
    end
  end,
})
Fk:loadTranslationTable {
  [skill.name] = "运策",
  [":" .. skill.name] = "锁定技，每名角色回合结束时，若中央区有锦囊牌，你获得中央区的一张锦囊牌或移动当前回合角色区域内的一张牌至你的对应区域内；否则，你将你区域内的一张锦囊牌移动到你的其他区域中（没有则不移动）。锦囊移入装备区时选择一个装备栏，替换该栏原装备。",
  ["hqchuliji_obtain"] = "获得中央区的一张锦囊", ["hqchuliji_take"] = "将当前回合角色的一张牌移至你的对应区域",
  ["#hqchuliji-yunce"] = "运策：获得中央区锦囊，或移动当前回合角色的牌",
  ["#hqchuliji-transfer"] = "运策：选择此锦囊移入的另一个区域",
}
return skill

local skill=fk.CreateSkill {name="changping__beishi",tags={Skill.Compulsory}}
skill:addEffect(fk.Damaged,{
  anim_type="drawcard",
  can_trigger=function(self,event,target,player,data)
    return target==player and player:hasSkill(skill.name) and #player:getAvailableEquipSlots()>0
  end,
  on_use=function(self,event,target,player,data)
    local room=player.room
    local n=#player:getAvailableEquipSlots()
    player:drawCards(n,skill.name)
    if player.dead then return end
    local choices={}
    for _,slot in ipairs(player:getAvailableEquipSlots()) do table.insertIfNeed(choices,slot) end
    if #choices==0 then return end
    local choice=room:askToChoice(player,{choices=choices,skill_name=skill.name,prompt="#changping__beishi-slot"})
    room:abortPlayerArea(player,choice)
  end,
})
Fk:loadTranslationTable {
  ["changping__beishi"]="备势",
  [":changping__beishi"]="锁定技，当你受到伤害后，你摸X张牌并废除一个装备栏（X为你未废除的装备栏数）。",
  ["#changping__beishi-slot"]="备势：选择废除一个装备栏",
}
Fk:loadTranslationTable{
 ["$changping__beishi1"]="秦人一击未成，老夫便教他再无可乘之隙！",
 ["$changping__beishi2"]="折甲尚可再披，失地岂能复得！",
}
return skill

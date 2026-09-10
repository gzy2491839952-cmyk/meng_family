local skill=fk.CreateSkill{name="changping__xiaocheng",tags={Skill.Lord},attached_skill_name="changping__xiaocheng_other&"}
skill:addEffect(fk.GameStart,{can_trigger=function()return false end})
Fk:loadTranslationTable{
 ["changping__xiaocheng"]="孝成",
 [":changping__xiaocheng"]="主公技，赵/其他势力角色出牌阶段限一次，其可以交给你两张牌并获得你区域内/装备区一张牌。",
}
Fk:loadTranslationTable{
 ["$changping__xiaocheng1"]="上党吏民既愿归赵，寡人岂可弃之于秦！",
 ["$changping__xiaocheng2"]="邯郸危急，望诸卿为寡人，再借一支援军！",
}
return skill

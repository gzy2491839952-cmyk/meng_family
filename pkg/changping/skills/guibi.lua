local skill=fk.CreateSkill{name="changping__guibi",attached_skill_name="changping__guibi_other&"}
skill:addEffect(fk.GameStart,{can_trigger=function()return false end})
Fk:loadTranslationTable{
 ["changping__guibi"]="归璧",
 [":changping__guibi"]="每名角色限一次，其他角色的出牌阶段，其可以展示你至多你装备区牌数张手牌，然后你选择一项：1.使用其中的所有基本牌（无距离限制）；2.重铸其中的所有非基本牌。然后，其获得其余展示牌。",
}
Fk:loadTranslationTable{
 ["$changping__guibi1"]="大王若欲强夺，臣头与璧，俱碎于此！",
 ["$changping__guibi2"]="城池未曾入赵，此璧岂能留秦！",
}
return skill

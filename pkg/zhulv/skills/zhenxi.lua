local skill=fk.CreateSkill{name="zhulv__zhenxi"}
skill:addEffect(fk.Damaged,{
 can_trigger=function(self,event,target,player,data)return target==player and player:hasSkill(skill.name) and player.hp==1 end,
 on_cost=function()return true end,
 on_use=function(self,event,target,player,data)player:setSkillUseHistory("zhulv__quzong",0,Player.HistoryGame)end,
})
skill:addEffect(fk.HpRecover,{
 can_trigger=function(self,event,target,player,data)
  return target==player and player:hasSkill(skill.name) and data.num>0 and player.hp==player.maxHp
 end,
 on_cost=function()return true end,
 on_use=function(self,event,target,player,data)
  player.room:changeMaxHp(player,1)
  player:setSkillUseHistory("zhulv__shiyi",0,Player.HistoryGame)
 end,
})
Fk:loadTranslationTable{
 ["zhulv__zhenxi"]="震息",
 [":zhulv__zhenxi"]="当你因受到伤害而使体力变为1后，你重置“驱纵”；当你回复体力至上限后，你增加1点体力上限并重置“市义”。",
}
return skill

local M=require "packages.meng_family.pkg.zhulv.revealed"
local skill=fk.CreateSkill{name="zhulv__choufeng",attached_skill_name="zhulv__choufeng_other&"}
skill:addEffect(fk.CardUsing,{
 can_trigger=function(self,event,target,player,data)
  local ctx=data.extra_data and data.extra_data.zhulv_choufeng
  return player:hasSkill(skill.name) and ctx and ctx.owner==player.id and not ctx.resolved
 end,
 on_cost=function()return true end,
 on_use=function(self,event,target,player,data)
  local room=player.room;local ctx=data.extra_data.zhulv_choufeng;ctx.resolved=true
  local ids=M.sameColor(player,ctx.color)
  local choices={"zhulv_choufeng_draw"}
  if #ids>0 then table.insert(choices,1,"zhulv_choufeng_show")end
  local choice=room:askToChoice(player,{choices=choices,skill_name=skill.name,prompt="#zhulv__choufeng-choice"})
  if choice=="zhulv_choufeng_show"then
   local selected=room:askToCards(player,{min_num=1,max_num=1,include_equip=false,
    pattern=tostring(Exppattern{id=ids}),skill_name=skill.name,cancelable=false,prompt="#zhulv__choufeng-show"})
   M.reveal(player,selected,skill.name)
  else
   data.extra_data.zhulv_choufeng_nullified=true
   data.nullifiedTargets=table.simpleClone(room.players)
   player:drawCards(2,skill.name)
  end
 end,
})
-- Also covers a Jink use against a Slash (toCard has no player target).
skill:addEffect(fk.PreCardEffect,{
 global=true,
 can_refresh=function(self,event,target,player,data)
  return data.from==player and data.extra_data and data.extra_data.zhulv_choufeng_nullified
 end,
 on_refresh=function(self,event,target,player,data)data.nullified=true end,
})
Fk:loadTranslationTable{
 ["zhulv__choufeng"]="酬烽",
 [":zhulv__choufeng"]="其他角色可以使用你明置的基本牌并令你选择一项：1.明置一张同色牌；2.摸两张牌并令此牌无效。",
 ["zhulv_choufeng_draw"]="摸两张牌，令此次使用的牌无效",
 ["zhulv_choufeng_show"]="明置一张同色手牌",
 ["#zhulv__choufeng-choice"]="酬烽：明置同色手牌，或摸两张并令此牌无效",
 ["#zhulv__choufeng-show"]="酬烽：明置一张与被使用牌同色的手牌",
}
return skill

local skill=fk.CreateSkill{name="zhulv__quzong",tags={Skill.Limited}}
local chosen="@zhulv_quzong-round"
local sources="zhulv_quzong_sources-round"
local done="zhulv_quzong_done-round"
skill:addEffect(fk.RoundStart,{
 can_trigger=function(self,event,target,player,data)
  return player:hasSkill(skill.name) and player:usedSkillTimes(skill.name,Player.HistoryGame)==0
 end,
 on_cost=function(self,event,target,player,data)
  local to=player.room:askToChoosePlayers(player,{targets=player.room.alive_players,min_num=1,max_num=1,
   skill_name=skill.name,cancelable=true,prompt="#zhulv__quzong-choose"})[1]
  if to then event:setCostData(self,{to=to});return true end
 end,
 on_use=function(self,event,target,player,data)
  local room=player.room
  room:setPlayerMark(player,chosen,event:getCostData(self).to.id)
  room:setPlayerMark(player,sources,0);room:setPlayerMark(player,done,0)
 end,
})
-- Delayed resolution does not consume the limited skill a second time.
skill:addEffect(fk.TargetConfirmed,{
 global=true,is_delay_effect=true,
 can_refresh=function(self,event,target,player,data)
  return target and target.id==player:getMark(chosen) and player:getMark(done)==0 and data.from~=nil
 end,
 on_refresh=function(self,event,target,player,data)
  local ids=player:getTableMark(sources)
  table.insertIfNeed(ids,data.from.id)
  player.room:setPlayerMark(player,sources,ids)
 end,
 can_trigger=function(self,event,target,player,data)
  return not player.dead and target and not target.dead and target.id==player:getMark(chosen)
   and player:getMark(done)==0 and #player:getTableMark(sources)>=3
 end,
 on_cost=function()return true end,
 on_use=function(self,event,target,player,data)
  local room=player.room;room:setPlayerMark(player,done,1)
  local choices={"zhulv_quzong_turn"}
  if #target:getCardIds("he")>=3 then table.insert(choices,1,"zhulv_quzong_give")end
  local choice=room:askToChoice(target,{choices=choices,skill_name=skill.name,prompt="#zhulv__quzong-result::"..player.id})
  if choice=="zhulv_quzong_give"then
   local ids=room:askToCards(target,{min_num=3,max_num=3,include_equip=true,skill_name=skill.name,cancelable=false,
    prompt="#zhulv__quzong-give::"..player.id})
   if #ids==3 then room:obtainCard(player,ids,false,fk.ReasonGive,target,skill.name)
   elseif not target.dead then target:turnOver()end
  else target:turnOver()end
 end,
})
Fk:loadTranslationTable{
 ["zhulv__quzong"]="驱纵",
 [":zhulv__quzong"]="限定技，轮次开始时，你可以指定一名角色，本轮当其成为三次不同使用者的牌目标后，其需令你获得其三张牌或翻面。",
 [chosen]="驱纵目标",["#zhulv__quzong-choose"]="驱纵：指定本轮的一名角色",
 ["zhulv_quzong_turn"]="翻面",["zhulv_quzong_give"]="令田文获得你的三张牌",
 ["#zhulv__quzong-result"]="驱纵：令 %dest 获得三张牌，或翻面（不足三张只能翻面）",
 ["#zhulv__quzong-give"]="驱纵：选择三张手牌或装备牌交给 %dest",
}
return skill

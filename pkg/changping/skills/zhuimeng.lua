local skill=fk.CreateSkill{name="changping__zhuimeng"}
skill:addEffect(fk.EventPhaseStart,{
 anim_type="offensive",
 can_trigger=function(self,event,target,player,data)
  return target==player and player:hasSkill(skill.name) and player.phase==Player.Start
 end,
 on_cost=function(self,event,target,player,data)
  return player.room:askToSkillInvoke(player,{skill_name=skill.name,prompt="#changping__zhuimeng-invoke"})
 end,
 on_use=function(self,event,target,player,data)
  local room=player.room;local ids=room:getNCards(3)
  if #ids>0 then
   room:moveCardTo(ids,Card.Processing,nil,fk.ReasonJustMove,skill.name,nil,true,player)
   room:fillAG(room.players,ids)
   for _,p in ipairs(room.players)do room:closeAG(p)end
  end
  local start=room.logic:getCurrentEvent().id
  local pending=table.filter(ids,function(id)return Fk:getCardById(id).is_damage_card end)
  while #pending>0 and not player.dead do
   pending=table.filter(pending,function(id)return room:getCardArea(id)==Card.Processing end)
   if #pending==0 then break end
   local use=room:askToUseRealCard(player,{pattern=pending,expand_pile=pending,skill_name=skill.name,
    cancelable=false,skip=true,prompt="#changping__zhuimeng-use",extra_data={bypass_times=true,extraUse=true}})
   if not use then break end
   for _,id in ipairs(Card:getIdList(use.card))do table.removeOne(pending,id)end
   room:useCard(use)
  end
  local dealt=#room.logic:getActualDamageEvents(1,function(e)return e.data.from==player end,nil,start)>0
  local left=table.filter(ids,function(id)return room:getCardArea(id)==Card.Processing end)
  if #left>0 then room:moveCardTo(left,Card.DiscardPile,nil,fk.ReasonPutIntoDiscardPile,skill.name)end
  if not dealt and not player.dead then
   room:askToDiscard(player,{min_num=1,max_num=1,include_equip=true,cancelable=false,skill_name=skill.name})
  end
 end,
})
Fk:loadTranslationTable{
 ["changping__zhuimeng"]="惴梦",
 [":changping__zhuimeng"]="准备阶段，你可以展示牌堆顶三张牌，然后使用其中的伤害牌。若你未因此造成伤害，则你弃置一张牌。",
 ["#changping__zhuimeng-invoke"]="惴梦：是否展示牌堆顶三张牌并使用其中的伤害牌？",
 ["#changping__zhuimeng-use"]="惴梦：使用亮出的伤害牌（遵守距离限制）",
}
Fk:loadTranslationTable{
 ["$changping__zhuimeng1"]="寡人乘龙登天……为何偏偏坠于中途？",
 ["$changping__zhuimeng2"]="金玉积山，本应是福，何以占来是祸？",
}
return skill

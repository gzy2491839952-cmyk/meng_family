local skill = fk.CreateSkill {name="changping__zhulei"}
for _, timing in ipairs {fk.TargetSpecified, fk.TargetConfirmed} do
  skill:addEffect(timing, {
    anim_type="defensive",
    can_trigger=function(self,event,target,player,data)
      return target==player and player:hasSkill(skill.name) and data.card.is_damage_card
        and #table.filter(player:getCardIds("he"),function(id) return not player:prohibitDiscard(id) end)>=2
    end,
    on_cost=function(self,event,target,player,data)
      local cards=player.room:askToDiscard(player,{
        min_num=2,max_num=2,include_equip=true,cancelable=true,skip=true,
        skill_name=skill.name,prompt="#changping__zhulei-discard",
      })
      if #cards==2 then event:setCostData(self,{cards=cards});return true end
    end,
    on_use=function(self,event,target,player,data)
      local room=player.room
      local ids=event:getCostData(self).cards
      local a,b=Fk:getCardById(ids[1]),Fk:getCardById(ids[2])
      local color=a.color==b.color
      local category=a.type==b.type
      room:throwCard(ids,skill.name,player,player)
      -- Apply to the whole use, including every target; preserve existing modifiers.
      if color and category then data.use.additionalDamage=(data.use.additionalDamage or 0)-1 end
      if player.dead then return end
      if color then player:drawCards(1,skill.name) end
      if category and not player.dead then
        local tos=room:askToChooseToMoveCardInBoard(player,{skill_name=skill.name,cancelable=true})
        if #tos==2 then
          room:askToMoveCardInBoard(player,{target_one=tos[1],target_two=tos[2],skill_name=skill.name})
        end
      end
    end,
  })
end
Fk:loadTranslationTable {
  ["changping__zhulei"]="筑垒",
  [":changping__zhulei"]="当你使用伤害牌指定目标后，或当你成为伤害牌的目标后，你可以弃置两张牌，若这两张牌：颜色相同，你摸一张牌；类别相同，你可以移动场上一张牌；若均满足，此牌造成的伤害-1。",
  ["#changping__zhulei-discard"]="筑垒：你可以弃置两张牌，同色摸一张、同类别可移场上一张牌，均满足则此牌伤害-1",
}
Fk:loadTranslationTable{
 ["$changping__zhulei1"]="任他百般搦战，老夫自坚守不出。",
 ["$changping__zhulei2"]="凭此坚垒，叫那秦人枉送性命！",
}
skill:addEffect(fk.GameFinished,{
 global=true,
 can_refresh=function(self,event,target,player,data)
  return (player.general=="changping__lianpo" or player.deputyGeneral=="changping__lianpo")
   and table.contains(data.players or {},player) and player:getMark("changping__lianpo_victory_voice")==0
 end,
 on_refresh=function(self,event,target,player,data)
  player.room:setPlayerMark(player,"changping__lianpo_victory_voice",1)
  player.room:broadcastPlaySound("./packages/meng_family/audio/win/changping__lianpo")
 end,
})
Fk:loadTranslationTable{
 ["!changping__lianpo"]="吾虽老，刀犹利！",
 ["~changping__lianpo"]="颇，尚能饭……尚能战……赵王，为何不召我……",
}
return skill

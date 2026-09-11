local skill=fk.CreateSkill{name="weekly__chenxu"}
local track="weekly_chenxu_owner"
local bonus="@weekly_chenxu_targets"
skill:addEffect(fk.Damage,{
 anim_type="control",
 audio_index={1,2},
 can_trigger=function(self,event,target,player,data)
  return target==player and player:hasSkill(skill.name) and data.to and not data.to.dead and not data.to:isKongcheng()
 end,
 on_cost=function(self,event,target,player,data)
  return player.room:askToSkillInvoke(player,{skill_name=skill.name,prompt="#weekly__chenxu-put::"..data.to.id})
 end,
 on_use=function(self,event,target,player,data)
  local room=player.room
  local to=data.to
  if to.dead or to:isKongcheng() then return end
  local id=room:askToChooseCard(player,{target=to,flag="h",skill_name=skill.name})
  if not id then return end
  to:showCards({id})
  if room:getCardOwner(id)~=to or room:getCardArea(id)~=Card.PlayerHand then return end
  room:setCardMark(Fk:getCardById(id),track,player.id)
  room:moveCards{ids={id},from=to,toArea=Card.DrawPile,drawPilePosition=math.random(math.min(15, #room.draw_pile + 1)),
   moveReason=fk.ReasonJustMove,skillName=skill.name,proposer=player,moveVisible=true}
 end,
})
-- Capture first acquisition and clear tracking before any nested movement.
skill:addEffect(fk.AfterCardsMove,{
 global=true,
 audio_index={1,2},
 can_refresh=function(self,event,target,player,data)return event:getSkillData(self,"weekly_chenxu_gains")==nil end,
 on_refresh=function(self,event,target,player,data)
  local room=player.room
  local gains={}
  for _,move in ipairs(data)do
   if move.to and move.toArea==Card.PlayerHand then
    for _,info in ipairs(move.moveInfo)do
     local card=Fk:getCardById(info.cardId)
     local owner=card:getMark(track)
     if owner~=0 then
      room:setCardMark(card,track,0)
      table.insert(gains,{owner=owner,to=move.to.id})
     end
    end
   end
  end
  event:setSkillData(self,"weekly_chenxu_gains",gains)
 end,
 can_trigger=function(self,event,target,player,data)
  return player:hasSkill(skill.name) and table.find(event:getSkillData(self,"weekly_chenxu_gains") or {},function(g)return g.owner==player.id end)~=nil
 end,
 on_cost=function()return true end,
 on_use=function(self,event,target,player,data)
  local room=player.room
  for _,gain in ipairs(event:getSkillData(self,"weekly_chenxu_gains") or {})do
   if player.dead then break end
   if gain.owner==player.id then
    if gain.to==player.id then
     if player:isWounded()then room:recover{who=player,num=1,recoverBy=player,skillName=skill.name}end
    else
     local to=room:getPlayerById(gain.to)
     if not to.dead and not to:isNude()then
      local id=room:askToChooseCard(player,{target=to,flag="he",skill_name=skill.name})
      if id then room:obtainCard(player,id,true,fk.ReasonPrey,player,skill.name)end
     end
     if not player.dead then room:addPlayerMark(player,bonus,1)end
    end
   end
  end
 end,
})
skill:addEffect("targetmod",{
 extra_target_func=function(self,player,cardSkill,card)
  if card and card.trueName=="slash" then return player:getMark(bonus)end
 end,
})
skill:addEffect(fk.AfterCardUseDeclared,{
 global=true,
 can_refresh=function(self,event,target,player,data)return target==player and data.card.trueName=="slash" and player:getMark(bonus)>0 end,
 on_refresh=function(self,event,target,player,data)player.room:setPlayerMark(player,bonus,0)end,
})
skill:addEffect(fk.GameFinished,{
 global=true,
 can_refresh=function(self,event,target,player,data)
  return (player.general=="weekly__kuangzhang" or player.deputyGeneral=="weekly__kuangzhang")
   and table.contains(data.players or {},player) and player:getMark("weekly__kuangzhang_victory_voice")==0
 end,
 on_refresh=function(self,event,target,player,data)
  player.room:setPlayerMark(player,"weekly__kuangzhang_victory_voice",1)
  player.room:broadcastPlaySound("./packages/meng_family/audio/win/weekly__kuangzhang")
 end,
})
Fk:loadTranslationTable{
 ["$weekly__chenxu1"]="燕国内乱，此正进兵之时！",
 ["$weekly__chenxu2"]="燕都危如累卵，看我趁虚取之！",
 ["!weekly__kuangzhang"]="燕垒既平，楚锋亦折，天下尽知，齐军锋锐！",
 ["~weekly__kuangzhang"]="半生征战为齐……余年且付田园……",

 ["weekly__chenxu"]="趁虚",
 [":weekly__chenxu"]="当你造成伤害后，你可以将受伤角色的一张手牌明置放入牌堆前15张牌中的随机位置。此牌首次被其他角色获得后，你获得其一张牌，且你下一张使用【杀】的目标上限+1（可累加）；首次被你获得后，你回复1点体力。",
 ["#weekly__chenxu-put"]="趁虚：你可以将%dest的一张手牌明置放入牌堆前15张牌中的随机位置",
 ["@weekly_chenxu_targets"]="趁虚加目标",
}
return skill

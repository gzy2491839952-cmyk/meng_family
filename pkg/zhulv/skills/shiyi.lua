local skill=fk.CreateSkill{name="zhulv__shiyi",tags={Skill.Limited}}
skill:addEffect("active",{
 anim_type="support",card_num=0,target_num=0,
 can_use=function(self,player)
  return player.phase==Player.Play and player:usedSkillTimes(skill.name,Player.HistoryGame)==0
 end,
 on_use=function(self,room,effect)
  local player=effect.from
  local targets=table.filter(room.alive_players,function(p)return p:isWounded()end)
  room:sortByAction(targets)
  local supporters={}
  for _,p in ipairs(targets)do
   if not p.dead then
    local diff=p.maxHp-p:getHandcardNum()
    if diff>0 then
     room.tag.zhulv_shiyi_stack=room.tag.zhulv_shiyi_stack or {}
     local ctx={recipient=p,ids={}}
     table.insert(room.tag.zhulv_shiyi_stack,ctx)
     p:drawCards(diff,skill.name)
     table.remove(room.tag.zhulv_shiyi_stack)
     if #ctx.ids>=2 then table.insert(supporters,p)end
    elseif diff<0 then
     room:askToDiscard(p,{min_num=-diff,max_num=-diff,include_equip=false,skill_name=skill.name,
      cancelable=false,prompt="#zhulv__shiyi-adjust"})
    end
   end
  end
  for _,p in ipairs(supporters)do
   if player.dead then break end
   if not p.dead and room:askToSkillInvoke(p,{skill_name=skill.name,prompt="#zhulv__shiyi-return::"..player.id})then
    player:drawCards(1,skill.name)
   end
  end
 end,
})
skill:addEffect(fk.AfterCardsMove,{
 global=true,
 can_refresh=function(self,event,target,player,data)
  local stack=player.room.tag.zhulv_shiyi_stack or {}
  return #stack>0 and stack[#stack].recipient==player
 end,
 on_refresh=function(self,event,target,player,data)
  local stack=player.room.tag.zhulv_shiyi_stack;local ctx=stack[#stack]
  for _,m in ipairs(data)do
   if m.to==player and m.toArea==Card.PlayerHand and m.moveReason==fk.ReasonDraw and m.skillName==skill.name then
    for _,i in ipairs(m.moveInfo)do table.insertIfNeed(ctx.ids,i.cardId)end
   end
  end
 end,
})
Fk:loadTranslationTable{
 ["zhulv__shiyi"]="市义",
 [":zhulv__shiyi"]="限定技，出牌阶段，你可以令所有受伤角色将手牌数调整至体力上限，每名因此获得至少两张牌的角色可以令你摸一张牌。",
 ["#zhulv__shiyi-adjust"]="市义：将手牌数调整至体力上限",
 ["#zhulv__shiyi-return"]="市义：是否令 %dest 摸一张牌？",
}
return skill

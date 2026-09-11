local skill=fk.CreateSkill{name="weekly__aili",tags={Skill.Switch},attached_skill_name="weekly__aili_other&"}
skill:addEffect(fk.EventPhaseChanging,{
 can_trigger=function(self,event,target,player,data)
  return player:hasSkill(skill.name) and player:getSwitchSkillState(skill.name)==fk.SwitchYang
   and target and not target.dead and target.gender==General.Male and data.phase==Player.Discard and not data.skipped
 end,
 on_cost=function(self,event,target,player,data)
  return player.room:askToSkillInvoke(player,{skill_name=skill.name,prompt="#weekly__aili-skip::"..target.id})
 end,
 on_use=function(self,event,target,player,data)
  player.room:damage{from=player,to=player,damage=1,damageType=fk.IceDamage,skillName=skill.name}
  data.skipped=true
 end,
})
-- The owner is also a male current-turn character; attached skills are only
-- distributed to other players by the engine, so expose his own Yin action here.
skill:addEffect("active",{
 card_num=0,target_num=0,anim_type="support",
 can_use=function(self,player)
  local room=player.room or Fk:currentRoom()
  return player.gender==General.Male and player.phase==Player.Play and room.current==player
   and player:getSwitchSkillState(skill.name)==fk.SwitchYin
 end,
 on_use=function(self,room,effect)
  local player=effect.from
  room:damage{from=player,to=player,damage=1,damageType=fk.IceDamage,skillName=skill.name}
  if not player.dead then player:drawCards(3,skill.name)end
 end,
})
Fk:loadTranslationTable{
 ["weekly__aili"]="哀鲤",
 [":weekly__aili"]="转换技，①你可以对你造成1点冰冻伤害以令当前回合的男性角色跳过弃牌阶段；②当前回合的男性角色可于出牌阶段对自己造成1点冰冻伤害以令你摸三张牌。",
 ["#weekly__aili-skip"]="哀鲤：对自己造成1点冰冻伤害，令 %dest 跳过弃牌阶段？",
}
return skill

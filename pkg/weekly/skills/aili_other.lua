local name="weekly__aili"
local skill=fk.CreateSkill{name="weekly__aili_other&"}
local function eligible(p)return not p.dead and p:hasSkill(name) and p:getSwitchSkillState(name)==fk.SwitchYin end
skill:addEffect("active",{
 anim_type="support",card_num=0,target_num=1,
 can_use=function(self,player)
  local room=player.room or Fk:currentRoom()
  return player.gender==General.Male and player.phase==Player.Play and room.current==player
   and table.find(room.alive_players,eligible)~=nil
 end,
 target_filter=function(self,player,to,selected)return #selected==0 and eligible(to)end,
 on_use=function(self,room,effect)
  local from,to=effect.from,effect.tos[1]
  if not eligible(to)then return end
  room:setPlayerMark(to,MarkEnum.SwithSkillPreName..name,fk.SwitchYang)
  to:broadcastSkillInvoke(name)
  room:damage{from=from,to=from,damage=1,damageType=fk.IceDamage,skillName=name}
  if not to.dead then to:drawCards(3,name)end
 end,
})
Fk:loadTranslationTable{
 ["weekly__aili_other&"]="哀鲤",
 [":weekly__aili_other&"]="你的回合内，若你为男性，出牌阶段可以选择处于②状态的龙阳君：你对自己造成1点冰冻伤害，然后其摸三张牌，哀鲤切回①。",
}
return skill

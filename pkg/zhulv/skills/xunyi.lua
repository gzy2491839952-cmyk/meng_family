local T=require "packages.meng_family.pkg.zhulv.tiandi"
local skill=fk.CreateSkill{name="zhulv__xunyi",tags={Skill.Limited}}
skill:addEffect(fk.EnterDying,{
 can_trigger=function(self,event,target,player,data)
  return target~=player and target and not target.dead and player:hasSkill(skill.name)
   and player:usedSkillTimes(skill.name,Player.HistoryGame)==0
 end,
 on_cost=function(self,event,target,player,data)
  return player.room:askToSkillInvoke(player,{skill_name=skill.name,prompt="#zhulv__xunyi-invoke::"..target.id})
 end,
 on_use=function(self,event,target,player,data)
  local room=player.room
  local ownHp,otherHp=player.hp,target.hp
  -- Rescue the original dying player first. The transfer is a health change,
  -- not damage, loss of HP or recovery; it preserves each maximum HP.
  room:changeHp(target,ownHp-otherHp,nil,skill.name)
  if player.dead then return end
  room:setPlayerMark(player,"zhulv_xunyi_exchanging",1)
  room:changeHp(player,otherHp-player.hp,nil,skill.name)
  room:setPlayerMark(player,"zhulv_xunyi_exchanging",0)
  local current=room.current
  if not player.dead and current and not current.dead then
   local ids=table.simpleClone(current:getCardIds("h"))
   if #ids>0 then current:showCards(ids)end
   local n=#table.filter(ids,function(id)return T.suit(current,id)==Card.Heart end)
   if n>0 then room:recover{who=player,num=n,recoverBy=player,skillName=skill.name}end
  end
  if not player.dead and player.hp<1 and not player.dying then room:enterDying{who=player}end
 end,
})
skill:addEffect(fk.BeforeHpChanged,{
 global=true,
 can_refresh=function(self,event,target,player,data)
  return target==player and player:getMark("zhulv_xunyi_exchanging")>0 and data.skillName==skill.name and data.reason==nil
 end,
 on_refresh=function(self,event,target,player,data)data.preventDying=true end,
})
Fk:loadTranslationTable{
 ["zhulv__xunyi"]="徇义",
 [":zhulv__xunyi"]="限定技，其他角色进入濒死状态时，你可以与其交换体力值，然后你展示当前回合角色的手牌并回复其中红桃牌数的体力。",
 ["#zhulv__xunyi-invoke"]="徇义：是否与 %dest 交换体力，然后展示当前回合角色手牌并按红桃数回复？",
}
return skill

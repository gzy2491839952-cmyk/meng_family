local U=require "packages.meng_family.pkg.changping.zhaodan_util"
local skill=fk.CreateSkill{name="changping__zeshuai"}
for _,timing in ipairs{fk.GameStart,fk.TurnStart}do
 skill:addEffect(timing,{
  anim_type="support",
  can_trigger=function(self,event,target,player,data)
   return (timing==fk.GameStart or target==player) and player:hasSkill(skill.name)
     and not U.onBoard(player.room) and #player:getAvailableEquipSlots(Card.SubtypeTreasure)>0
  end,
  on_cost=function(self,event,target,player,data)
   return player.room:askToSkillInvoke(player,{skill_name=skill.name,prompt="#changping__zeshuai-equip"})
  end,
  on_use=function(self,event,target,player,data)
   if not player.dead and not U.onBoard(player.room) then
    player.room:moveCardIntoEquip(player,U.tokenId(player.room),skill.name,true,player)
   end
  end,
 })
end
skill:addEffect(fk.TurnEnd,{
 anim_type="control",
 can_trigger=function(self,event,target,player,data)
  if not target or target.dead or not player:hasSkill(skill.name) then return false end
  local holder,id=U.onBoard(player.room)
  if holder~=target or player.room:getCardArea(id)~=Card.PlayerEquip then return false end
  return #player.room.logic:getActualDamageEvents(1,function(e)return e.data.from==target end,Player.HistoryTurn)==0
    and table.find(player.room.alive_players,function(p)return p~=holder and p:canMoveCardIntoEquip(Fk:getCardById(id),true)end)~=nil
 end,
 on_cost=function(self,event,target,player,data)
  local room=player.room;local holder,id=U.onBoard(room)
  if holder~=target then return false end
  local tos=room:askToChoosePlayers(player,{targets=table.filter(room.alive_players,function(p)
   return p~=holder and p:canMoveCardIntoEquip(Fk:getCardById(id),true)
  end),min_num=1,max_num=1,cancelable=true,skill_name=skill.name,prompt="#changping__zeshuai-move"})
  if #tos==1 then event:setCostData(self,{tos=tos,id=id});return true end
 end,
 on_use=function(self,event,target,player,data)
  local room=player.room;local cost=event:getCostData(self);local to=cost.tos[1]
  if not to.dead and room:getCardOwner(cost.id)==target and room:getCardArea(cost.id)==Card.PlayerEquip then
   room:moveCardIntoEquip(to,cost.id,skill.name,true,player)
  end
 end,
})
Fk:loadTranslationTable{
 ["changping__zeshuai"]="择帅",
 [":changping__zeshuai"]="游戏开始时或回合开始时，若场上没有【赵帅符】，你可以将【赵帅符】置于你的装备区；拥有【赵帅符】的角色的回合结束时，若其本回合未造成伤害，你可以移动【赵帅符】。",
 ["#changping__zeshuai-equip"]="择帅：是否将【赵帅符】置入你的装备区？",
 ["#changping__zeshuai-move"]="择帅：你可以将【赵帅符】移给另一名角色",
}
Fk:loadTranslationTable{
 ["$changping__zeshuai1"]="廉颇久守无功，岂能坐待秦退！",
 ["$changping__zeshuai2"]="虎符既授，长平胜负，悉托将军！",
}
skill:addEffect(fk.GameFinished,{
 global=true,
 can_refresh=function(self,event,target,player,data)
  return (player.general=="changping__zhaodan" or player.deputyGeneral=="changping__zhaodan")
   and table.contains(data.players or {},player) and player:getMark("changping__zhaodan_victory_voice")==0
 end,
 on_refresh=function(self,event,target,player,data)
  player.room:setPlayerMark(player,"changping__zhaodan_victory_voice",1)
  player.room:broadcastPlaySound("./packages/meng_family/audio/win/changping__zhaodan")
 end,
})
Fk:loadTranslationTable{
 ["!changping__zhaodan"]="秦军既退，寡人今夜……总算能安寝了。",
 ["~changping__zhaodan"]="贪得十七城……竟失举国之兵……",
}
return skill

local skill=fk.CreateSkill{name="#changping__zhaoshuaifu_skill"}
local used="changping_zhaoshuaifu_used-turn"
skill:addEffect(fk.AfterCardsMove,{
 anim_type="control",
 can_trigger=function(self,event,target,player,data)
  if not player:hasSkill(skill.name) or player:getMark(used)>0 then return false end
  local discarded=table.find(data,function(move)return move.from==player and move.moveReason==fk.ReasonDiscard and #move.moveInfo>0 end)
  return discarded~=nil and table.find(player.room:getOtherPlayers(player,false),function(p)return not p:isNude()end)~=nil
 end,
 on_cost=function(self,event,target,player,data)
  local tos=player.room:askToChoosePlayers(player,{targets=table.filter(player.room:getOtherPlayers(player,false),function(p)return not p:isNude()end),
   min_num=1,max_num=1,cancelable=true,skill_name=skill.name,prompt="#changping__zhaoshuaifu-prey"})
  if #tos==1 then event:setCostData(self,{tos=tos});return true end
 end,
 on_use=function(self,event,target,player,data)
  local room=player.room;local to=event:getCostData(self).tos[1]
  room:setPlayerMark(player,used,1)
  if to.dead or to:isNude()then return end
  local id=room:askToChooseCard(player,{target=to,flag="he",skill_name=skill.name})
  if id then room:obtainCard(player,id,false,fk.ReasonPrey,player,skill.name)end
 end,
})
Fk:loadTranslationTable{
 ["changping__zhaoshuaifu"]="赵帅符",
 ["#changping__zhaoshuaifu_skill"]="赵帅符",
 [":changping__zhaoshuaifu"]="装备牌·宝物。每回合限一次，当你弃置牌时，你可以获得一名其他角色的一张牌。",
 ["#changping__zhaoshuaifu-prey"]="赵帅符：你可以获得一名其他角色的一张手牌或装备牌",
}
return skill

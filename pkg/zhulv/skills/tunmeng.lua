local M=require "packages.meng_family.pkg.zhulv.tiandi"
local skill=fk.CreateSkill{name="dream__tunmeng"}
skill:addEffect(fk.EventPhaseStart,{
 can_trigger=function(self,event,target,p,data)
  return target==p and p.phase==Player.Start and p:hasSkill(skill.name) and table.find(p.room.alive_players,function(t)return t.chained and not t:isKongcheng()end)~=nil
 end,
 on_cost=function(self,event,target,p,data)return p.room:askToSkillInvoke(p,{skill_name=skill.name})end,
 on_use=function(self,event,target,p,data)
  local room=p.room
  local tos=table.filter(room.alive_players,function(t)return t.chained and not t:isKongcheng()end);room:sortByAction(tos)
  local votes,result=M.vote(room,tos,skill.name)
  if result==Card.Red then
   for _,v in ipairs(votes)do if v.color==Card.Black and not v.player.dead and v.player.chained then v.player:setChainState(false)end end
  elseif result==Card.Black and not p.dead then
   local ids={}
   for _,v in ipairs(votes)do
    if v.color==Card.Black and room:getCardOwner(v.id)==v.player and room:getCardArea(v.id)==Card.PlayerHand then table.insert(ids,v.id)end
   end
   if #ids>0 then room:obtainCard(p,ids,true,fk.ReasonPrey,p,skill.name)end
  end
 end,
})
Fk:loadTranslationTable{
 ["dream__tunmeng"]="吞盟",
 [":dream__tunmeng"]="准备阶段，你可以令横置角色议事，若结果为：红色，重置意见为黑的角色；黑色，你获得所有黑色议事牌。",
 ["#dream__tunmeng-vote"]="吞盟议事：秘密选择一张手牌，所有人选定后同时展示",
}
return skill

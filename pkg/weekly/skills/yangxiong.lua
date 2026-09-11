local M=require "packages.meng_family.pkg.weekly.zhaoyong"
local skill=fk.CreateSkill{name="weekly__yangxiong",tags={Skill.Lord}}
local function helps(lord,from,card)
 return lord~=from and not lord.dead and lord:hasSkill(skill.name) and from.kingdom=="meng_zhao" and #M.matching(lord,card)>0
end
skill:addEffect("targetmod",{
 bypass_distances=function(self,player,card_skill,card,to)
  return table.find(Fk:currentRoom().alive_players,function(p)return helps(p,player,card)end)~=nil
 end,
})
skill:addEffect(fk.CardUsing,{
 can_trigger=function(self,event,target,player,data)return helps(player,data.from,data.card)end,
 on_cost=function(self,event,target,player,data)
  local ids=table.filter(M.matching(player,data.card),function(id)return not player:prohibitDiscard(id)end)
  if #ids==0 then return false end
  local selected=player.room:askToChooseCards(player,{target=player,flag={card_data={{"$Equip",ids}}},
   min=1,max=1,skill_name=skill.name,cancelable=true,prompt="#weekly__yangxiong-boost"})
  if #selected>0 then event:setCostData(self,{cards=selected});return true end
 end,
 on_use=function(self,event,target,player,data)
  local room=player.room;local id=event:getCostData(self).cards[1]
  room:throwCard({id},skill.name,player,player)
  -- A replaced discard that left the offered card equipped did not pay the cost.
  if room:getCardOwner(id)==player and room:getCardArea(id)==Card.PlayerEquip then return end
  data.additionalDamage=(data.additionalDamage or 0)+1
  data.additionalRecover=(data.additionalRecover or 0)+1
  data.extra_data=data.extra_data or {}
  data.extra_data.additionalDrank=(data.extra_data.additionalDrank or 0)+1
 end,
})
Fk:loadTranslationTable{
 ["weekly__yangxiong"]="扬雄",
 [":weekly__yangxiong"]="主公技，其他赵势力角色使用与你装备栏内同名的基本牌无距离限制，且你可以弃置其中一张令此牌基础值+1。",
 ["#weekly__yangxiong-boost"]="扬雄：可弃置装备栏内一张同名基本牌，令此牌基础值+1",
}
return skill

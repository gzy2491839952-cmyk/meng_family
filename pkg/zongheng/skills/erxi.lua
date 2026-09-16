local M=require "packages.meng_family.pkg.zongheng.alliance"
local skill=fk.CreateSkill{name="hqzhangyi__erxi"}
local function pairsFor(p)
 local room=p.room
 return table.filter(room.alive_players,function(q)
  return table.find(room.alive_players,function(other)return other~=q and q:canPindian(other)end)~=nil
 end)
end
skill:addEffect(fk.CardUsing,{
 global=true,
 can_trigger=function(self,e,t,p,d)
  return t==p and M.effect(p,skill.name) and d.from==p and table.contains(d.tos,p) and #pairsFor(p)>=2
 end,
 on_cost=function(self,e,t,p,d)
  local room=p.room
  local first=room:askToChoosePlayers(p,{targets=pairsFor(p),min_num=1,max_num=1,cancelable=true,
   skill_name=skill.name,prompt="#hq-erxi-first"})[1]
  if not first then return false end
  local tos=table.filter(room.alive_players,function(q)return q~=first and first:canPindian(q)end)
  local second=room:askToChoosePlayers(p,{targets=tos,min_num=1,max_num=1,cancelable=false,
   skill_name=skill.name,prompt="#hq-erxi-second"})[1]
  if second then e:setCostData(self,{first,second});return true end
 end,
 on_use=function(self,e,t,p,d)
  local tos=e:getCostData(self)
  if not tos[1]:canPindian(tos[2])then return end
  local result=tos[1]:pindian({tos[2]},skill.name)
  local winner=result.results[tos[2]] and result.results[tos[2]].winner
  if winner and not winner.dead and winner~=p and not p:isProhibited(winner,d.card)then
   d:removeTarget(p)
   if not table.contains(d.tos,winner)then d:addTarget(winner)end
  end
 end,
})
local function eligible(p,d)
 local low=math.min(d.fromCard.number,d.toCard.number)
 local high=math.max(d.fromCard.number,d.toCard.number)
 return table.filter(p:getCardIds("he"),function(id)
  local n=Fk:getCardById(id).number;return n<low or n>high
 end)
end
skill:addEffect(fk.PindianResultConfirmed,{
 priority=100,
 can_trigger=function(self,e,t,p,d)
  return p:hasSkill(skill.name) and p~=d.from and p~=d.to and #eligible(p,d)>0
 end,
 on_cost=function(self,e,t,p,d)
  local ids=eligible(p,d)
  local chosen=p.room:askToCards(p,{min_num=1,max_num=1,include_equip=true,skill_name=skill.name,
   pattern=tostring(Exppattern{id=ids}),cancelable=true,prompt="#hq-erxi-bahe"})
  if #chosen==1 then e:setCostData(self,chosen);return true end
 end,
 on_use=function(self,e,t,p,d)
  -- Set both the single result and the parent result: native pindian copies
  -- winner into the single event, so updating only that copy is insufficient.
  d.winner=nil
  local parent=p.room.logic:getCurrentEvent():findParent(GameEvent.Pindian,true)
  if parent and parent.data.results[d.to]then parent.data.results[d.to].winner=nil end
  p.room:sendLog{type="#hq-alliance-nowin",from=p.id}
  p.room:recastCard(e:getCostData(self),p,skill.name)
 end,
})
Fk:loadTranslationTable{
 ["hqzhangyi__erxi"]="饵戏",
 [":hqzhangyi__erxi"]="连横技，你对自己使用牌时，可令两名角色拼点，然后将此牌的目标由你转移给赢者。捭阖：在你未参与的一场拼点中，你可重铸点数小于两张拼点牌的较小点数或大于较大点数的一张牌，令双方均视为没赢。",
 ["#hq-erxi-first"]="饵戏：选择拼点发起者（取消则不发动）",
 ["#hq-erxi-second"]="饵戏：选择另一名拼点角色",
 ["#hq-erxi-bahe"]="饵戏·捭阖：可重铸一张点数在两张拼点牌区间之外的牌，令双方均没赢",
}
return skill

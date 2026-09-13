local C=require "packages.meng_family.pkg.changping.central"
local skill=fk.CreateSkill{name="hqgod__fengrang"}
local fix={
 can_trigger=function(self,e,t,p,d)return t==p and p:hasSkill(skill.name) and p:getLostHp()>0 and #C.cards(p.room)>#C.fixed(p.room)end,
 on_cost=function(self,e,t,p,d)return p.room:askToSkillInvoke(p,{skill_name=skill.name})end,
 on_use=function(self,e,t,p,d)
  local room=p.room;local fixed=C.fixed(room)
  local ids=table.filter(C.cards(room),function(id)return not table.contains(fixed,id)end)
  local chosen={}
  for i=1,math.min(p:getLostHp(),#ids)do
   room:fillAG(p,ids);local id=room:askToAG(p,{id_list=ids,cancelable=true,skill_name=skill.name});room:closeAG(p)
   if not id or id==-1 then break end
   table.insert(chosen,id);table.removeOne(ids,id)
  end
  C.fix(room,chosen)
 end,
}
skill:addEffect(fk.Damaged,fix)
local phase=table.simpleClone(fix)
phase.can_trigger=function(self,e,t,p,d)return p.phase==Player.Play and fix.can_trigger(self,e,t,p,d)end
skill:addEffect(fk.EventPhaseEnd,phase)
skill:addEffect(fk.TurnEnd,{
 can_trigger=function(self,e,t,p,d)return p:hasSkill(skill.name) and p:getLostHp()>0 and #p.room.alive_players>1 end,
 on_cost=function(self,e,t,p,d)
  local others=table.filter(p.room.alive_players,function(who)return who~=p end)
  local tos=p.room:askToChoosePlayers(p,{targets=others,min_num=1,max_num=math.min(p:getLostHp(),#others),cancelable=true,skill_name=skill.name,prompt="#hqfengrang-target"})
  if #tos==0 then return false end;e:setCostData(self,tos);return true
 end,
 on_use=function(self,e,t,p,d)
  local room=p.room;local tos=e:getCostData(self);room:sortByAction(tos)
  for _,to in ipairs(tos)do
   if p.dead then break end
   if not to.dead then
    local suits={};for _,id in ipairs(C.cards(room))do table.insertIfNeed(suits,Fk:getCardById(id).suit)end
    local ids=table.filter(to:getCardIds("he"),function(id)return not to:prohibitDiscard(id) and not table.contains(suits,Fk:getCardById(id).suit)end)
    local discarded={}
    if #ids>0 then discarded=room:askToDiscard(to,{min_num=1,max_num=1,include_equip=true,cancelable=true,pattern=tostring(Exppattern{id=ids}),skill_name=skill.name,prompt="#hqfengrang-discard"})end
    if #discarded==0 and not p.dead and not to.dead then
     local card=Fk:cloneCard("hqice__slash");card.skillName=skill.name
     room:useCard{from=p,tos={to},card=card,extraUse=true}
    end
   end
  end
 end,
})
Fk:loadTranslationTable{
 ["hqgod__fengrang"]="封壤",
 [":hqgod__fengrang"]="出牌阶段结束时，或当你受到伤害后，你可以将至多X张中央区的牌固定。回合结束时，你可以令至多X名其他角色依次选择一项：1.弃置一张花色未在中央区出现的牌；2.你视为对其使用一张冰【杀】。（X为你已损失体力值）<br>中央区：本回合进入弃牌堆的牌。固定牌不会因回合结束移去；中央区牌被使用后移去，但仍可处于弃牌堆。",
 ["#hqfengrang-target"]="封壤：选择至多X名其他角色",
 ["#hqfengrang-discard"]="封壤：弃置一张中央区没有其花色的牌，否则受到冰杀",
}
return skill

local skill=fk.CreateSkill{name="dream__pizhi"}
skill:addEffect(fk.RoundStart,{
 can_trigger=function(self,event,target,p,data)return p:hasSkill(skill.name)end,
 on_cost=function(self,event,target,p,data)return p.room:askToSkillInvoke(p,{skill_name=skill.name})end,
 on_use=function(self,event,target,p,data)
  local room=p.room;local n=#room.alive_players
  local ids=room:getNCards(n)
  room:moveCardTo(ids,Card.Processing,nil,fk.ReasonJustMove,skill.name,nil,true)
  local participants=table.simpleClone(room.alive_players);room:sortByAction(participants)
  for _,other in ipairs(participants)do
   local remaining=table.filter(ids,function(id)return room:getCardArea(id)==Card.Processing end)
   if #remaining==0 or p.dead then break end
   if not other.dead then
    local choices={"dream_pizhi_exchange"}
    if not other.chained then table.insert(choices,1,"dream_pizhi_chain")end
    local c=room:askToChoice(other,{choices=choices,skill_name=skill.name})
    if c=="dream_pizhi_chain"then other:setChainState(true)end
    if not other.dead and not p.dead then
     local chooser=c=="dream_pizhi_chain" and other or p
     room:fillAG(chooser,remaining)
     local id=room:askToAG(chooser,{id_list=remaining,cancelable=false,skill_name=skill.name})
     room:closeAG(chooser)
     room:obtainCard(chooser,id,true,fk.ReasonPrey,chooser,skill.name)
     if c=="dream_pizhi_exchange" and other~=p and not other.dead and not p.dead and #p:getCardIds("he")>0 then
      local gift=room:askToCards(p,{min_num=1,max_num=1,include_equip=true,cancelable=false,skill_name=skill.name,prompt="#dream__pizhi-give::"..other.id})
      if #gift>0 then room:obtainCard(other,gift,false,fk.ReasonGive,p,skill.name)end
     end
    end
   end
  end
  local rest=table.filter(ids,function(id)return room:getCardArea(id)==Card.Processing end)
  if #rest>0 then room:moveCardTo(rest,Card.DiscardPile,nil,fk.ReasonPutIntoDiscardPile,skill.name,nil,true)end
 end,
})
Fk:loadTranslationTable{
 ["dream__pizhi"]="睥峙",
 [":dream__pizhi"]="每轮开始时，你可以亮出牌堆顶X张牌（X为存活的角色数），令所有角色依次选择一项：1.横置并获得其中一张；2.令你获得其中一张并交给其一张牌。",
 ["dream_pizhi_chain"]="横置并获得一张亮出的牌",["dream_pizhi_exchange"]="令梦田地获得一张，然后交给你一张牌",
 ["#dream__pizhi-give"]="睥峙：交给 %dest 一张牌",
}
return skill

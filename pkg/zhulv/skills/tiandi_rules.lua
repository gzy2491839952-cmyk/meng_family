local M=require "packages.meng_family.pkg.zhulv.tiandi"
local skill=fk.CreateSkill{name="dream__tiandi_rules"}
skill:addEffect(fk.BeforeCardEffect,{
 global=true,
 can_refresh=function(self,event,target,p,data)
  return data.from==p and data.to and data.card.trueName=="fire_attack" and
   ((data.extra_data and data.extra_data.dream_pianxiang) or M.affected(data.to))
 end,
 on_refresh=function(self,event,target,p,data)
  data.skill=Fk.skills["dream__fire_attack"]
 end,
})
skill:addEffect(fk.CardShown,{
 global=true,
 can_refresh=function(self,event,target,p,data)return data.from==p and M.affected(p)end,
 on_refresh=function(self,event,target,p,data)
  data.dream_lingjue_suit=Card.Spade
  local shown={}
  for _,id in ipairs(data.cardIds)do
   local c=Fk:getCardById(id)
   table.insert(shown,Fk:cloneCard(c.name,Card.Spade,c.number))
  end
  p.room:showVirtualCard(shown,p,{type="#dream_lingjue_spade",from=p.id,card=data.cardIds},p.room.logic:getCurrentEvent().id)
  p.room:sendLog{type="#dream_lingjue_spade",from=p.id,card=data.cardIds}
 end,
})
Fk:loadTranslationTable{["dream__tiandi_rules"]="梦田地规则"}
return skill

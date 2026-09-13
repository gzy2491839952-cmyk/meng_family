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
skill:addEffect(fk.GameFinished,{
 global=true,
 can_refresh=function(self,event,target,p,data)
  return (p.general=="dream__tiandi" or p.deputyGeneral=="dream__tiandi")
   and table.contains(data.players or {},p) and p:getMark("dream__tiandi_victory_voice")==0
 end,
 on_refresh=function(self,event,target,p,data)
  p.room:setPlayerMark(p,"dream__tiandi_victory_voice",1)
  p.room:broadcastPlaySound("./packages/meng_family/audio/win/dream__tiandi")
 end,
})
Fk:loadTranslationTable{
 ["~dream__tiandi"]="列国之玺皆已在此……为何朕，还是不能瞑目……",
 ["!dream__tiandi"]="周室失其鹿，诸侯逐踪，唯朕得之！",
}
return skill

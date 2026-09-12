local M=require "packages.meng_family.pkg.changping.zhaokuo_dream"
local skill=fk.CreateSkill{name="dream__yiqi"}
local function dealtDamage(data)
 for _,n in pairs(data.damageDealt or {})do if n>0 then return true end end
 return false
end
skill:addEffect(fk.EventPhaseStart,{
 can_trigger=function(self,event,target,p,data)
  return target==p and p:hasSkill(skill.name) and (p.phase==Player.Start or p.phase==Player.Finish) and #p:getPile(M.pile)>0
 end,
 on_cost=function(self,event,target,p,data)
  local room=p.room;local ids=table.simpleClone(p:getPile(M.pile))
  room:fillAG(p,ids)
  local id=room:askToAG(p,{id_list=ids,cancelable=true,skill_name=skill.name});room:closeAG(p)
  if not id or id==-1 then return false end
  local use=room:askToUseVirtualCard(p,{name=Fk:getCardById(id,true).name,skill_name=skill.name,cancelable=true,skip=true})
  if use then event:setCostData(self,{use=use,id=id});return true end
 end,
 on_use=function(self,event,target,p,data)
  local cost=event:getCostData(self)
  if not table.contains(p:getPile(M.pile),cost.id)then return end
  cost.use.extra_data=cost.use.extra_data or {}
  cost.use.extra_data.dream_yiqi={owner=p.id,id=cost.id}
  p.room:useCard(cost.use)
 end,
})
skill:addEffect(fk.CardUseFinished,{
 global=true,is_delay_effect=true,
 can_refresh=function(self,event,target,p,data)
  local c=data.extra_data and data.extra_data.dream_yiqi
  return c and c.owner==p.id and data.damageDealt and table.contains(p:getPile(M.pile),c.id)
   and dealtDamage(data)
 end,
 on_refresh=function(self,event,target,p,data)
  local id=data.extra_data.dream_yiqi.id
  p.room:moveCardTo(id,Card.DiscardPile,nil,fk.ReasonPutIntoDiscardPile,skill.name,nil,true)
 end,
})
Fk:loadTranslationTable{
 ["dream__yiqi"]="刈旗",
 [":dream__yiqi"]="准备阶段与结束阶段，你可以视为使用一张因【披矢】置于武将牌上的牌，若此牌造成伤害则弃置之。",
}
return skill

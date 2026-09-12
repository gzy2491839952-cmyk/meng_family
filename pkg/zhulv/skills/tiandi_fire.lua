local M=require "packages.meng_family.pkg.zhulv.tiandi"
local skill=fk.CreateSkill{name="dream__fire_attack"}
skill:addEffect("cardskill",{
 on_effect=function(self,room,effect)
  local from,to=effect.from,effect.to
  if from.dead or to.dead or to:isKongcheng()then return end
  local id=room:askToCards(to,{min_num=1,max_num=1,include_equip=false,cancelable=false,
   skill_name="fire_attack_skill",prompt="#fire_attack-show:"..from.id})[1]
  if not id then return end
  local shown=M.revealed.shown(to,id)
  local raw=Fk:getCardById(id)
  local card=Fk:cloneCard(raw.name,M.suit(to,id),raw.number)
  M.present(to,{id})
  if from.dead or to.dead then return end
  effect.extra_data=effect.extra_data or {};effect.extra_data.fire_attack_show={id}
  local params={min_num=1,max_num=1,include_equip=false,cancelable=true,skill_name="fire_attack_skill",
   pattern=".|.|"..card:getSuitString(),prompt="#fire_attack-discard:"..to.id.."::"..card:getSuitString(),skip=true}
  for _,f in pairs(effect.extra_data.extra_effect or {})do
   if type(f)=="function"then params=f(room,effect,card,params)end
  end
  params.skip=true
  local ids=room:askToDiscard(from,params)
  if #ids==0 then return end
  local discarded=M.revealed.shown(from,ids[1])
  local extra=effect.extra_data.dream_pianxiang and shown~=discarded and 1 or 0
  room:throwCard(ids,"fire_attack_skill",from,from)
  if not to.dead then
   effect.extra_data.fire_attack_discard=ids
   room:damage{from=from,to=to,card=effect.card,damage=1+extra,damageType=fk.FireDamage,skillName="fire_attack_skill"}
  end
 end,
})
Fk:loadTranslationTable{["dream__fire_attack"]="火攻"}
return skill

local R=require "packages.meng_family.pkg.zhulv.revealed"
local skill=fk.CreateSkill{name="hqgod__liaofan"}
local function targets(room)
 return table.filter(room.alive_players,function(p)return not p:isKongcheng() and #R.cards(p,false)==0 end)
end
skill:addEffect(fk.TurnEnd,{
 audio_index={1,2},
 can_trigger=function(self,e,t,p,d)return p:hasSkill(skill.name) and #targets(p.room)>0 end,
 on_cost=function(self,e,t,p,d)return p.room:askToSkillInvoke(p,{skill_name=skill.name})end,
 on_use=function(self,e,t,p,d)
  local room=p.room;local tos=targets(room);room:sortByAction(tos)
  for _,who in ipairs(tos)do if not who.dead then local ids=who:getCardIds("h");if #ids>0 then room:throwCard(ids,skill.name,who,p)end end end
  for _,who in ipairs(tos)do if not who.dead then room:damage{from=p,to=who,damage=1,damageType=fk.FireDamage,skillName=skill.name}end end
 end,
})
Fk:loadTranslationTable{
 ["hqgod__liaofan"]="燎燔",
 [":hqgod__liaofan"]="每回合结束时，你可以弃置手牌均为明置牌的所有角色的所有手牌，并对这些角色各造成1点火焰伤害。",
}
return skill

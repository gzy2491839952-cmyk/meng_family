local skill=fk.CreateSkill{name="hqice__slash_skill"}
local slash=Fk.skills["slash_skill"]
skill:addEffect("cardskill",{
 target_num=1,max_phase_use_time=1,can_use=slash.canUse,
 mod_target_filter=slash.modTargetFilter,target_filter=slash.targetFilter,
 on_effect=function(self,room,e)
  if not e.to.dead then room:damage{from=e.from,to=e.to,card=e.card,damage=1,damageType=fk.IceDamage,skillName=skill.name}end
 end,
})
return skill

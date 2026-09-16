local skill=fk.CreateSkill{name="hqzhangyi_light_slash"}
local slash=Fk.skills["slash_skill"]
skill:addEffect("cardskill",{
 target_num=1,max_phase_use_time=1,can_use=slash.canUse,
 mod_target_filter=slash.modTargetFilter,target_filter=slash.targetFilter,
 on_effect=function(self,room,e)
  room:damage{from=e.from,to=e.to,card=e.card,damage=1,damageType="hanqing_light",skillName=skill.name}
 end,
})
Fk:loadTranslationTable{["hqzhangyi_light_slash"]="光杀"}
return skill

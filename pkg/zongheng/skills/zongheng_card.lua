local M=require "packages.meng_family.pkg.zongheng.alliance"
local skill=fk.CreateSkill{name="hq_zongheng_card"}
skill:addEffect("cardskill",{
 min_target_num=1,max_target_num=2,mod_target_filter=Util.TrueFunc,target_filter=Util.CardTargetFilter,
 on_effect=function(self,room,e)if not e.to.dead then M.cardEffect(e.to)end end,
})
Fk:loadTranslationTable{["hq_zongheng_card"]="纵横捭阖",["#hq_zongheng_card"]="选择至多两名角色，改变其合纵／连横状态"}
return skill

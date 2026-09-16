local M=require "packages.meng_family.pkg.zongheng.alliance"
local skill=fk.CreateSkill{name="hq_alliance_convert"}
skill:addEffect("viewas",{
 pattern="hq__zongheng",handly_pile=true,
 card_filter=function(self,p,id,selected)
  local c=Fk:getCardById(id)
  return #selected==0 and c.type==Card.TypeTrick and c.multiple_targets==true
 end,
 view_as=function(self,p,ids)
  if #ids~=1 then return end
  local c=Fk:cloneCard("hq__zongheng");c:addSubcard(ids[1]);c.skillName=skill.name;return c
 end,
 enabled_at_play=function(self,p)return M.own(p)end,
 enabled_at_response=function()return false end,
})
Fk:loadTranslationTable{
 ["hq_alliance_convert"]="纵横转化",[":hq_alliance_convert"]="你可以将一张多目标锦囊牌当【纵横捭阖】使用。<br/><b>合纵／连横：</b>两种独立状态，互不共存，均可与铁索连环同时存在。处于其中一种状态时，视为拥有其他同状态角色对应技能中“捭阖”之前的效果。重置武将牌，或对其他同状态角色造成伤害后，退出该状态。",
}
return skill

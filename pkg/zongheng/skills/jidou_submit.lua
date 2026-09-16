local M=require "packages.meng_family.pkg.zongheng.alliance"
local skill=fk.CreateSkill{name="hq_jidou_submit"}
skill:addEffect("active",{
 card_num=1,min_target_num=1,max_target_num=2,
 interaction=function(self,p)return UI.CardNameBox{choices=M.names()}end,
 card_filter=function(self,p,id,selected)
  return #selected==0 and table.contains(p:getCardIds("he"),id)
 end,
 target_filter=function(self,p,q,selected,ids)
  local name=self.interaction.data
  if not name or #ids~=1 then return false end
  local max=Fk:cloneCard(name).trueName=="slash" and 1 or 2
  return #selected<max and table.contains(M.targets(p,name,ids[1]),q)
 end,
 feasible=function(self,p,selected,ids)
  local name=self.interaction.data
  if not name or #ids~=1 then return false end
  local max=Fk:cloneCard(name).trueName=="slash" and 1 or 2
  return #selected>=1 and #selected<=max
 end,
})
Fk:loadTranslationTable{["hq_jidou_submit"]="犄斗选牌"}
return skill

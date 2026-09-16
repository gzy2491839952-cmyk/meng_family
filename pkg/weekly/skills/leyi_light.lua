local M=require "packages.meng_family.pkg.weekly.leyi"
local R=require "packages.meng_family.pkg.zhulv.revealed"
local skill=fk.CreateSkill{name="hqleyi_light_rule"}
skill:addEffect(fk.Damage,{
 global=true,
 can_trigger=function(self,e,t,p,d)return t==p and d.from==p and not p.dead and not d.to.dead and d.damageType==M.light and #d.to:getCardIds("h")>0 end,
 on_cost=function(self,e,t,p,d)return p.room:askToSkillInvoke(p,{skill_name=skill.name,prompt="#hqlight-invoke::"..d.to.id})end,
 on_use=function(self,e,t,p,d)
  local room=p.room;local to=d.to
  local hidden=table.filter(to:getCardIds("h"),function(id)return not M.shown(to,id)end)
  local shown=table.filter(to:getCardIds("h"),function(id)return M.shown(to,id) and not p:prohibitDiscard(id)end)
  local choices={};if #hidden>0 then table.insert(choices,"hqlight_show")end;if #shown>0 then table.insert(choices,"hqlight_discard")end
  if #choices==0 then return end
  local choice=room:askToChoice(p,{choices=choices,skill_name=skill.name})
  local pool=choice=="hqlight_show" and hidden or shown
  local visible={};for _,id in ipairs(pool)do visible[tostring(id)]=choice~="hqlight_show" or p:cardVisible(id)end
  local ids=room:askToPoxi(p,{poxi_type="AskForCardsChosen",data={{"$Hand",pool}},extra_data={to=to.id,min=1,max=math.min(2,#pool),skillName=skill.name,visible_data=visible},cancelable=true})
  if #ids==0 then return end
  if choice=="hqlight_show"then R.reveal(to,ids,skill.name)
  else room:throwCard(ids,skill.name,to,p)end
 end,
})
Fk:loadTranslationTable{
 ["hqleyi_light_rule"]="光属性伤害",["#hqlight-invoke"]="光伤害：是否明置 %dest 的至多两张暗牌，或弃置其至多两张明牌？",
 ["hqlight_show"]="明置至多两张暗置手牌",["hqlight_discard"]="弃置至多两张明置手牌",
}
return skill

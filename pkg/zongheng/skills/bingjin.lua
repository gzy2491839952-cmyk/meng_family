local A=require "packages.meng_family.pkg.zongheng.alliance"
local M=require "packages.meng_family.pkg.zongheng.gongsunyan"
local skill=fk.CreateSkill{name="hqgsy__bingjin"}
skill:addEffect(fk.TargetConfirmed,{
 audio_index={1,2,3},
 global=true,
 can_trigger=function(self,e,t,p,d)
  return not p.dead and A.effect(p,skill.name) and p:getMark(M.used)==0 and M.consecutive(p,d)
 end,
 on_cost=function(self,e,t,p,d)
  local choices={"hq_bingjin_draw","hq_bingjin_reset"}
  if #M.discardable(p,d.to)>0 then table.insert(choices,2,"hq_bingjin_discard")end
  if p:hasSkill(skill.name) and M.backwater(p)then choices[#choices+1]="hq_bingjin_backwater"end
  choices[#choices+1]="Cancel"
  local choice=p.room:askToChoice(p,{choices=choices,skill_name=skill.name,prompt="#hq-bingjin-choice:"..d.to.id})
  if choice~="Cancel" then e:setCostData(self,choice);return true end
 end,
 on_use=function(self,e,t,p,d)M.resolve(p,d,e:getCostData(self))end,
})
Fk:loadTranslationTable{
 ["hqgsy__bingjin"]="并进",
 [":hqgsy__bingjin"]="合纵技，每回合限一次，有角色连续成为牌的目标时，若其中包含来源为你的牌，则你可以选择一项：1.摸两张牌，然后横置；2.弃置其一张牌，然后重置；3.重置所有角色的“并进”，然后翻面。捭阖：你可以令此牌结算两次，并获得应变效果〈助战→否则失效〉。",
 ["hq_bingjin_draw"]="摸两张牌，然后横置自己",
 ["hq_bingjin_discard"]="弃置该角色一张牌，然后重置自己",
 ["hq_bingjin_reset"]="重置所有角色的并进次数，然后翻面自己",
 ["hq_bingjin_backwater"]="背水：此牌双结算并需自己助战，然后依次执行前三项",
 ["#hq-bingjin-choice"]="并进：%src 连续成为牌的目标，请选择一项",
 ["#hq-bingjin-discard"]="并进：弃置 %src 的一张牌",
 ["#hq-bingjin-bahe"]="并进·捭阖：是否令此牌结算两次，且助战失败则此牌无效？",
 ["#hq-bingjin-help"]="并进：可弃置一张同类别手牌助战 %src，否则该牌无效",
 ["#hq-bingjin-failed"]="%from 的【并进】未获助战，【%arg】无效",
 ["@hq_shared_bingjin"]="共享并进",
 [":@hq_shared_bingjin"]="合纵状态：视为拥有其他合纵角色【并进】中捭阖之前的效果，每回合限一次。",
}
return skill

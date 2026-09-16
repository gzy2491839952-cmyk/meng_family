local M=require "packages.meng_family.pkg.zongheng.gongsunyan"
local skill=fk.CreateSkill{name="hqgsy__guzhi"}
skill:addEffect(fk.DamageInflicted,{
 audio_index={1,2,3},
 can_trigger=function(self,e,t,p,d)
  return p:hasSkill(skill.name) and d.damage>0 and not d.prevented and d.from and not d.from.dead and M.same(p,d.to)
 end,
 on_cost=function(self,e,t,p,d)
  return p.room:askToSkillInvoke(d.from,{skill_name=skill.name,prompt="#hq-guzhi-replace:"..p.id..":"..d.to.id})
 end,
 on_use=function(self,e,t,p,d)
  d.prevented=true
  local card=Fk:cloneCard("hq__zongheng");card.skillName=skill.name
  -- A real CardEffectData is required: passing a plain table here crashes
  -- when the engine calls isNullified(). This is one effect, not a new use.
  p.room:doCardEffect(CardEffectData:new{from=d.from,to=d.to,tos={d.to},card=card,extra_data={hq_guzhi=true}})
 end,
})
Fk:loadTranslationTable{
 ["hqgsy__guzhi"]="孤鸷",
 [":hqgsy__guzhi"]="与你武将牌状态相同的角色受到伤害时，伤害来源可以改为对其结算一次【纵横捭阖】。若没有与你武将牌状态相同的其他角色，则你合纵技的“捭阖”改为“背水”，且仅你可以助战你。<br/>状态比较包括正面／背面、连环状态及合纵／连横状态。助战：弃置一张与该牌类别相同的手牌。",
 ["#hq-guzhi-replace"]="孤鸷（%src）：是否防止此次伤害，改为对 %dest 结算一次纵横捭阖？",
}
return skill

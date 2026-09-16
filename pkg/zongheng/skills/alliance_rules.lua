local M=require "packages.meng_family.pkg.zongheng.alliance"
local skill=fk.CreateSkill{name="hq_alliance_rules"}
skill:addEffect(fk.ChainStateChanged,{
 global=true,
 can_refresh=function(self,e,t,p,d)return t==p and not p.chained end,
 on_refresh=function(self,e,t,p,d)M.onReset(p)end,
})
skill:addEffect(fk.DetermineDamageInflicted,{
 global=true,late_refresh=true,
 can_refresh=function(self,e,t,p,d)return p==p.room.players[1] and d.from~=nil end,
 on_refresh=function(self,e,t,p,d)
  if d.from~=d.to and M.state(d.from)~=0 and M.state(d.from)==M.state(d.to)then
   d.extra_data=d.extra_data or {};d.extra_data.hq_alliance_betrayal={from=d.from.id,state=M.state(d.from)}
  end
 end,
})
skill:addEffect(fk.Damage,{
 global=true,
 can_refresh=function(self,e,t,p,d)
  local saved=d.extra_data and d.extra_data.hq_alliance_betrayal
  return t==p and saved and saved.from==p.id and M.state(p)==saved.state
 end,
 on_refresh=function(self,e,t,p,d)M.set(p,0)end,
})
for _,event in ipairs{fk.GameStart,fk.EventAcquireSkill,fk.EventLoseSkill,fk.Death}do
 skill:addEffect(event,{
  global=true,
  can_refresh=function(self,e,t,p,d)return p==p.room.players[1]end,
  on_refresh=function(self,e,t,p,d)M.sync(p.room)end,
 })
end
Fk:loadTranslationTable{["hq_alliance_rules"]="合纵连横规则"}
return skill

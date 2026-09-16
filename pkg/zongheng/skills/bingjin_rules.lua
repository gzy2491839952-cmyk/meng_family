local M=require "packages.meng_family.pkg.zongheng.gongsunyan"
local skill=fk.CreateSkill{name="hq_bingjin_rules"}
skill:addEffect(fk.AfterCardUseDeclared,{
 global=true,
 can_refresh=function(self,e,t,p,d)return p==p.room.players[1]end,
 on_refresh=function(self,e,t,p,d)M.record(p.room,d)end,
})
skill:addEffect(fk.TargetConfirmed,{
 global=true,
 can_refresh=function(self,e,t,p,d)return p==p.room.players[1] and d.use and d.use.extra_data and d.use.extra_data.hq_bingjin_record end,
 on_refresh=function(self,e,t,p,d)
  -- Capture targets after target-transfer and target-modification effects.
  d.use.extra_data.hq_bingjin_record.tos=table.map(d.use.tos,function(q)return q.id end)
 end,
})
skill:addEffect(fk.PreCardEffect,{
 global=true,
 can_refresh=function(self,e,t,p,d)
  return p==p.room.players[1] and d.use and d.use.extra_data and d.use.extra_data.hq_bingjin_failed
 end,
 on_refresh=function(self,e,t,p,d)d.nullified=true end,
})
Fk:loadTranslationTable{["hq_bingjin_rules"]="并进记录"}
return skill

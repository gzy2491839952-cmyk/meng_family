local M=require "packages.meng_family.pkg.weekly.leyi"
local skill=fk.CreateSkill{name="hqleyi__genxi",tags={Skill.Compulsory}}
skill:addEffect(fk.BeforeGameOverJudge,{
 global=true,
 can_refresh=function(self,e,t,p,d)return t==p and M.is(p)end,
 on_refresh=function(self,e,t,p,d)
  local room=p.room
  if p:hasSkill(skill.name,true) and #M.activeOthers(room,p)>0 then
   room:setPlayerMark(p,"hqleyi_preserve",1)
   room:setPlayerRest(p,1)
   p._splayer:setDied(false)
   d.extra_data=d.extra_data or {};d.extra_data.skip_reward_punish=true
  else
   -- No active body remains: resting bodies must not block the winner check.
   for _,other in ipairs(room.players)do
    if M.is(other) and other.dead and (other.rest or 0)>0 then
     room:setPlayerRest(other,0);room:setPlayerMark(other,"hqleyi_preserve",0)
     other._splayer:setDied(true);other:bury()
    end
   end
  end
 end,
})
skill:addEffect(fk.BuryVictim,{
 global=true,priority=100,
 can_trigger=function(self,e,t,p,d)return t==p and M.is(p) and p:getMark("hqleyi_preserve")>0 and p.rest>0 end,
 on_trigger=function(self,e,t,p,d)return true end,
})
skill:addEffect(fk.AfterPlayerRevived,{
 global=true,
 can_refresh=function(self,e,t,p,d)return t==p and M.is(p) and p:getMark("hqleyi_preserve")>0 end,
 on_refresh=function(self,e,t,p,d)
  p.room:setPlayerMark(p,"hqleyi_preserve",0)
  p.room:sortByAction(p.room.alive_players)
 end,
})
Fk:loadTranslationTable{
 ["hqleyi__genxi"]="亘曦",
 [":hqleyi__genxi"]="锁定技，你死亡时，若场上有其他不处于休整状态的“神乐毅”，你保留所有牌并改为休整一轮。",
}
return skill

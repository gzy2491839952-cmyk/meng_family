local M=require "packages.meng_family.pkg.weekly.leyi"
local skill=fk.CreateSkill{name="hqleyi__sancun",tags={Skill.Compulsory}}
skill:addEffect(fk.GamePrepared,{
 global=true,
 can_refresh=function(self,e,t,p,d)return M.is(p) and p:hasSkill(skill.name) and p:getMark("hqleyi_spawned")==0 end,
 on_refresh=function(self,e,t,p,d)M.spawn(p)end,
})
skill:addEffect(fk.DrawInitialCards,{
 can_refresh=function(self,e,t,p,d)return t==p and p:hasSkill(skill.name)end,
 on_refresh=function(self,e,t,p,d)d.num=4 end,
})
skill:addEffect("maxcards",{fixed_func=function(self,p)if p:hasSkill(skill.name)then return 4 end end})
skill:addEffect(fk.AfterPropertyChange,{
 global=true,
 can_refresh=function(self,e,t,p,d)
  return t==p and M.is(p) and p:getMark("hqleyi_owner")~=0 and d.results
   and (d.results.kingdomChange or d.results.roleChange)
 end,
 on_refresh=function(self,e,t,p,d)
  for _,body in ipairs(p.room.players)do
   if body~=p and body:getMark("hqleyi_owner")==p:getMark("hqleyi_owner")then
    if d.results.kingdomChange then p.room:setPlayerProperty(body,"kingdom",p.kingdom)end
    if d.results.roleChange then p.room:setPlayerProperty(body,"role",p.role)end
   end
  end
 end,
})
Fk:loadTranslationTable{
 ["hqleyi__sancun"]="三踆",
 [":hqleyi__sancun"]="锁定技，游戏开始时，你改为以三个体力上限为2，初始手牌数和手牌上限为4，座次连续的“神乐毅”登场。",
}
return skill

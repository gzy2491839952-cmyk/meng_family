local M=require "packages.meng_family.pkg.zhulv.tiandi"
local skill=fk.CreateSkill{name="dream__lingjue",tags={Skill.Lord}}
local function present(room)
 local ks={};for _,p in ipairs(room.alive_players)do if not p.dead then table.insertIfNeed(ks,p.kingdom)end end
 return ks
end
skill:addEffect(fk.GameStart,{
 global=true,
 can_refresh=function(self,event,target,p,data)return true end,
 on_refresh=function(self,event,target,p,data)
  p.room:setPlayerMark(p,"dream_lingjue_present",present(p.room))
 end,
})
local spec={
 can_trigger=function(self,event,target,p,data)
  if not p:hasSkill(skill.name)then return false end
  local now=present(p.room)
  return table.find(p:getTableMark("dream_lingjue_present"),function(k)return not table.contains(now,k)end)~=nil
 end,
 on_cost=function()return true end,
 on_use=function(self,event,target,p,data)
  local room=p.room;local now=present(room)
  local lost=table.filter(p:getTableMark("dream_lingjue_present"),function(k)return not table.contains(now,k)end)
  room:setPlayerMark(p,"dream_lingjue_present",now)
  for _,old in ipairs(lost)do
   if p.dead then break end
   local choices=table.filter(now,function(k)return not table.contains(M.factions(p),k)end)
   if #choices>0 then
    table.insert(choices,"Cancel")
    local c=room:askToChoice(p,{choices=choices,skill_name=skill.name,prompt="#dream__lingjue-absorb::"..old})
    if c~="Cancel"then local ks=M.factions(p);table.insertIfNeed(ks,c);room:setPlayerMark(p,"@dream_lingjue",ks)end
   end
  end
 end,
}
skill:addEffect(fk.Death,spec)
skill:addEffect(fk.AfterPropertyChange,spec)
-- Update the census only after the trigger has had a chance to compare it.
-- New factions are recorded without removing vanished entries prematurely.
for _,ev in ipairs{fk.Death,fk.AfterPropertyChange}do
 skill:addEffect(ev,{
  global=true,
  can_refresh=function()return true end,
  on_refresh=function(self,event,target,p,data)
   local ks=p:getTableMark("dream_lingjue_present")
   for _,k in ipairs(present(p.room))do table.insertIfNeed(ks,k)end
   p.room:setPlayerMark(p,"dream_lingjue_present",ks)
   if not p:hasSkill(skill.name)then p.room:setPlayerMark(p,"dream_lingjue_present",present(p.room))end
  end,
 })
end
Fk:loadTranslationTable{
 ["dream__lingjue"]="凌绝",
 [":dream__lingjue"]="主公技，其他〔齐〕势力角色展示的牌花色均视为黑桃；当场上失去一个势力时，你可以将另一个势力并入〔〕。",
 ["@dream_lingjue"]="凌绝势力",
 ["#dream__lingjue-absorb"]="凌绝：%dest 势力已消失，可选择另一个势力加入技能范围",
 ["#dream_lingjue_spade"]="凌绝：%from 展示的 %card 视为黑桃",
}
return skill

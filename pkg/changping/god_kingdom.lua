-- Restrict only Hanqing god generals; keep their displayed god faction.
local Room=require "ltk.server.room"
local M={choices={"meng_qin","meng_chu","meng_qi","meng_yan","meng_zhao","meng_wei","meng_han"}}
function M.applies(p)
 local g=Fk.generals[p.general]
 return g and g.kingdom=="god" and g.package and g.package.extensionName=="meng_family"
end
function M.install()
 if Room.hanqing_god_kingdom_installed then return end
 Room.hanqing_god_kingdom_installed=true
 local original=Room.askToChooseKingdom
 function Room:askToChooseKingdom(players)
  local others={}
  for _,p in ipairs(players or self.alive_players)do
   if M.applies(p) and p.kingdom=="god" then
    local choices=table.simpleClone(M.choices)
    local choice=self:askToChoice(p,{choices=choices,skill_name="AskForKingdom",prompt="#ChooseInitialKingdom"})
    if not table.contains(choices,choice)then choice=choices[1]end
    p.kingdom=choice
    self:notifyProperty(p,p,"kingdom")
   else table.insert(others,p)end
  end
  if #others>0 then return original(self,others)end
 end
end
return M

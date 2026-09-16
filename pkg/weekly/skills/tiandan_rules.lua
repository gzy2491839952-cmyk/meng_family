local M=require "packages.meng_family.pkg.weekly.tiandan"
local skill=fk.CreateSkill{name="hqtiandan_mountain_rule"}
skill:addEffect(fk.AfterCardsMove,{
 global=true,
 can_refresh=function(self,e,t,p,d)return p==p.room.players[1] and p.room:getBanner(M.active)end,
 on_refresh=function(self,e,t,p,d)M.watch(p.room);M.update(p.room)end,
})
skill:addEffect(fk.AfterDrawPileShuffle,{
 global=true,
 can_refresh=function(self,e,t,p,d)return p==p.room.players[1] and p.room:getBanner(M.active)end,
 on_refresh=function(self,e,t,p,d)
  p.room:setBanner(M.shuffle,(p.room:getBanner(M.shuffle)or 0)+1);M.update(p.room)
 end,
})
skill:addEffect("visibility",{
 global=true,
 card_visible=function(self,viewer,card)
  local room=Fk:currentRoom()
  if room:getBanner(M.active) and room:getBanner(M.top)==card.id and room:getCardArea(card.id)==Card.DrawPile then return true end
 end,
})
-- The scheduled repetitions survive losing the limited skill, but not death.
skill:addEffect(fk.TurnStart,{
 global=true,priority=20,
 can_refresh=function(self,e,t,p,d)return t==p and not p.dead and p:getMark("hqtd_repeats")>0 end,
 on_refresh=function(self,e,t,p,d)
  p.room:setPlayerMark(p,"hqtd_repeats",p:getMark("hqtd_repeats")-1);M.sacrifice(p)
  -- The third sacrifice replaces this turn as soon as all three areas are sealed.
  if p:getMark("@hqtd_ember")>0 then d.turn_end=true;M.erupt(p,"hqtiandan__cuipo")end
 end,
})
skill:addEffect(fk.PreTurnStart,{
 global=true,
 can_refresh=function(self,e,t,p,d)return t==p and not p.dead and p:getMark("@hqtd_ember")>0 end,
 on_refresh=function(self,e,t,p,d)d.turn_end=true;M.erupt(p,"hqtiandan__cuipo")end,
})
Fk:loadTranslationTable{["hqtiandan_mountain_rule"]="火焰山规则"}
return skill

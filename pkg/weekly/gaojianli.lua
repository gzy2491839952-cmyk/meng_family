-- Shared implementation for the original rhythm skill and its permanent revision.
local M={name="weekly__zhuangxing", revised="weekly__zhuangxing_revised",
 used="weekly_zhuangxing_used-turn", state="@weekly_zhuangxing_rhyme",
 aided="weekly_zhuangxing_aided", awakened="weekly_juezhu", pending="weekly_zhuangxing_wine-turn",
 damage="weekly_zhuangxing_damage-turn"}
function M.isRevised(p)return p:getMark(M.awakened)>0 end
function M.has(p)return p:hasSkill(M.name)or p:hasSkill(M.revised)end
function M.remember(room,p,to)
 if p==to then return end
 local ids=p:getTableMark(M.aided);table.insertIfNeed(ids,to.id);room:setPlayerMark(p,M.aided,ids)
end
function M.wine(room,p,to,name)
 if p.dead or to.dead then return end
 local ids=table.filter(p:getCardIds("he"),function(id)
  local c=Fk:cloneCard("analeptic");c:addSubcard(id);c.skillName=name
  return not p:prohibitUse(c) and not p:isProhibited(to,c)
 end)
 if #ids==0 then return end
 ids=room:askToCards(p,{min_num=1,max_num=1,include_equip=true,cancelable=true,
  pattern=tostring(Exppattern{id=ids}),skill_name=name,prompt="#weekly_zhuangxing-wine::"..to.id})
 if #ids~=1 or p.dead or to.dead then return end
 local c=Fk:cloneCard("analeptic");c:addSubcards(ids);c.skillName=name
 if p:prohibitUse(c)or p:isProhibited(to,c)then return end
 M.remember(room,p,to)
 local pending=p:getTableMark(M.pending);table.insert(pending,to.id);room:setPlayerMark(p,M.pending,pending)
 room:useCard{from=p,tos={to},card=c,extraUse=true,extra_data={weekly_zhuangxing_wine=true}}
end
function M.recast(room,p,to,name)
 if p.dead or to.dead then return end
 local maxp=math.min(3,#p:getCardIds("he"))
 local maxt=to==p and 0 or math.min(3,#to:getCardIds("he"))
 local choices,alloc={},{}
 for a=0,maxp do for b=0,math.min(maxt,3-a)do
  local label=string.format("你重铸%d张，对方重铸%d张",a,b)
  table.insert(choices,label);alloc[label]={a,b}
 end end
 local chosen=room:askToChoice(p,{choices=choices,skill_name=name,prompt="#weekly_zhuangxing-allocate::"..to.id})
 local n=alloc[chosen];if not n then return end
 local selected={}
 for i,who in ipairs({p,to})do
  selected[i]={}
  if n[i]>0 and not who.dead then
   selected[i]=room:askToCards(who,{min_num=n[i],max_num=n[i],include_equip=true,cancelable=false,
    skill_name=name,prompt="#weekly_zhuangxing-recast:::"..n[i]})
  end
 end
 M.remember(room,p,to)
 local suits,counts={},{}
 for i,who in ipairs({p,to})do
  local ids=not who.dead and table.filter(selected[i],function(id)
   return table.contains(who:getCardIds("he"),id)
  end)or{}
  counts[i]=#ids
  for _,id in ipairs(ids)do
   local suit=Fk:getCardById(id).suit
   if suit~=Card.NoSuit then table.insertIfNeed(suits,suit)end
  end
  if #ids>0 then room:recastCard(ids,who,name)end
 end
 if to.dead or #suits==0 then return end
 local ids=table.filter(to:getCardIds("he"),function(id)return table.contains(suits,Fk:getCardById(id).suit)end)
 if #ids==0 then return end
 local use=room:askToUseVirtualCard(to,{name="slash",skill_name=name,card_filter={cards=ids,n=1},
  prompt="#weekly_zhuangxing-stab:::"..(to==p and counts[1]or counts[2]),cancelable=true,skip=true,
  extra_data={bypass_times=true,extraUse=true}})
 if use then
  use.extra_data=use.extra_data or{}
  use.extra_data.weekly_zhuangxing_stab=true
  use.extra_data.weekly_zhuangxing_draw=to==p and counts[1]or counts[2]
  room:useCard(use)
 end
end
function M.build(revised)
 local name=revised and M.revised or M.name
 local skill=fk.CreateSkill{name=name,tags=revised and{}or{Skill.Rhyme}}
 skill:addEffect(fk.EventPhaseStart,{
  anim_type="support",audio_index=0,
  can_trigger=function(self,event,target,player,data)
   return player:hasSkill(name)and not player.dead and target~=player and not target.dead
    and target.phase==Player.Start and player:getMark(M.used)==0
  end,
  on_use=function(self,event,target,player,data)
   local room=player.room
   local voice=revised and {1,2} or (player:getSwitchSkillState(name)==fk.SwitchYang and {1,2} or {3,4})
   player:broadcastSkillInvoke(name,room:tableRandomPick(voice))
   -- Set before any card movement: a black card lost as cost may reset this very use.
   room:setPlayerMark(player,M.used,1)
   local to=revised and player or target
   if not revised then
    if player:getSwitchSkillState(name)==fk.SwitchYang then M.wine(room,player,to,name)
    else M.recast(room,player,to,name)end
   else
    local choices={"weekly_zhuangxing_wine","weekly_zhuangxing_recast"}
    if table.find(player:getCardIds("he"),function(id)
     return Fk:getCardById(id).color==Card.Black and not player:prohibitDiscard(id)
    end)then table.insert(choices,"weekly_zhuangxing_both")end
    local choice=room:askToChoice(player,{choices=choices,skill_name=name,prompt="#weekly_zhuangxing-revised"})
    if choice=="weekly_zhuangxing_both"then
     local ids=room:askToDiscard(player,{min_num=1,max_num=1,include_equip=true,pattern=".|.|spade,club",
      skill_name=name,cancelable=true,prompt="#weekly_zhuangxing-backwater"})
     if #ids==0 then return end
    end
    if choice~="weekly_zhuangxing_recast"then M.wine(room,player,to,name)end
    if choice~="weekly_zhuangxing_wine"and not player.dead then M.recast(room,player,to,name)end
   end
  end,
 })
 return skill
end
return M

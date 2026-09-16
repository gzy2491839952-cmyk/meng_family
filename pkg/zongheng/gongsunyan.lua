local A=require "packages.meng_family.pkg.zongheng.alliance"
local M={used="hq_bingjin_used-turn"}
function M.same(a,b)
 return a.faceup==b.faceup and a.chained==b.chained and A.state(a)==A.state(b)
end
function M.alone(p)
 return not table.find((p.room or Fk:currentRoom()).alive_players,function(q)return q~=p and M.same(p,q)end)
end
function M.backwater(p)return p:hasSkill("hqgsy__guzhi") and M.alone(p)end
function M.record(room,use)
 use.extra_data=use.extra_data or {}
 use.extra_data.hq_bingjin_previous=room:getTag("hq_bingjin_last")
 local current={from=use.from.id,tos=table.map(use.tos,function(q)return q.id end)}
 use.extra_data.hq_bingjin_record=current
 room:setTag("hq_bingjin_last",current)
end
function M.consecutive(p,aim)
 local use=aim.use
 local prev=use and use.extra_data and use.extra_data.hq_bingjin_previous
 return prev and table.contains(prev.tos,aim.to.id) and (prev.from==p.id or use.from==p)
end
function M.discardable(p,q)
 return table.filter(q:getCardIds("hej"),function(id)return not p:prohibitDiscard(id)end)
end
-- Exact ID selection with explicit visibility: do not pass an ID-pattern to
-- AskForCardsChosen, which disables all face-down cards in this engine version.
Fk:addPoxiMethod{
 name="hq_bingjin_discard",
 card_filter=function(id,selected,data,e)return #selected==0 and table.contains(e.ids,id)end,
 feasible=function(selected,data,e)return #selected==1 and table.contains(e.ids,selected[1])end,
 prompt=function(data,e)return "#hq-bingjin-discard:"..e.to end,
 default_choice=function(data,e)return #e.ids>0 and {RoomInstance:tableRandomPick(e.ids)}or {}end,
}
function M.discard(p,q)
 local room=p.room;local ids=M.discardable(p,q)
 if p.dead or q.dead or #ids==0 then return end
 local visible={};local rows={}
 for _,zone in ipairs{{"h","$Hand"},{"e","$Equip"},{"j","$Judge"}}do
  local part=table.filter(q:getCardIds(zone[1]),function(id)return table.contains(ids,id)end)
  if #part>0 then rows[#rows+1]={zone[2],part}end
  for _,id in ipairs(part)do visible[tostring(id)]=p:cardVisible(id)end
 end
 local ret=room:askToPoxi(p,{poxi_type="hq_bingjin_discard",data=rows,cancelable=false,
  extra_data={to=q.id,ids=ids,visible_data=visible,skillName="hqgsy__bingjin"}})
 local legal=table.filter(M.discardable(p,q),function(id)return table.contains(ids,id)end)
 if #legal==0 or p.dead or q.dead then return end
 local id=ret and ret[1]
 if not table.contains(legal,id)then id=room:tableRandomPick(legal)end
 room:throwCard({id},"hqgsy__bingjin",q,p)
end
function M.option(p,q,choice)
 local room=p.room
 if p.dead then return end
 if choice=="hq_bingjin_draw" then
  p:drawCards(2,"hqgsy__bingjin")
  if not p.dead and not p.chained then p:setChainState(true)end
 elseif choice=="hq_bingjin_discard" then
  M.discard(p,q)
  if not p.dead then p:reset()end
 elseif choice=="hq_bingjin_reset" then
  for _,who in ipairs(room.players)do
   room:setPlayerMark(who,M.used,0)
   who:setSkillUseHistory("hqgsy__bingjin",0,Player.HistoryTurn)
  end
  if not p.dead then p:turnOver()end
 end
end
function M.helpCards(q,card)
 return table.filter(q:getCardIds("h"),function(id)
  return Fk:getCardById(id).type==card.type and not q:prohibitDiscard(id)
 end)
end
function M.enhance(p,use,selfOnly)
 local room=p.room
 use.extra_data=use.extra_data or {}
 local enhanced=use.extra_data.hq_bingjin_enhanced
 if not enhanced then use.additionalEffect=(use.additionalEffect or 0)+1;use.extra_data.hq_bingjin_enhanced=true end
 local helpers=selfOnly and {p}or table.filter(room.alive_players,function(q)return q~=p end)
 room:sortByAction(helpers)
 local helped=false
 for _,q in ipairs(helpers)do
  local ids=M.helpCards(q,use.card)
  if not q.dead and #ids>0 then
   local ret=room:askToDiscard(q,{min_num=1,max_num=1,include_equip=false,cancelable=true,
    skill_name="hqgsy__bingjin",pattern=tostring(Exppattern{id=ids}),prompt="#hq-bingjin-help:"..p.id})
   if #ret>0 then helped=true;break end
  end
 end
 if not helped then
  use.extra_data.hq_bingjin_failed=true
  use.nullifiedTargets=use.nullifiedTargets or {}
  for _,q in ipairs(room.players)do table.insertIfNeed(use.nullifiedTargets,q)end
  room:sendLog{type="#hq-bingjin-failed",from=p.id,arg=use.card.name}
 end
 return helped
end
function M.resolve(p,aim,choice)
 local room=p.room
 room:setPlayerMark(p,M.used,1)
 if choice=="hq_bingjin_backwater" then
  -- Snapshot the solo restriction before the three options change our state.
  M.enhance(p,aim.use,true)
  for _,option in ipairs{"hq_bingjin_draw","hq_bingjin_discard","hq_bingjin_reset"}do M.option(p,aim.to,option)end
 else
  local mayBahe=p:hasSkill("hqgsy__bingjin") and not M.backwater(p)
  M.option(p,aim.to,choice)
  if not p.dead and mayBahe and room:askToSkillInvoke(p,{skill_name="hqgsy__bingjin",prompt="#hq-bingjin-bahe"})then
   M.enhance(p,aim.use,M.backwater(p))
  end
 end
end
return M

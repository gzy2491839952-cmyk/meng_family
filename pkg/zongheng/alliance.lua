local M={mark="@hq_alliance",registry={}}
-- Each future alliance skill registers only its pre-捭阖 effect here.
M.registry["hqzhangyi__erxi"]={mode="hq_lianheng"}
M.registry["hqgsy__bingjin"]={mode="hq_hezong"}
function M.state(p)return p:getMark(M.mark)end
function M.own(p)
 for name in pairs(M.registry)do if p:hasSkill(name)then return true end end
 return false
end
function M.effect(p,name)
 if p:hasSkill(name)then return true end
 local entry=M.registry[name]
 if not entry or M.state(p)~=entry.mode then return false end
 -- Honour the shared non-compulsory-skill invalidation used by 霜骸.
 if not Fk.skills[name]:isEffectable(p)then return false end
 local room=p.room or Fk:currentRoom()
 return table.find(room.alive_players,function(q)
  return q~=p and M.state(q)==entry.mode and q:hasSkill(name)
 end)~=nil
end
function M.sync(room)
 for _,p in ipairs(room.players)do
  room:setPlayerMark(p,"@hq_shared_bingjin",not p.dead and not p:hasSkill("hqgsy__bingjin") and M.effect(p,"hqgsy__bingjin") and 1 or 0)
  room:setPlayerMark(p,"@hq_shared_erxi",not p.dead and not p:hasSkill("hqzhangyi__erxi") and M.effect(p,"hqzhangyi__erxi") and 1 or 0)
 end
end
function M.set(p,state)
 p.room:setPlayerMark(p,M.mark,state);M.sync(p.room)
end
function M.onReset(p)
 local room=p.room
 if M.state(p)~=0 then M.set(p,0)end
 if p.dead then return end
 local event=room.logic:getCurrentEvent()
 local use=event and event:findParent(GameEvent.UseCard,true)
 local data=use and use.data
 local ctx=room:getTag("hq_jidou_context")
 if ctx and not ctx.winner and data and data.extra_data and data.extra_data.hq_jidou==ctx.token then
  ctx.winner=data.from
  local ids=table.filter(ctx.ids,function(id)return room:getCardArea(id)==Card.Processing end)
  if not data.from.dead and #ids>0 then
   room:sendLog{type="#hq-jidou-prize",from=data.from.id}
   room:obtainCard(data.from,ids,true,fk.ReasonPrey,data.from,"hqzhangyi__jidou")
  end
 end
end
function M.cardEffect(p)
 local state=M.state(p)
 -- Check the exclusive diplomatic state first, even while still chained.
 if state=="hq_lianheng" then p:reset()
 elseif state=="hq_hezong" or p.chained then M.set(p,"hq_lianheng")
 else M.set(p,"hq_hezong")end
end
function M.install()
 local ServerPlayer=require "ltk.server.serverplayer"
 if ServerPlayer.hq_alliance_reset then return end
 ServerPlayer.hq_alliance_reset=true
 local original=ServerPlayer.reset
 function ServerPlayer:reset()
  local had=M.state(self)~=0 or self.chained or not self.faceup
  original(self)
  if had then M.onReset(self)end
 end
end
function M.names()
 local names={"iron_chain","hq__zongheng"}
 local slashes={}
 local disabled=(Fk:currentRoom().disabled_packs or {})
 for name,c in pairs(Fk.all_card_types)do
  if c.trueName=="slash" and not table.contains(disabled,c.package.name)then slashes[#slashes+1]=name end
 end
 table.sort(slashes)
 for _,name in ipairs(slashes)do names[#names+1]=name end
 return names
end
function M.card(name,id,fake)
 local orig=Fk:getCardById(id)
 local c=Fk:cloneCard(name,orig.suit,orig.number)
 if fake then c:addFakeSubcard(id)else c:addSubcard(id)end
 c.skillName="hqzhangyi__jidou";return c
end
function M.targets(p,name,id)
 return M.card(name,id):getAvailableTargets(p,{bypass_times=true,extraUse=true})
end
function M.options(p)
 local plans={}
 for _,id in ipairs(p:getCardIds("he"))do
  for _,name in ipairs(M.names())do
   local tos=M.targets(p,name,id)
   if #tos>0 then plans[#plans+1]={id=id,name=name,tos={tos[1]}}end
  end
 end
 return plans
end
function M.plan(p,reply)
 local ids=type(reply)=="table" and reply.card and reply.card.subcards
 local id=ids and #ids==1 and ids[1]
 local name=type(reply)=="table" and reply.interaction_data
 if not id or not table.contains(p:getCardIds("he"),id) or not table.contains(M.names(),name)then return end
 local available=M.targets(p,name,id);local tos={};local room=p.room
 for _,pid in ipairs(reply.targets or {})do
  local q=room:getPlayerById(pid)
  if not q or not table.contains(available,q)or table.contains(tos,q)then return end
  tos[#tos+1]=q
 end
 local max=Fk:cloneCard(name).trueName=="slash" and 1 or 2
 if #tos<1 or #tos>max then return end
 return {id=id,name=name,tos=tos}
end
function M.jidou(p,participants)
 local room=p.room;local request=Request:new(participants,"AskForUseActiveSkill")
 for _,q in ipairs(participants)do
  local plan=M.options(q)[1]
  request:setData(q,{"hq_jidou_submit","#hq-jidou-submit",false,{skillName="hqzhangyi__jidou"}})
  if plan then request:setDefaultReply(q,{card={subcards={plan.id}},interaction_data=plan.name,targets={plan.tos[1].id}})end
 end
 request.focus_text="hqzhangyi__jidou"
 local plans={};local moves={};local all={}
 -- One Request starts all prompts together. No card moves or uses until all replies arrive.
 for _,q in ipairs(participants)do
  local plan=M.plan(q,request:getResult(q)) or M.options(q)[1]
  if plan and not q.dead then
   plan.from=q;plans[#plans+1]=plan;all[#all+1]=plan.id
   moves[#moves+1]={ids={plan.id},from=q,toArea=Card.Processing,moveReason=fk.ReasonUse,
    skillName="hqzhangyi__jidou",moveVisible=true}
  end
 end
 if #plans==0 then return end
 local previous=room:getTag("hq_jidou_context")
 local ctx={ids=all,token=room.logic:getCurrentEvent().id}
 local finished=false
 local function cleanup()
  if finished then return end;finished=true
  room:cleanProcessingArea(all,"hqzhangyi__jidou")
  room:setTag("hq_jidou_context",previous)
 end
 room.logic:getCurrentEvent():addCleaner(cleanup)
 room:moveCards(table.unpack(moves))
 room:setTag("hq_jidou_context",ctx)
 local order={}
 while #plans>0 do
  local chosen=plans[1].from
  if #plans>1 and not p.dead then
   chosen=room:askToChoosePlayers(p,{targets=table.map(plans,function(x)return x.from end),min_num=1,max_num=1,
    cancelable=false,skill_name="hqzhangyi__jidou",prompt="#hq-jidou-order"})[1] or chosen
  end
  for i,plan in ipairs(plans)do if plan.from==chosen then order[#order+1]=plan;table.remove(plans,i);break end end
 end
 for _,plan in ipairs(order)do
  if not plan.from.dead then
   local tos=table.filter(plan.tos,function(q)return not q.dead end)
   if #tos>0 then
    -- The submitted material is already paid and reserved as a 底牌. Fake
    -- subcards keep the declared suit/number without spending that card again.
    room:useCard{from=plan.from,tos=tos,card=M.card(plan.name,plan.id,true),extraUse=true,
     extra_data={hq_jidou=ctx.token}}
   end
  end
 end
 cleanup()
end
return M

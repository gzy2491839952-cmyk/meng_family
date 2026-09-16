-- Shared Fire Mountain state belongs to the deck, not an individual skill owner.
local M={active="hqtd_mountain",top="hqtd_top",boost="hqtd_boost",shuffle="hqtd_shuffle"}
-- ID membership is independent of visibility. The standard patterned picker
-- rejects every face-down card, even when the pattern is only an ID whitelist.
Fk:addPoxiMethod{
 name="hqtd_discard_one",
 card_filter=function(id,selected,data,extra)
  return #selected==0 and table.contains(extra.allowed_ids,id)
 end,
 feasible=function(selected,data,extra)
  return #selected==1 and table.contains(extra.allowed_ids,selected[1])
 end,
 prompt=function(data,extra)return extra.prompt end,
 default_choice=function(data,extra)
  if #extra.allowed_ids==0 then return {} end
  return {RoomInstance:tableRandomPick(extra.allowed_ids)}
 end,
}
function M.discardOne(room,p,q,skill)
 local allowed=table.filter(q:getCardIds("hej"),function(id)return not p:prohibitDiscard(Fk:getCardById(id))end)
 if #allowed==0 or q.dead or p.dead then return end
 local rows={};local visibility={}
 for _,area in ipairs{{"h","$Hand"},{"e","$Equip"},{"j","$Judge"}}do
  local ids=table.filter(q:getCardIds(area[1]),function(id)return table.contains(allowed,id)end)
  if #ids>0 then rows[#rows+1]={area[2],ids}end
  for _,id in ipairs(ids)do visibility[tostring(id)]=p:cardVisible(id)end
 end
 local result=room:askToPoxi(p,{poxi_type="hqtd_discard_one",data=rows,cancelable=false,
  extra_data={to=q.id,skillName=skill,allowed_ids=allowed,visible_data=visibility,
   prompt="#AskForChooseCard:"..q.id.."::"..skill}})
 -- Recheck ownership/eligibility before moving; timeout falls back only to
 -- eligible cards, never to the target's unfiltered concealed hand.
 local current=table.filter(q:getCardIds("hej"),function(id)
  return table.contains(allowed,id) and not p:prohibitDiscard(Fk:getCardById(id))
 end)
 if p.dead or q.dead or #current==0 then return end
 local id=result and result[1]
 if not table.contains(current,id)then id=room:tableRandomPick(current)end
 room:throwCard({id},skill,q,p)
end
function M.fire(c)
 return c.name=="fire__slash" or c.trueName=="fire_attack" or c.damage_type==fk.FireDamage
end
function M.update(room)
 if not room:getBanner(M.active) then return end
 local id=room.draw_pile[1]
 room:setBanner(M.top,id or 0)
 room:setBanner("@hqtd_mountain",id and Fk:getCardById(id):toLogString() or "hqtd_empty")
end
function M.watch(room)
 if room.hqtd_watching then return end
 room.hqtd_watching=true
 local sync=room.syncDrawPile
 room.syncDrawPile=function(r,...)local result=sync(r,...);M.update(r);return result end
end
function M.choose(room,p,ids,skill,prompt)
 if #ids==0 then return end
 return room:askToChooseCard(p,{target=p,flag={card_data={{"hqtd_cards",ids}}},skill_name=skill,prompt=prompt})
end
function M.processing(room,ids)
 return table.filter(ids,function(id)return room:getCardArea(id)==Card.Processing end)
end
function M.tryUse(room,p,ids,skill,prompt)
 local available=table.filter(ids,function(id)
  return #Fk:getCardById(id):getAvailableTargets(p,{bypass_times=true,extraUse=true})>0
 end)
 if #available==0 then return false end
 local use=room:askToUseRealCard(p,{pattern=available,expand_pile=available,skill_name=skill,
  prompt=prompt,cancelable=true,skip=true,extra_data={bypass_times=true,extraUse=true}})
 if use then room:useCard(use);return true end
 return false
end
function M.erupt(p,skill,equipmentUser)
 local room=p.room;local ids={};local black=0;local fire=false
 local serial=room:getBanner(M.shuffle) or 0
 local n=2+(room:getBanner(M.boost) or 0)
 -- Clean only cards still in Processing, including on interrupted resolution.
 local cleaned=false
 local function cleanup()
  if cleaned then return end;cleaned=true
  room:cleanProcessingArea(M.processing(room,ids),skill)
 end
 room.logic:getCurrentEvent():addCleaner(cleanup)
 repeat
  -- Reveal the remaining top cards first; a refill ends this eruption.
  local batch={}
  for i=1,math.min(n,#room.draw_pile)do batch[#batch+1]=room.draw_pile[i] end
  for _,id in ipairs(batch)do
   ids[#ids+1]=id;local c=Fk:getCardById(id)
   if c.color==Card.Black then black=black+1 end
   if M.fire(c) then fire=true end
  end
  if #batch>0 then room:turnOverCardsFromDrawPile(p,batch,skill,true) end
  if p.dead or (room:getBanner(M.shuffle) or 0)~=serial then break end
  if #batch<n or #room.draw_pile==0 then room:shuffleDrawPile();break end
  local top=Fk:getCardById(room.draw_pile[1])
  if top.color~=Card.Red then break end
 until false
 M.update(room)
 if not p.dead and black>0 then
  local tos=table.filter(room.alive_players,function(q)
   return table.find(q:getCardIds("hej"),function(id)return not p:prohibitDiscard(Fk:getCardById(id))end)~=nil
  end)
  if #tos>0 then
   tos=room:askToChoosePlayers(p,{targets=tos,min_num=1,max_num=math.min(black,#tos),cancelable=true,
    skill_name=skill,prompt="#hqtd-discard:::"..black})
   room:sortByAction(tos)
   for _,q in ipairs(tos)do
    if p.dead then break end
    M.discardOne(room,p,q,skill)
   end
  end
 end
 local red=table.filter(M.processing(room,ids),function(id)return Fk:getCardById(id).color==Card.Red end)
 if not p.dead and #red>0 then
  local choice=room:askToChoice(p,{choices={"hqtd_use","hqtd_obtain"},skill_name=skill,prompt="#hqtd-red"})
  if choice~="hqtd_use" or not M.tryUse(room,p,red,skill,"#hqtd-use-red")then
   red=table.filter(M.processing(room,ids),function(id)return Fk:getCardById(id).color==Card.Red end)
   if not p.dead and #red>0 then
    local id=M.choose(room,p,red,skill,"#hqtd-obtain-red")
    if id then room:obtainCard(p,id,true,fk.ReasonJustMove,p,skill)end
   end
  end
 end
 if not p.dead and fire then
  local q=room:askToChoosePlayers(p,{targets=room.alive_players,min_num=1,max_num=1,cancelable=false,
   skill_name=skill,prompt="#hqtd-fire"})[1]
  if q then room:damage{from=p,to=q,damage=1,damageType=fk.FireDamage,skillName=skill}end
 end
 -- Keep unclaimed equipment available until the recast owner's optional use.
 if equipmentUser and not equipmentUser.dead then
  local equip=table.filter(M.processing(room,ids),function(id)return Fk:getCardById(id).type==Card.TypeEquip end)
  if #equip>0 then M.tryUse(room,equipmentUser,equip,skill,"#hqtd-use-equip")end
 end
 cleanup()
 return ids
end
function M.areas(p)
 local choices={}
 if not p:isHandAreaSealed()then choices[#choices+1]="hqtd_hand"end
 if #p:getAvailableEquipSlots()>0 then choices[#choices+1]="hqtd_equip"end
 if not p:isJudgeAreaSealed()then choices[#choices+1]="hqtd_judge"end
 return choices
end
function M.sacrifice(p)
 local room=p.room;local choices=M.areas(p)
 if #choices==0 then return end
 local choice=room:askToChoice(p,{choices=choices,skill_name="hqtiandan__cuipo",prompt="#hqtd-seal"})
 local slots=choice=="hqtd_hand" and {Player.HandSlot} or (choice=="hqtd_judge" and {Player.JudgeSlot} or p:getAvailableEquipSlots())
 room:abortPlayerArea(p,slots)
 if p.dead then return end
 local ids=table.filter(room.discard_pile,function(id)return M.fire(Fk:getCardById(id))end)
 if #ids>0 then
  local id=M.choose(room,p,ids,"hqtiandan__cuipo","#hqtd-obtain-fire")
  if id then room:obtainCard(p,id,true,fk.ReasonJustMove,p,"hqtiandan__cuipo")end
 end
 room:setBanner(M.boost,(room:getBanner(M.boost) or 0)+1)
 room:setBanner("@hqtd_batch",2+room:getBanner(M.boost))
 if #M.areas(p)==0 then room:setPlayerMark(p,"@hqtd_ember",1)end
end
return M

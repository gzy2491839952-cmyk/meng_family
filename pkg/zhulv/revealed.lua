local M={mark="@zhulv_revealed"}
function M.shown(player,id)
 return table.contains(player:getCardIds("h"),id) and Fk:getCardById(id):getMark(M.mark)==player.id
end
function M.cards(player,shown)
 return table.filter(player:getCardIds("h"),function(id)return M.shown(player,id)==shown end)
end
function M.reveal(player,ids,skill)
 local kept=table.filter(ids,function(id)return table.contains(player:getCardIds("h"),id)end)
 for _,id in ipairs(kept)do player.room:setCardMark(Fk:getCardById(id),M.mark,player.id)end
 if #kept>0 then player:showCards(kept)end
end
function M.materials(player)
 local room=player.room or Fk:currentRoom();local ids={}
 for _,owner in ipairs(room.alive_players)do
  if owner~=player and owner:hasSkill("zhulv__choufeng")then
   for _,id in ipairs(M.cards(owner,true))do
    if Fk:getCardById(id).type==Card.TypeBasic then table.insert(ids,id)end
   end
  end
 end
 return ids
end
function M.sameColor(player,color)
 if color==Card.NoColor then return {}end
 return table.filter(M.cards(player,false),function(id)return Fk:getCardById(id).color==color end)
end
-- Match the engine's discard-phase accounting: excluded cards do not
-- occupy the hand limit. getMaxCards() alone does not include exclusions.
function M.refillCount(player)
 local room=player.room or Fk:currentRoom()
 local counted=0
 for _,id in ipairs(player:getCardIds("h"))do
  local card=Fk:getCardById(id)
  local excluded=false
  for _,status in ipairs(room.status_skills[MaxCardsSkill] or {})do
   if status:excludeFrom(player,card)then excluded=true;break end
  end
  if not excluded then counted=counted+1 end
 end
 return math.max(0,player:getMaxCards()-counted)
end
function M.adjust(player)
 local room=player.room;local name="zhulv__qianche"
 local desired=math.max(player.hp,0)
 local shown=M.cards(player,true)
 if #shown<desired then
  local hidden=M.cards(player,false);local n=math.min(desired-#shown,#hidden)
  if n>0 then
   local ids=room:askToCards(player,{min_num=n,max_num=n,include_equip=false,skill_name=name,
    pattern=tostring(Exppattern{id=hidden}),cancelable=false,prompt="#zhulv__qianche-show"})
   M.reveal(player,ids,name)
  end
 elseif #shown>desired then
  local ids=table.filter(shown,function(id)return not player:prohibitDiscard(id)end)
  local n=math.min(#shown-desired,#ids)
  if n>0 then room:askToDiscard(player,{min_num=n,max_num=n,include_equip=false,
   pattern=tostring(Exppattern{id=ids}),skill_name=name,cancelable=false,prompt="#zhulv__qianche-discard"})end
 end
 if not player.dead and #M.cards(player,false)==0 then
  local n=M.refillCount(player)
  if n>0 then player:drawCards(n,name)end
 end
end
return M

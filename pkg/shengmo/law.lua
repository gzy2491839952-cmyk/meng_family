local U = {book="shengmo__shangjunshu", lock="-shengmo_law", owner="shengmo_law_origin", left="shengmo_law_left"}
function U.token(room, player)
  return room:prepareDeriveCards({{U.book,Card.NoSuit,0}}, "shengmo_shangjunshu_"..player.id)[1]
end
function U.holderBook(player)
  for _,id in ipairs(player:getCardIds("h")) do
    if Fk:getCardById(id,true).name==U.book then return id end
  end
end
function U.sides(player, book)
  local left,right={},{}; local passed=false
  for _,id in ipairs(player:getCardIds("h")) do
    if id==book then passed=true
    elseif passed then table.insert(right,id)
    else table.insert(left,id) end
  end
  return left,right
end
function U.sync(player, order)
  local room=player.room
  player.player_cards[Player.Hand]=table.simpleClone(order)
  -- Native order notification has no handler in some clients. The package
  -- callback below performs only UI/model reordering, never a game card move.
  room:doBroadcastNotify("HanqingLawHandOrder", {player.id,order})
end
function U.place(room, player, id)
  local cards=player:getCardIds("h")
  -- Fisher-Yates uses the room RNG, so recorded games remain reproducible.
  for i=#cards,2,-1 do local j=room:random(1,i);cards[i],cards[j]=cards[j],cards[i] end
  local middle=math.floor(#cards/2)+1
  room:setCardMark(Fk:getCardById(id,true),U.owner,player.id)
  room:setPlayerMark(player,MarkEnum.SortProhibited..U.lock,1)
  room:moveCards{ids={id},to=player,toArea=Card.PlayerHand,moveReason=fk.ReasonJustMove,
    skillName="shengmo__dingfa",moveVisible=true}
  if room:getCardOwner(id)~=player or room:getCardArea(id)~=Card.PlayerHand then return end
  -- Keep cards obtained by nested effects on the right; remove cards already lost.
  local current=player:getCardIds("h");local order={}
  for _,cid in ipairs(cards) do if table.contains(current,cid) then table.insert(order,cid) end end
  table.insert(order,math.min(middle,#order+1),id)
  for _,cid in ipairs(current) do if not table.contains(order,cid) then table.insert(order,cid) end end
  U.sync(player,order)
end
function U.snapshot(player, card)
  local book=U.holderBook(player);if not book then return end
  local left,right=U.sides(player,book)
  local ids=Card:getIdList(card);if #ids==0 then return end
  local side
  for _,id in ipairs(ids) do
    local s=table.contains(left,id) and "left" or (table.contains(right,id) and "right" or nil)
    if not s or (side and side~=s) then return end
    side=s
  end
  if #left==#right then return end
  local more=#left>#right and "left" or "right"
  return {book=book,mode=side==more and "cancel" or "repeat",more=more,
    less=more=="left" and "right" or "left", more_ids=more=="left" and left or right}
end
function U.apply(player, data, record)
  local room=player.room
  if record.mode=="cancel" then
    data.extra_data.shengmo_law_nullified=true
    data.nullifiedTargets=table.simpleClone(room.players)
    local ids=room:getNCards(2)
    if #ids>0 then
      if record.less=="left" then
        for _,id in ipairs(ids) do room:setCardMark(Fk:getCardById(id,true),U.left,player.id) end
      end
      room:moveCards{ids=ids,to=player,toArea=Card.PlayerHand,moveReason=fk.ReasonJustMove,skillName="shengmo__dingfa"}
    end
  else
    data.additionalEffect=(data.additionalEffect or 0)+1
    local left,right=U.sides(player,record.book)
    local ids=record.more=="left" and left or right
    if U.holderBook(player)~=record.book then
      local hand=player:getCardIds("h")
      ids=table.filter(record.more_ids,function(id)return table.contains(hand,id) end)
    end
    if #ids>0 then
      room:askToDiscard(player,{min_num=1,max_num=1,include_equip=false,cancelable=false,
        pattern=tostring(Exppattern{ id=ids }),skill_name="shengmo__dingfa",prompt="#shengmo-law-discard"})
    end
  end
end
return U

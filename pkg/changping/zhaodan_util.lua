local U={token="changping__zhaoshuaifu"}
function U.tokenId(room)
 return room:prepareDeriveCards({{U.token,Card.Spade,8}},"changping_zhaoshuaifu_unique")[1]
end
function U.onBoard(room)
 for _,p in ipairs(room.alive_players)do
  for _,id in ipairs(p:getCardIds("ej"))do
   local c=p:getVirtualEquip(id) or Fk:getCardById(id)
   if c.name==U.token then return p,id end
  end
 end
end
function U.isZhao(p)return p.kingdom=="meng_zhao" or p.kingdom=="zhao" end
function U.xiaochengEligible(from,to)
 return to~=from and not to.dead and to:hasSkill("changping__xiaocheng")
   and (U.isZhao(from) or #to:getCardIds("e")>0)
end
return U

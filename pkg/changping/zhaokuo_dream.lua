local M={pile="dream_pishi"}
function M.hasName(p,name)
 local trueName=Fk:cloneCard(name).trueName
 return table.find(p:getPile(M.pile),function(id)return Fk:getCardById(id,true).trueName==trueName end)~=nil
end
function M.collectible(room,card)
 local ids=Card:getIdList(card)
 if #ids~=1 then return end
 local id=ids[1];local real=Fk:getCardById(id,true)
 if real.trueName==card.trueName and room:getCardArea(id)==Card.Processing then return id end
end
function M.damageNames()
 return table.filter(Fk:getAllCardNames("btd"),function(n)return Fk:cloneCard(n).is_damage_card end)
end
return M

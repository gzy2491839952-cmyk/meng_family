local R=require "packages.meng_family.pkg.zhulv.revealed"
local M={}
function M.factions(lord)
 local t=lord:getTableMark("@dream_lingjue")
 table.insertIfNeed(t,"meng_qi")
 return t
end
function M.affected(player)
 return table.find(player.room.alive_players,function(lord)
  return lord~=player and lord:hasSkill("dream__lingjue") and table.contains(M.factions(lord),player.kingdom)
 end)~=nil
end
function M.suit(player,id)
 return M.affected(player) and Card.Spade or Fk:getCardById(id).suit
end
function M.color(player,id)
 if M.affected(player)then return Card.Black end
 return Fk:getCardById(id).color
end
function M.present(player,ids)
 player:showCards(ids)
end
function M.vote(room,players,name)
 local votes={};local red,black=0,0
 -- Collect privately before displaying any selected card.
 for _,p in ipairs(players)do
  if not p.dead and not p:isKongcheng()then
   local id=room:askToCards(p,{min_num=1,max_num=1,include_equip=false,cancelable=false,
    skill_name=name,prompt="#dream__tunmeng-vote"})[1]
   if id then table.insert(votes,{player=p,id=id,color=M.color(p,id)})end
  end
 end
 for _,v in ipairs(votes)do
  M.present(v.player,{v.id})
  if v.color==Card.Red then red=red+1 elseif v.color==Card.Black then black=black+1 end
 end
 return votes,red>black and Card.Red or(black>red and Card.Black or Card.NoColor)
end
M.revealed=R
return M

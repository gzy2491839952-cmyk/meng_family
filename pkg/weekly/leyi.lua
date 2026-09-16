local M={general="hanqing_god__leyi",light="hanqing_light"}
function M.is(p)return p.general==M.general or p.deputyGeneral==M.general end
function M.active(p)return M.is(p) and not p.dead and (p.rest or 0)==0 end
function M.activeOthers(room,p)return table.filter(room.players,function(q)return q~=p and M.active(q)end)end
function M.flank(victim)
 if victim.dead or (victim.rest or 0)>0 then return nil end
 local a,b=victim:getLastAlive(),victim:getNextAlive()
 if a~=b and a~=victim and b~=victim and M.active(a) and M.active(b) and a.kingdom==b.kingdom and a.kingdom~=victim.kingdom then return {a,b}end
end
function M.shown(p,id)
 if not table.contains(p:getCardIds("h"),id)then return false end
 local c=Fk:getCardById(id)
 for _,mark in ipairs{"@zhulv_revealed","@daxi__shewei","@xi__judong_shown"}do if c:getMark(mark)==p.id then return true end end
 return false
end
function M.spawn(p)
 local room=p.room
 if p:getMark("hqleyi_spawned")~=0 then return end
 room:setPlayerMark(p,"hqleyi_spawned",1)
 room:setPlayerMark(p,"hqleyi_owner",p.id)
 room:setPlayerProperty(p,"maxHp",2);room:setPlayerProperty(p,"hp",2)
 local anchor=p.next
 for i=1,2 do
  local body=room:addNpc(anchor)
  room:setPlayerMark(body,"hqleyi_spawned",1)
  room:setPlayerMark(body,"hqleyi_owner",p.id)
  for key,value in pairs{general=M.general,kingdom=p.kingdom,role=p.role,gender=General.Male,maxHp=2,hp=2,dead=false,faceup=true}do
   -- Hide identity from opponents until the normal identity reveal.
   if key=="role"then body.role=value;room:notifyProperty(p,body,"role")
   else room:setPlayerProperty(body,key,value)end
  end
  body:setInitController(p._controller_stack[1])
  table.insertIfNeed(room.alive_players,body)
  room.logic:attachGeneralSkillsToPlayer(body)
 end
 room:sortByAction(room.alive_players)
end
return M

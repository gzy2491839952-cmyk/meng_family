local M=require "packages.meng_family.pkg.weekly.leyi"
local skill=fk.CreateSkill{name="hqleyi__haishan"}
skill:addEffect("active",{
 card_num=0,target_num=1,
 can_use=function(self,p)return p.phase==Player.Play and table.find((p.room or Fk:currentRoom()).alive_players,function(q)return q~=p and M.active(q) and q.faceup end)~=nil end,
 target_filter=function(self,p,q,selected)return #selected==0 and q~=p and M.active(q) and q.faceup end,
 on_use=function(self,room,e)
  local p=e.from;local body=e.tos[1]
  if not M.active(body) or not body.faceup then return end
  local anchors=table.filter(room.alive_players,function(q)return q~=body end)
  local anchor=room:askToChoosePlayers(p,{targets=anchors,min_num=1,max_num=1,cancelable=false,skill_name=skill.name,prompt="#hqhaishan-position"})[1]
  if not anchor then return end
  body:turnOver()
  if body.faceup or not M.active(body) then return end
  room:moveSeatToNext(body,anchor,false,true)
  room:sortByAction(room.alive_players)
  if p.dead then return end
  local neighbors={};for _,q in ipairs{body:getLastAlive(),body:getNextAlive()}do
   if not q.dead and #q:getCardIds("he")>0 then table.insertIfNeed(neighbors,q)end
  end
  if #neighbors==0 then return end
  local to=room:askToChoosePlayers(p,{targets=neighbors,min_num=1,max_num=1,cancelable=false,skill_name=skill.name,prompt="#hqhaishan-obtain"})[1]
  local id=room:askToChooseCard(p,{target=to,flag="he",skill_name=skill.name})
  if id then room:obtainCard(p,id,false,fk.ReasonPrey,p,skill.name)end
 end,
})
Fk:loadTranslationTable{
 ["hqleyi__haishan"]="骇闪",
 [":hqleyi__haishan"]="出牌阶段，你可以令另一名正面朝上且不在休整中的“神乐毅”翻至背面并移至两名角色之间，然后你获得其上家或下家一张牌。",
 ["#hqhaishan-position"]="骇闪：选择一名角色，神乐毅将移至其下家位置",
 ["#hqhaishan-obtain"]="骇闪：选择移动后的上家或下家，获得其一张牌",
}
return skill

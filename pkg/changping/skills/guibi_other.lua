local skill=fk.CreateSkill{name="changping__guibi_other&"}
local used="changping_guibi_used"
local function eligible(from,to)
 return to~=from and not to.dead and to:hasSkill("changping__guibi")
   and #to:getCardIds("e")>0 and not to:isKongcheng()
end
skill:addEffect("active",{
 mute=true,
 anim_type="control",card_num=0,target_num=1,
 can_use=function(self,player)
  local room=player.room or Fk:currentRoom()
  return player.phase==Player.Play and player:getMark(used)==0
    and table.find(room.alive_players,function(p)return eligible(player,p)end)~=nil
 end,
 target_filter=function(self,player,to_select,selected)return #selected==0 and eligible(player,to_select)end,
 on_use=function(self,room,effect)
  local from,to=effect.from,effect.tos[1]
  if not eligible(from,to)then return end
  local ids=room:askToChooseCards(from,{target=to,flag="h",min=1,max=math.min(#to:getCardIds("e"),to:getHandcardNum()),
    cancelable=false,skill_name="changping__guibi",prompt="#changping__guibi-reveal::"..to.id})
  if #ids==0 then return end
  room:setPlayerMark(from,used,1)
  to:broadcastSkillInvoke("changping__guibi")
  to:showCards(ids)
  if to.dead then return end
  local function remaining()
   return table.filter(ids,function(id)return room:getCardOwner(id)==to and room:getCardArea(id)==Card.PlayerHand end)
  end
  local choice=room:askToChoice(to,{choices={"changping_guibi_use","changping_guibi_recast"},skill_name="changping__guibi"})
  if choice=="changping_guibi_use" then
   local pending=table.filter(remaining(),function(id)return Fk:getCardById(id).type==Card.TypeBasic end)
   while #pending>0 and not to.dead do
    pending=table.filter(pending,function(id)return room:getCardOwner(id)==to and room:getCardArea(id)==Card.PlayerHand end)
    if #pending==0 then break end
    local use=room:askToUseRealCard(to,{pattern=pending,skill_name="changping__guibi",cancelable=false,skip=true,
      extra_data={bypass_distances=true,bypass_times=true,extraUse=true},prompt="#changping__guibi-use"})
    if not use then break end -- No remaining card has a legal use (e.g. Jink).
    for _,id in ipairs(Card:getIdList(use.card))do table.removeOne(pending,id);table.removeOne(ids,id)end
    room:useCard(use)
   end
  else
   local recast=table.filter(remaining(),function(id)return Fk:getCardById(id).type~=Card.TypeBasic end)
   if #recast>0 then
    for _,id in ipairs(recast)do table.removeOne(ids,id)end
    room:recastCard(recast,to,"changping__guibi")
   end
  end
  local rest=remaining()
  if not from.dead and #rest>0 then room:moveCardTo(rest,Card.PlayerHand,from,fk.ReasonPrey,"changping__guibi",nil,true,from)end
 end,
})
Fk:loadTranslationTable{
 ["changping__guibi_other&"]="归璧",
 [":changping__guibi_other&"]="整局限一次，出牌阶段，你可以展示一名拥有“归璧”的其他角色至多其装备区牌数张手牌，其选择使用其中所有可合法使用的基本牌（无距离限制）或重铸其中所有非基本牌，然后你获得其余展示牌。",
 ["changping_guibi_use"]="使用其中所有可合法使用的基本牌",
 ["changping_guibi_recast"]="重铸其中所有非基本牌",
 ["#changping__guibi-reveal"]="归璧：选择展示%dest的手牌",
 ["#changping__guibi-use"]="归璧：须使用剩余展示基本牌（无距离限制）",
}
return skill

local skill=fk.CreateSkill{name="weekly__tanqin"}
local busy="weekly_tanqin_resolving"
local function resolve(player)
 local room=player.room
 room:setPlayerMark(player,busy,1)
 local n=#player:getCardIds("e")-player:getHandcardNum()
 if n>0 then player:drawCards(n,skill.name)
 elseif n<0 then room:askToDiscard(player,{min_num=-n,max_num=-n,include_equip=false,
   skill_name=skill.name,cancelable=false,prompt="#weekly__tanqin-adjust"})end
 if not player.dead and player:getHandcardNum()<=player:getMaxCards()then
  local most=0
  for _,p in ipairs(room.alive_players)do most=math.max(most,p:getHandcardNum())end
  if most>0 then
   local targets=table.filter(room.alive_players,function(p)return p:getHandcardNum()==most end)
   local to=room:askToChoosePlayers(player,{targets=targets,min_num=1,max_num=1,
    skill_name=skill.name,cancelable=true,prompt="#weekly__tanqin-look"})[1]
   if to then
    local hand=to:getCardIds("h")
    room:viewCards(player,{cards=hand,skill_name=skill.name,prompt="#weekly__tanqin-hand"})
    local ids=table.filter(to:getCardIds("h"),function(id)
     local c=Fk:getCardById(id)
     return (c.type==Card.TypeBasic or c.type==Card.TypeEquip) and not player:prohibitDiscard(id)
    end)
    if #ids>0 then
     local selected=room:askToChooseCards(player,{target=to,flag={card_data={{"$Hand",ids}}},
      min=1,max=1,skill_name=skill.name,cancelable=false,prompt="#weekly__tanqin-discard"})
     if #selected>0 then room:throwCard(selected,skill.name,to,player)end
    end
   end
  end
 end
 room:setPlayerMark(player,busy,0)
end
skill:addEffect(fk.BeforeDrawCard,{
 can_trigger=function(self,event,target,player,data)
  return target==player and player:hasSkill(skill.name) and player:getMark(busy)==0 and data.num>0
 end,
 on_cost=function(self,event,target,player,data)return player.room:askToSkillInvoke(player,{skill_name=skill.name,prompt="#weekly__tanqin-replace"})end,
 on_use=function(self,event,target,player,data)data.num=0;resolve(player)end,
})
skill:addEffect(fk.BeforeCardsMove,{
 can_trigger=function(self,event,target,player,data)
  return player:hasSkill(skill.name) and player:getMark(busy)==0 and table.find(data,function(m)
   return m.from==player and m.moveReason==fk.ReasonDiscard and #m.moveInfo>0
  end)~=nil
 end,
 on_cost=function(self,event,target,player,data)return player.room:askToSkillInvoke(player,{skill_name=skill.name,prompt="#weekly__tanqin-replace"})end,
 on_use=function(self,event,target,player,data)
  player.room:cancelMove(data,nil,function(m,i)return m.from==player and m.moveReason==fk.ReasonDiscard end)
  resolve(player)
 end,
})
Fk:loadTranslationTable{
 ["weekly__tanqin"]="探秦",
 [":weekly__tanqin"]="你即将执行的摸／弃牌结算可以改为：将手牌数向上／下调整至装备区牌数，然后若手牌数未超出手牌上限，你可以观看手牌数最大角色的手牌，并弃置其一张装备牌或基本牌。",
 ["#weekly__tanqin-replace"]="探秦：将此次摸／弃牌改为把手牌数调整至装备区牌数？",
 ["#weekly__tanqin-adjust"]="探秦：将手牌数调整至装备区牌数",
 ["#weekly__tanqin-look"]="探秦：可观看一名手牌最多角色的手牌，并弃置其中一张基本或装备牌",
 ["#weekly__tanqin-hand"]="探秦：观看手牌",
 ["#weekly__tanqin-discard"]="探秦：弃置其一张基本牌或装备牌",
}
return skill

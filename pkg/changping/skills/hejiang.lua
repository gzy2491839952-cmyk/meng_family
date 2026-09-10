local U=require "packages.meng_family.pkg.changping.hejiang_util"
local skill=fk.CreateSkill{name="changping__hejiang"}
skill:addEffect("active",{
  anim_type="support",card_num=1,target_num=1,
  can_use=function(self,player)return player.phase==Player.Play end,
  card_filter=function(self,player,to_select,selected)
    return #selected==0 and table.contains(player:getCardIds("he"),to_select)
      and Fk:getCardById(to_select).type==Card.TypeBasic
      and not table.contains(player:getTableMark(U.used),Fk:getCardById(to_select).trueName)
  end,
  target_filter=function(self,player,to_select,selected,cards)
    return #selected==0 and #cards==1 and #U.available(to_select)>0
  end,
  on_use=function(self,room,effect)
    local p,to=effect.from,effect.tos[1]
    local id=effect.cards[1];local card=Fk:getCardById(id)
    if to.dead or #U.available(to)==0 then return end
    local slot=room:askToChoice(p,{choices=U.available(to),skill_name=skill.name,prompt="#changping__hejiang-slot::"..to.id})
    local i=U.slotIndex(slot)
    local names=p:getTableMark(U.used);table.insertIfNeed(names,card.trueName);room:setPlayerMark(p,U.used,names)
    local old=to:getEquipments(U.types[i])
    local moves={}
    -- For a duplicated slot, replace only when every available instance is occupied.
    if #old>=#to:getAvailableEquipSlots(U.types[i]) and #old>0 then
      local oid=old[1]
      if #old>1 then oid=room:askToChooseCard(p,{target=to,flag={card_data={{"equip",old}}},skill_name=skill.name})end
      table.insert(moves,{ids={oid},from=to,toArea=Card.DiscardPile,moveReason=fk.ReasonPutIntoDiscardPile,skillName=skill.name})
    end
    local v=Fk:cloneCard("changping__hejiang_equip"..i,card.suit,card.number);v:addSubcard(id)
    room:setCardMark(card,U.mark,{p.id,card.name})
    table.insert(moves,{ids={id},from=room:getCardOwner(id),to=to,toArea=Card.PlayerEquip,
      moveReason=fk.ReasonJustMove,skillName=skill.name,moveVisible=true,virtualEquip=v})
    room:moveCards(table.unpack(moves))
  end,
})
skill:addEffect(fk.AfterCardsMove,{
  global=true,
  can_refresh=function(self,event,target,player,data)return not event:getSkillData(self,"hejiang_departures")end,
  on_refresh=function(self,event,target,player,data)
    local records={}
    for _,move in ipairs(data)do
      for _,info in ipairs(move.moveInfo)do
        local c=Fk:getCardById(info.cardId,true);local mark=c:getMark(U.mark)
        if type(mark)=="table" and info.fromArea==Card.PlayerEquip and move.from
          and (move.toArea~=Card.PlayerEquip or move.to~=move.from)then
          table.insert(records,{owner=mark[1],name=mark[2],loser=move.from.id})
          if player.room:getCardArea(info.cardId)~=Card.PlayerEquip then player.room:setCardMark(c,U.mark,0)end
        end
      end
    end
    event:setSkillData(self,"hejiang_departures",records)
  end,
  can_trigger=function(self,event,target,player,data)
    return player:hasSkill(skill.name) and not player.dead and table.find(event:getSkillData(self,"hejiang_departures") or {},function(r)return r.owner==player.id end)
  end,
  on_cost=function()return true end,
  on_use=function(self,event,target,player,data)
    local room=player.room
    for _,record in ipairs(event:getSkillData(self,"hejiang_departures") or {})do
      if record.owner==player.id and not player.dead then
        local targets={player};local loser=room:getPlayerById(record.loser)
        if loser~=player and not loser.dead then table.insert(targets,loser)end
        targets=table.filter(targets,function(p)return #Fk:cloneCard(record.name):getAvailableTargets(p,{bypass_times=true})>0 end)
        if #targets>0 then
          local tos=room:askToChoosePlayers(player,{targets=targets,min_num=1,max_num=1,cancelable=true,
            skill_name=skill.name,prompt="#changping__hejiang-use:::"..record.name})
          if #tos==1 then room:askToUseVirtualCard(tos[1],{name=record.name,skill_name=skill.name,cancelable=false})end
        end
      end
    end
  end,
})
Fk:loadTranslationTable{
 ["changping__hejiang"]="和将",
 [":changping__hejiang"]="出牌阶段每种牌名限一次，你可以将一张基本牌置入一名角色的装备区（替换原装备），此牌离开装备区后，你可以令你或失去者视为使用之。",
 ["#changping__hejiang-slot"]="和将：选择%dest的一个装备栏（基本牌不提供装备效果）",
 ["#changping__hejiang-use"]="和将：你可以令你或失去此牌的角色视为使用【%arg】",
}
Fk:loadTranslationTable{
 ["$changping__hejiang1"]="我与廉将军同为赵臣，岂可以私怨误国！",
 ["$changping__hejiang2"]="将军御敌于外，相如岂可生隙于内！",
}
skill:addEffect(fk.GameFinished,{
 global=true,
 can_refresh=function(self,event,target,player,data)
  return (player.general=="changping__linxiangru" or player.deputyGeneral=="changping__linxiangru")
   and table.contains(data.players or {},player) and player:getMark("changping__linxiangru_victory_voice")==0
 end,
 on_refresh=function(self,event,target,player,data)
  player.room:setPlayerMark(player,"changping__linxiangru_victory_voice",1)
  player.room:broadcastPlaySound("./packages/meng_family/audio/win/changping__linxiangru")
 end,
})
Fk:loadTranslationTable{
 ["!changping__linxiangru"]="强秦虽有万乘，亦不能夺赵国之尊！",
 ["~changping__linxiangru"]="赵括徒读兵书，未谙临阵之变……大王慎之……",
}
return skill

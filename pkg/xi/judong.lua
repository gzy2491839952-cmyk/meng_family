-- SPDX-License-Identifier: GPL-3.0-or-later
local U=require 'packages.meng_family.pkg.xi.yangjun_util'
return function(alternate)
  local skill=fk.CreateSkill{name=alternate and 'xi__judong_xi' or 'xi__judong'}
  skill:addEffect(fk.EventPhaseStart,{
    can_trigger=function(self,event,target,player)return target==player and player.phase==Player.Start and player:hasSkill(skill.name)end,
    on_cost=function(self,event,target,player)
      return player.room:askToSkillInvoke(player,{skill_name=skill.name,prompt='#xi__judong-invoke'})
    end,
    on_use=function(self,event,target,player)
      local room=player.room;local max=player:getHandcardNum()
      for _,p in ipairs(room.alive_players) do max=math.max(max,p:getHandcardNum()) end
      local n=max-player:getHandcardNum();if n>0 then player:drawCards(n,skill.name) end
      if player.dead then return end
      if not alternate then
        room:setPlayerMark(player,'xi__judong_resolving',1)
        room:setPlayerMark(player,'xi__judong_emptied',0)
      end
      local others=room:getOtherPlayers(player);room:sortByAction(others,player)
      for _,p in ipairs(others) do
        if player.dead then break end
        if not p.dead then
          local ids=table.filter(p:getCardIds('h'),function(id)
            return Fk:getCardById(id).trueName=='slash' and not U.isShown(room,id)
          end)
          if not alternate and not table.find(player:getCardIds('h'),function(id)return not player:prohibitDiscard(id)end) then ids={} end
          if alternate then
            ids=table.filter(ids,function(id)
              local c=Fk:cloneCard(Fk:getCardById(id).name)
              return not p:prohibitUse(c) and not p:isProhibited(player,c)
            end)
          end
          if #ids>0 then
            local chosen=room:askToCards(p,{min_num=1,max_num=1,include_equip=false,cancelable=true,
              pattern=tostring(Exppattern{id=ids}),skill_name=skill.name,
              prompt=alternate and '#xi__judong-slash::'..player.id or '#xi__judong-show::'..player.id})
            if #chosen==1 then
              local id=chosen[1];local name=Fk:getCardById(id).name
              room:setCardMark(Fk:getCardById(id),U.shown,p.id)
              p:showCards(chosen)
              if not p.dead and not player.dead then
                if alternate then room:useVirtualCard(name,nil,p,player,skill.name,true)
                else U.discardBy(p,player,1,true,skill.name) end
              end
            end
          end
        end
      end
      if not alternate then
        local emptied=player:getMark('xi__judong_emptied')>0
        room:setPlayerMark(player,'xi__judong_resolving',0)
        room:setPlayerMark(player,'xi__judong_emptied',0)
        if emptied then U.change(player,true) end
      end
    end,
  })
  if not alternate then
    skill:addEffect('visibility',{
      card_visible=function(self,viewer,card)
        local room=Fk:currentRoom();local owner=room:getCardOwner(card.id)
        if owner and room:getCardArea(card.id)==Card.PlayerHand and card:getMark(U.shown)==owner.id then return true end
      end,
    })
    skill:addEffect(fk.AfterCardsMove,{
      global=true,
      can_refresh=function(self,event,target,player,data)
        return table.find(data,function(move)return move.from==player end)~=nil
      end,
      on_refresh=function(self,event,target,player,data)
        for _,move in ipairs(data) do
          if move.from==player then
            for _,info in ipairs(move.moveInfo) do
              if info.fromArea==Card.PlayerHand then
                local card=Fk:getCardById(info.cardId)
                if card:getMark(U.shown)==player.id then player.room:setCardMark(card,U.shown,0) end
              end
            end
            if player:getMark('xi__judong_resolving')>0 and move.skillName=='xi__judong'
              and move.moveReason==fk.ReasonDiscard and player:isKongcheng()
              and table.find(move.moveInfo,function(info)return info.fromArea==Card.PlayerHand end) then
              player.room:setPlayerMark(player,'xi__judong_emptied',1)
            end
          end
        end
      end,
    })
  end
  return skill
end

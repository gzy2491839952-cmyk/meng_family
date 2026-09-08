-- SPDX-License-Identifier: GPL-3.0-or-later
local U=require 'packages.meng_family.pkg.xi.zhangti_util'
return function(alternate)
  local skill=fk.CreateSkill{name=alternate and 'xi__juedu_xi' or 'xi__juedu'}
  -- The stock recast menu accepts only physical hand cards. Supply a button
  -- restricted to borrowed cards which already have the native recast action.
  local function canRecast(player,id)
    return table.contains(U.available(player),id)
      and table.contains(Fk:getCardById(id).special_skills or {},'recast')
  end
  skill:addEffect('active',{
    handly_pile=true,card_num=1,target_num=0,prompt='#xi__juedu-recast',
    can_use=function(self,player)
      return player.phase==Player.Play and table.find(U.available(player),function(id)return canRecast(player,id)end)~=nil
    end,
    card_filter=function(self,player,id,selected)return #selected==0 and canRecast(player,id)end,
    on_use=function(self,room,effect)
      U.installRoom(room)
      room:recastCard(effect.cards,effect.from,'recast')
    end,
  })
  skill:addEffect(fk.EventPhaseStart,{
    can_trigger=function(self,event,target,player)
      if not player:hasSkill(skill.name) or not target or target.phase~=Player.Start then return false end
      if alternate then return #U.areas(player)>0 end
      local ids=player:getCardIds('he')
      return target==player and #ids>0 and table.every(ids,function(id)return not player:prohibitDiscard(id)end)
    end,
    on_cost=function(self,event,target,player)
      if not alternate then return player.room:askToSkillInvoke(player,{skill_name=skill.name,prompt='#xi__juedu-invoke'}) end
      local choices=U.areas(player);table.insert(choices,'Cancel')
      local choice=player.room:askToChoice(player,{choices=choices,skill_name=skill.name,prompt='#xi__juedu-area'})
      if choice~='Cancel' then event:setCostData(self,{choice=choice});return true end
    end,
    on_use=function(self,event,target,player)
      local room=player.room
      if alternate then
        local choice=event:getCostData(self).choice
        local slots=choice=='xi__juedu_hand' and {Player.HandSlot}
          or choice=='xi__juedu_judge' and {Player.JudgeSlot} or player:getAvailableEquipSlots()
        local record=player:getTableMark(U.restore)
        for _,slot in ipairs(slots) do table.insert(record,slot) end
        room:setPlayerMark(player,U.restore,record)
        room:abortPlayerArea(player,slots)
      else
        room:throwCard(player:getCardIds('he'),skill.name,player,player)
      end
      if not player.dead then U.enable(player,alternate and 'times' or 'distance') end
    end,
  })
  if not alternate then
    skill:addEffect(fk.AfterCardsMove,{
      global=true,
      can_refresh=function(self,event,target,player,data)
        return player:hasSkill('xi__juedu',true) or player:hasSkill('xi__juedu_xi',true)
          or #player:getTableMark(U.modes)>0
      end,
      on_refresh=function(self,event,target,player,data)
        local ids=player:getTableMark(U.seen)
        for _,move in ipairs(data) do
          if move.toArea==Card.DiscardPile then
            for _,info in ipairs(move.moveInfo) do table.insertIfNeed(ids,info.cardId) end
          end
        end
        player.room:setPlayerMark(player,U.seen,ids)
      end,
    })
    skill:addEffect(fk.TurnStart,{
      global=true,priority=1000,
      can_refresh=function(self,event,target,player)
        return target==player and #player:getTableMark(U.restore)>0
      end,
      on_refresh=function(self,event,target,player)
        local slots=player:getTableMark(U.restore)
        player.room:setPlayerMark(player,U.restore,0)
        player.room:resumePlayerArea(player,slots)
      end,
    })
    skill:addEffect('filter',{handly_cards=function(self,player)return U.available(player)end})
    skill:addEffect('targetmod',{
      bypass_distances=function(self,player,cardSkill,card)
        return table.contains(player:getTableMark(U.modes),'distance') and U.borrowed(player,card)
      end,
      bypass_times=function(self,player,cardSkill,scope,card)
        return table.contains(player:getTableMark(U.modes),'times') and U.borrowed(player,card)
      end,
    })
    for _,timing in ipairs{fk.PreCardUse,fk.PreCardRespond} do
      skill:addEffect(timing,{
        global=true,
        can_refresh=function(self,event,target,player,data)return target==player and U.borrowed(player,data.card)end,
        on_refresh=function(self,event,target,player,data)
          local available=U.available(player)
          data.xi__juedu_bottom=table.filter(Card:getIdList(data.card),function(id)return table.contains(available,id)end)
          for _,id in ipairs(data.xi__juedu_bottom) do player.room:setCardMark(Fk:getCardById(id),'xi__juedu_using',player.id) end
          if timing==fk.PreCardUse and table.contains(player:getTableMark(U.modes),'times') then data.extraUse=true end
        end,
      })
    end
    for _,timing in ipairs{fk.CardUseFinished,fk.CardRespondFinished} do
      skill:addEffect(timing,{
        global=true,priority=-1000,
        can_refresh=function(self,event,target,player,data)return target==player and data.xi__juedu_bottom~=nil end,
        on_refresh=function(self,event,target,player,data)
          local ids=data.xi__juedu_bottom;data.xi__juedu_bottom=nil
          U.bottom(player.room,ids,player)
          for _,id in ipairs(ids) do player.room:setCardMark(Fk:getCardById(id),'xi__juedu_using',0) end
        end,
      })
    end
  end
  return skill
end

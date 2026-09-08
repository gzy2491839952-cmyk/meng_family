-- SPDX-License-Identifier: GPL-3.0-or-later
local U=require 'packages.meng_family.pkg.xi.yangjun_util'
local function currentUse(player)
  local e=player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
  local use=e and e.data
  if use and use.from==player and use.extra_data and use.extra_data.xi__xiongcou then return use end
end
return function(alternate)
  local skill=fk.CreateSkill{name=alternate and 'xi__xiongcou_xi' or 'xi__xiongcou'}
  skill:addEffect('viewas',{
    pattern='.',prompt=alternate and '#xi__xiongcou_xi' or '#xi__xiongcou',
    expand_pile=function(self,player)return U.materials(player)end,
    interaction=function(self,player)
      local all=U.names(player,alternate)
      local choices=player:getViewAsCardNames(skill.name,all)
      if #choices>0 then return UI.CardNameBox{choices=choices,all_choices=all} end
    end,
    filter_pattern=function(self,player,name)
      local n=name and U.nameLength(name) or (self.interaction.data and U.nameLength(self.interaction.data) or 1)
      return {min_num=n,max_num=n,pattern='.'}
    end,
    card_filter=function(self,player,id,selected)
      local name=self.interaction.data
      return name and #selected<U.nameLength(name) and not table.contains(selected,id)
        and table.contains(U.materials(player),id)
    end,
    view_as=function(self,player,ids)
      local name=self.interaction.data
      if not name or #ids~=U.nameLength(name) or not table.contains(U.names(player,alternate),name) then return end
      local c=Fk:cloneCard(name);c:addSubcards(ids);c.skillName=skill.name;return c
    end,
    enabled_at_play=function(self,player)return #U.names(player,alternate)>0 end,
    enabled_at_response=function(self,player,responding)return not responding and #U.names(player,alternate)>0 end,
    enabled_at_nullification=function(self,player)return alternate and table.contains(U.names(player,true),'nullification')end,
    before_use=function(self,player,use)
      local ids=Card:getIdList(use.card);local available=U.materials(player)
      if #ids~=U.nameLength(use.card.name) or not table.every(ids,function(id)return table.contains(available,id)end) then return skill.name end
      use.extra_data=use.extra_data or {}
      use.extra_data.xi__xiongcou={alternate=alternate,materials=ids,consumed={},losses={},awarded={}}
    end,
  })
  if not alternate then
    skill:addEffect(fk.AfterCardsMove,{
      global=true,
      can_refresh=function(self,event,target,player,data)return currentUse(player)~=nil end,
      on_refresh=function(self,event,target,player,data)
        local use=currentUse(player);if not use then return end
        local record=use.extra_data.xi__xiongcou
        for _,move in ipairs(data) do
          if move.from and move.toArea==Card.Processing and move.moveReason==fk.ReasonUse then
            local owner=move.from
            for _,info in ipairs(move.moveInfo) do
              if info.fromArea==Card.PlayerHand and table.contains(record.materials,info.cardId)
                and not table.contains(record.consumed,info.cardId) then
                table.insert(record.consumed,info.cardId)
                local key=tostring(owner.id)
                record.losses[key]=(record.losses[key] or 0)+1
                if not record.alternate and not record.awarded[key] then
                  record.awarded[key]=true
                  player.room:addPlayerMark(owner,U.pending,1)
                end
              end
            end
          end
        end
      end,
    })
    skill:addEffect(fk.DamageInflicted,{
      global=true,mute=true,
      can_trigger=function(self,event,target,player,data)return target==player and player:getMark(U.pending)>0 and data.damage>0 end,
      on_cost=function()return true end,
      on_use=function(self,event,target,player,data)
        local n=player:getMark(U.pending);player.room:setPlayerMark(player,U.pending,0);data:changeDamage(n)
      end,
    })
    skill:addEffect(fk.CardUseFinished,{
      global=true,is_delay_effect=true,
      can_trigger=function(self,event,target,player,data)
        local record=data.extra_data and data.extra_data.xi__xiongcou
        return data.from==player and record and record.alternate and not record.rewarded and next(record.losses)~=nil
      end,
      on_cost=function()return true end,
      on_use=function(self,event,target,player,data)
        local room=player.room;local record=data.extra_data.xi__xiongcou;record.rewarded=true
        local owners=table.filter(room.alive_players,function(p)return record.losses[tostring(p.id)]~=nil end)
        room:sortByAction(owners)
        for _,owner in ipairs(owners) do
          if not owner.dead then
            local n=record.losses[tostring(owner.id)]
            local choices={'xi__xiongcou_draw','Cancel'}
            if not player.dead and table.find(player:getCardIds('he'),function(id)return not player:prohibitDiscard(id)end) then
              table.insert(choices,2,'xi__xiongcou_discard')
            end
            local choice=room:askToChoice(owner,{choices=choices,skill_name='xi__xiongcou_xi',prompt='#xi__xiongcou-choice::'..player.id..':'..n})
            if choice=='xi__xiongcou_draw' then owner:drawCards(n,'xi__xiongcou_xi')
            elseif choice=='xi__xiongcou_discard' then U.discardBy(owner,player,n,false,'xi__xiongcou_xi') end
          end
        end
      end,
    })
  end
  return skill
end

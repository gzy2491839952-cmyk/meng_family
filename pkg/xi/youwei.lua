-- SPDX-License-Identifier: GPL-3.0-or-later
local U=require 'packages.meng_family.pkg.xi.zhangti_util'
local function recastable(player,damage)
  local ids=player:getCardIds('he')
  table.insertTableIfNeed(ids,player:getHandlyIds())
  return table.filter(ids,function(id)
    local c=Fk:getCardById(id)
    if damage then return c.is_damage_card or c.type==Card.TypeEquip end
    return not c.is_damage_card
  end)
end
return function(alternate)
  local skill=fk.CreateSkill{name=alternate and 'xi__youwei_xi' or 'xi__youwei'}
  skill:addEffect(fk.TargetConfirmed,{
    can_trigger=function(self,event,target,player,data)
      if not player:hasSkill(skill.name) or not data.card.is_damage_card then return false end
      if alternate then return target==player end
      return player:getMark('xi__youwei_used-turn')==0 and #recastable(player,true)>0
    end,
    on_cost=function(self,event,target,player,data)
      if alternate then return true end
      local cards=player.room:askToCards(player,{
        min_num=1,max_num=1,include_equip=true,expand_pile=player:getHandlyIds(false),
        pattern=tostring(Exppattern{id=recastable(player,true)}),cancelable=true,
        skill_name=skill.name,prompt='#xi__youwei-recast::'..target.id,
      })
      if #cards>0 then event:setCostData(self,{cards=cards});return true end
    end,
    on_use=function(self,event,target,player,data)
      local room=player.room
      if not alternate then
        room:setPlayerMark(player,'xi__youwei_used-turn',1)
        U.installRoom(room)
        room:recastCard(event:getCostData(self).cards,player,skill.name)
        data:setNullified(target)
        local source=data.from
        if player.dead or not source or source.dead or source:isNude() then return end
        local id=room:askToChooseCard(player,{target=source,flag='he',skill_name=skill.name})
        room:obtainCard(player,id,true,fk.ReasonPrey,player,skill.name)
        if not player.dead and room:getCardOwner(id)==player and U.mentionsSlash(Fk:getCardById(id)) then U.change(player,true) end
      else
        local source=data.from
        local gift={}
        if source and not source.dead and source~=player then
          local ids=table.filter(source:getCardIds('he'),function(id)return U.mentionsSlash(Fk:getCardById(id))end)
          if #ids>0 then gift=room:askToCards(source,{
            min_num=1,max_num=1,include_equip=true,pattern=tostring(Exppattern{id=ids}),cancelable=true,
            skill_name=skill.name,prompt='#xi__youwei-give::'..player.id,
          }) end
        end
        if #gift>0 then
          room:moveCards{ids=gift,from=source,to=player,toArea=Card.PlayerHand,
            moveReason=fk.ReasonGive,proposer=source,skillName=skill.name,moveVisible=true}
          data.use:changeEffectTimes(player,1)
        else
          data.use.extra_data=data.use.extra_data or {}
          data.extra_data=data.use.extra_data
          local pending=data.extra_data.xi__youwei_pending or {}
          table.insertIfNeed(pending,player.id)
          data.extra_data.xi__youwei_pending=pending
        end
      end
    end,
  })
  if alternate then
    skill:addEffect(fk.CardUseFinished,{
      is_delay_effect=true,
      can_trigger=function(self,event,target,player,data)
        return not player.dead and player:hasSkill(skill.name)
          and table.contains(data.extra_data and data.extra_data.xi__youwei_pending or {},player.id)
      end,
      on_cost=function()return true end,
      on_use=function(self,event,target,player,data)
        local room=player.room
        table.removeOne(data.extra_data.xi__youwei_pending,player.id)
        local used={}
        while not player.dead and player:hasSkill(skill.name) do
          local targets=table.filter(room.alive_players,function(p)return not table.contains(used,p.id)end)
          if #targets==0 then break end
          local ids=table.filter(player:getHandlyIds(),function(id)
            local card=Fk:getCardById(id);return card.is_damage_card or card.type==Card.TypeEquip
          end)
          if #ids==0 then break end
          local use=room:askToUseRealCard(player,{
            pattern=ids,expand_pile=player:getHandlyIds(false),skill_name=skill.name,cancelable=true,skip=true,
            prompt='#xi__youwei-chain',
            extra_data={bypass_times=true,extraUse=true,exclusive_targets=table.map(targets,function(p)return p.id end)},
          })
          if not use or #use.tos==0 or table.find(use.tos,function(p)return table.contains(used,p.id)end) then break end
          for _,p in ipairs(use.tos) do table.insertIfNeed(used,p.id) end
          use.extra_data=use.extra_data or {};use.extra_data.xi__youwei_chain=player.id
          room:useCard(use)
        end
      end,
    })
    for _,timing in ipairs{fk.CardUsing,fk.CardResponding} do
      skill:addEffect(timing,{
        can_trigger=function(self,event,target,player,data)
          local effect=data.responseToEvent
          local use=effect and effect.use
          return player:hasSkill(skill.name) and use and use.extra_data
            and use.extra_data.xi__youwei_chain==player.id
        end,
        on_cost=function()return true end,
        on_use=function(self,event,target,player,data)
          local room=player.room
          local cards=recastable(player,false)
          local choices={'xi__youwei_exit'}
          if #cards>0 then table.insert(choices,1,'xi__youwei_recast') end
          local choice=room:askToChoice(player,{choices=choices,skill_name=skill.name,prompt='#xi__youwei-responded'})
          if choice=='xi__youwei_exit' then U.change(player,false);return end
          local ids=room:askToCards(player,{min_num=1,max_num=1,include_equip=true,
            expand_pile=player:getHandlyIds(false),pattern=tostring(Exppattern{id=cards}),
            cancelable=false,skill_name=skill.name,prompt='#xi__youwei-nondamage'})
          U.installRoom(room)
          room:recastCard(ids,player,skill.name)
        end,
      })
    end
  end
  return skill
end

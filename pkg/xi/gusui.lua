-- SPDX-License-Identifier: GPL-3.0-or-later
local U=require 'packages.meng_family.pkg.xi.guanyu_util'
return function(alternate)
  local skill=fk.CreateSkill{name=alternate and 'xi__gusui_xi' or 'xi__gusui'}
  if not alternate then
    skill:addEffect(fk.HpChanged,{
      global=true,
      can_refresh=function(self,event,target,player,data)
        return target==player and data.num~=0 and not data.prevented
          and (player:hasSkill('xi__gusui',true) or player:hasSkill('xi__gusui_xi',true))
      end,
      on_refresh=function(self,event,target,player,data)
        local history=player:getTableMark(U.history)
        local first=not table.contains(history,player.hp)
        table.insertIfNeed(history,player.hp)
        player.room:setPlayerMark(player,U.history,history)
        local highest,unique=true,true
        for _,p in ipairs(player.room.alive_players) do
          if p~=player then
            if p.hp>player.hp then highest=false end
            if p.hp==player.hp then unique=false end
          end
        end
        data.xi__gusui=data.xi__gusui or {}
        data.xi__gusui[player.id]={count=(highest and 1 or 0)+(unique and 1 or 0)+(first and 1 or 0),
          alternate=player:getMark('@@hanqing_xi')~=0}
      end,
    })
  end
  skill:addEffect(fk.HpChanged,{
    can_trigger=function(self,event,target,player,data)
      local record=data.xi__gusui and data.xi__gusui[player.id]
      return target==player and player:hasSkill(skill.name) and record and record.alternate==alternate
    end,
    on_cost=function(self,event,target,player,data)
      event:setCostData(self,{empty=player:isKongcheng(),count=data.xi__gusui[player.id].count})
      return true
    end,
    on_use=function(self,event,target,player,data)
      local cost=event:getCostData(self)
      if alternate then
        local n=3-cost.count
        if n>0 then player.room:askToDiscard(player,{
          min_num=n,max_num=n,include_equip=true,cancelable=false,skill_name=skill.name,
        }) end
        if player:isKongcheng() then U.damage(player,skill.name) end
      else
        if cost.count>0 then player:drawCards(cost.count,skill.name) end
        if cost.empty then U.damage(player,skill.name) end
      end
    end,
  })
  return skill
end

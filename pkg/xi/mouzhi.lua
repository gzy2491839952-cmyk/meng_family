-- SPDX-License-Identifier: GPL-3.0-or-later
local state = require "packages.meng_family.pkg.xi.state"
require("packages.meng_family.pkg.xi.mouzhi_ui").install()
local colors, suits = "xi__mouzhi_colors-turn", "xi__mouzhi_suits-turn"
return function(alternate)
  local skill = fk.CreateSkill{name=alternate and "xi__mouzhi_xi" or "xi__mouzhi"}
  skill:addEffect("viewas", {
    handly_pile=true,
    prompt=alternate and "#xi__mouzhi_xi" or "#xi__mouzhi",
    interaction=function(self,player)
      local all=Fk:getAllCardNames("t")
      local choices=player:getViewAsCardNames(skill.name,all)
      if #choices>0 then return UI.CardNameBox{choices=choices,all_choices=all} end
    end,
    card_filter=function(self,player,id,selected)
      return #selected==0 and table.contains(player:getHandlyIds(),id)
    end,
    view_as=function(self,player,cards)
      if #cards~=1 or not self.interaction.data then return end
      local card=Fk:cloneCard(self.interaction.data)
      card:addSubcard(cards[1])
      card.skillName=skill.name
      return card
    end,
    enabled_at_play=function(self,player) return player.phase==Player.Play end,
    enabled_at_response=function() return false end,
    before_use=function(self,player,use)
      use.extra_data=use.extra_data or {}
      use.extra_data.xi__mouzhi_penalty={key=alternate and suits or colors,
        value=alternate and use.card.suit or use.card.color}
    end,
    after_use=function(self,player,use)
      local penalty=use.extra_data and use.extra_data.xi__mouzhi_penalty
      if not penalty then return end
      local values=player:getTableMark(penalty.key)
      table.insertIfNeed(values,penalty.value)
      player.room:setPlayerMark(player,penalty.key,values)
    end,
  })
  if not alternate then
    skill:addEffect("prohibit", {
      -- Bans survive changing form or losing Mouzhi, until this turn ends.
      prohibit_use=function(self,player,card)
        return table.contains(player:getTableMark(colors),card.color)
          or table.contains(player:getTableMark(suits),card.suit)
      end,
    })
    skill:addEffect(fk.TargetConfirmed, {
      global=true,
      can_refresh=function(self,event,target,player,data)
        return target==player and data.card.type==Card.TypeTrick
      end,
      on_refresh=function(self,event,target,player)
        player.room:setPlayerMark(player,"xi__mouzhi_target-turn",1)
      end,
    })
    skill:addEffect(fk.TurnEnd, {
      can_trigger=function(self,event,target,player)
        return target==player and player:hasSkill(skill.name) and
          table.find(player.room.alive_players,function(p) return p:getMark("xi__mouzhi_target-turn")>0 end)
      end,
      on_cost=function(self,event,target,player)
        local targets=table.filter(player.room.alive_players,function(p) return p:getMark("xi__mouzhi_target-turn")>0 end)
        local chosen=player.room:askToChoosePlayers(player,{
          targets=targets,min_num=1,max_num=1,cancelable=true,skill_name=skill.name,prompt="#xi__mouzhi-target",
        })
        if #chosen>0 then event:setCostData(self,{to=chosen[1]});return true end
      end,
      on_use=function(self,event,target,player)
        local to=event:getCostData(self).to
        local room=player.room
        local use=not to.dead and room:askToUseCard(to,{
          pattern="slash",skill_name=skill.name,prompt="#xi__mouzhi-slash",cancelable=true,
          extra_data={bypass_times=true,extraUse=true},
        })
        if use then room:useCard(use) else state.change(player,true) end
      end,
    })
  else
    skill:addEffect(fk.CardEffectCancelledOut, {
      can_trigger=function(self,event,target,player,data)
        return player:hasSkill(skill.name) and data.from==player and data.card.type==Card.TypeTrick
      end,
      on_cost=function() return true end,
      on_use=function(self,event,target,player)
        local choice=player.room:askToChoice(player,{
          choices={"xi__mouzhi_losehp","xi__mouzhi_leave"},skill_name=skill.name,prompt="#xi__mouzhi-cancelled",
        })
        if choice=="xi__mouzhi_losehp" then player.room:loseHp(player,1,skill.name)
        else state.change(player,false) end
      end,
    })
  end
  return skill
end

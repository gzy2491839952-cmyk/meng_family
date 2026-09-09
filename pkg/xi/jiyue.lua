-- SPDX-License-Identifier: GPL-3.0-or-later
local U=require 'packages.meng_family.pkg.xi.guanyu_util'
return function(alternate)
  local skill=fk.CreateSkill{name=alternate and 'xi__jiyue_xi' or 'xi__jiyue'}
  skill:addEffect('viewas',{
    pattern=alternate and 'slash,nullification' or 'nullification',
    prompt=alternate and '#xi__jiyue_xi' or '#xi__jiyue',
    interaction=function(self,player)
      local all=alternate and {'slash','nullification'} or {'nullification'}
      local choices=player:getViewAsCardNames(skill.name,all)
      if #choices>0 then return UI.CardNameBox{choices=choices,all_choices=all} end
    end,
    filter_pattern={min_num=1,max_num=999,pattern='.|.|.|hand,equip'},
    card_filter=function(self,player,id,selected)
      return not table.contains(selected,id) and table.contains(U.costs(player,alternate),id)
    end,
    view_as=function(self,player,ids)
      if #ids==0 or not self.interaction.data then return end
      if not table.contains(alternate and {'slash','nullification'} or {'nullification'},self.interaction.data) then return end
      local card=Fk:cloneCard(self.interaction.data)
      card.skillName=skill.name
      -- These cards are a paid cost, NOT subcards of the virtual card. Preserve
      -- the cost separately so color/suit and movement reasons stay correct.
      card.xi__jiyue_cost={table.unpack(ids)}
      return card
    end,
    enabled_at_play=function(self,player)
      return alternate and player.phase==Player.Play and #U.costs(player,true)>0
    end,
    enabled_at_response=function(self,player,responding)
      return not responding and #U.costs(player,alternate)>0
    end,
    enabled_at_nullification=function(self,player)
      return #U.costs(player,alternate)>0
    end,
    before_use=function(self,player,use)
      local ids=use.card.xi__jiyue_cost or {}
      if #ids==0 or not table.every(ids,function(id)return table.contains(U.costs(player,alternate),id)end) then return skill.name end
      local paid={n=#ids,max=U.threshold(ids),alternate=alternate,skill=skill.name}
      use.extra_data=use.extra_data or {};use.extra_data.xi__jiyue=paid
      if alternate then player.room:recastCard(ids,player,skill.name)
      else player.room:throwCard(ids,skill.name,player,player) end
      if player.dead then return skill.name end
    end,
  })
  if not alternate then
    skill:addEffect(fk.PreCardEffect,{
      global=true,
      can_refresh=function(self,event,target,player,data)
        return data.from==player and data.use and data.use.extra_data and data.use.extra_data.xi__jiyue
      end,
      on_refresh=function(self,event,target,player,data)
        local paid=data.use.extra_data.xi__jiyue
        data.offsetFunc=function(room,effect)
          -- A replacement offset is one payment for this target's effect.
          -- The engine may call offsetFunc again for multiple-Jink modifiers.
          if effect.xi__jiyue_answered then return effect.xi__jiyue_offset end
          effect.xi__jiyue_answered=true
          effect.xi__jiyue_offset=U.offset(room,effect,paid)
          return effect.xi__jiyue_offset
        end
      end,
    })
    skill:addEffect(fk.CardEffectFinished,{
      is_delay_effect=true,
      can_trigger=function(self,event,target,player,data)
        local paid=data.use and data.use.extra_data and data.use.extra_data.xi__jiyue
        return data.from==player and not player.dead and paid and not paid.alternate
          and not data.isCancellOut and not data:isNullified()
          and not data.use.extra_data.xi__jiyue_rewarded
      end,
      on_cost=function(self,event,target,player,data)
        return player.room:askToChoice(player,{
          choices={'xi__jiyue_recover','Cancel'},skill_name=skill.name,prompt='#xi__jiyue-success',
        })=='xi__jiyue_recover'
      end,
      on_use=function(self,event,target,player,data)
        data.use.extra_data.xi__jiyue_rewarded=true
        if player:isWounded() then player.room:recover{who=player,num=1,recoverBy=player,skillName=skill.name} end
        U.change(player,true)
      end,
    })
  end
  return skill
end

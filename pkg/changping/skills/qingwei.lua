local skill=fk.CreateSkill{name="changping__qingwei"}
local used="changping__qingwei_users"
local function eligible(player)
  local done=player:getTableMark(used)
  return table.filter(player.room:getOtherPlayers(player,false),function(p)
    return not table.contains(done,p.id) and not p:isNude()
  end)
end
skill:addEffect(fk.EventPhaseStart,{
  audio_index={1,2},
  can_trigger=function(self,event,target,player,data)
    if not target or target.dead or player.dead or not player:hasSkill(skill.name) then return false end
    if target==player then return player.phase==Player.Start and #eligible(player)>0 end
    return target.phase==Player.Play and not target:isNude()
  end,
  on_cost=function(self,event,target,player,data)
    if target==player then
      return player.room:askToSkillInvoke(player,{skill_name=skill.name,prompt="#changping__qingwei-collect"})
    end
    -- The phase owner, rather than Fan Ju, chooses whether to offer a card use.
    local use=player.room:askToUseVirtualCard(target,{
      name={"changping__sincere_treat","dismantlement"},
      card_filter={cards=target:getCardIds("he"),n=1},
      skill_name=skill.name,cancelable=true,skip=true,
      prompt="#changping__qingwei-offer::"..player.id,
      extra_data={exclusive_targets={player.id},bypass_times=true,extraUse=true},
    })
    if use then event:setCostData(self,{use=use,tos={target}});return true end
  end,
  on_use=function(self,event,target,player,data)
    local room=player.room
    if target==player then
      local list=eligible(player)
      room:sortByAction(list)
      for _,p in ipairs(list) do
        if player.dead then break end
        if not p.dead and not p:isNude() then
          local ids=room:askToCards(p,{min_num=1,max_num=#p:getCardIds("he"),include_equip=true,
            cancelable=false,skill_name=skill.name,prompt="#changping__qingwei-give::"..player.id})
          if #ids>0 then room:moveCardTo(ids,Card.PlayerHand,player,fk.ReasonGive,skill.name,nil,false,p) end
        end
      end
      return
    end
    local use=event:getCostData(self).use
    local ids=Card:getIdList(use.card)
    if player.dead or target.dead or #ids~=1 or room:getCardOwner(ids[1])~=target then return end
    local done=player:getTableMark(used)
    table.insertIfNeed(done,target.id)
    room:setPlayerMark(player,used,done)
    -- A prospective reversal must be legal; all distance and prohibition rules apply.
    local reverse=player:canUseTo(use.card,target,{bypass_times=true,extraUse=true})
      and room:askToSkillInvoke(player,{skill_name=skill.name,prompt="#changping__qingwei-reverse::"..target.id})
    if not reverse then room:useCard(use);return end
    -- Reserve the SAME physical card before damage. Enyuan can now resolve without
    -- accidentally taking this card out of the phase owner's hand as its payment.
    room:moveCardTo(ids,Card.Processing,nil,fk.ReasonUse,skill.name,nil,true,target)
    if room:getCardArea(ids[1])~=Card.Processing then return end
    if not player.dead and not target.dead then
      room:damage{from=target,to=player,damage=1,skillName=skill.name}
    end
    if not player.dead and not target.dead and room:getCardArea(ids[1])==Card.Processing
      and player:canUseTo(use.card,target,{bypass_times=true,extraUse=true}) then
      use.from=player
      use.tos={target}
      use.extraUse=true
      room:useCard(use)
    end
    if room:getCardArea(ids[1])==Card.Processing then
      room:moveCardTo(ids,Card.DiscardPile,nil,fk.ReasonPutIntoDiscardPile,skill.name)
    end
  end,
})
skill:addEffect(fk.GameFinished,{
  global=true,
  can_refresh=function(self,event,target,player,data)
    return (player.general=="changping__fanju" or player.deputyGeneral=="changping__fanju")
      and table.contains(data.players or {},player)
      and player:getMark("changping__fanju_victory_voice")==0
  end,
  on_refresh=function(self,event,target,player,data)
    player.room:setPlayerMark(player,"changping__fanju_victory_voice",1)
    player.room:broadcastPlaySound("./packages/meng_family/audio/win/changping__fanju")
  end,
})
Fk:loadTranslationTable{
  ["$changping__qingwei1"]="君既推心相待，范某岂敢不报？",
  ["$changping__qingwei2"]="君以利刃相赠，吾当原物奉还！",
  ["!changping__fanju"]="远交以安诸国，近攻以拓秦疆。臣为王谋者，岂止一时之胜！",
  ["~changping__fanju"]="恩仇皆偿……唯负秦王知遇……",
  ["changping__qingwei"]="倾危",
  [":changping__qingwei"]="其他角色的出牌阶段开始时，其可将一张牌当【推心置腹】或【过河拆桥】对你使用。然后你可受到其造成的1点伤害，改为视为对其使用之。准备阶段，你可令未对你发动过首句效果的角色各交给你至少一张牌。",
  ["#changping__qingwei-offer"]="倾危：你可将一张牌当推心置腹或过河拆桥对 %dest 使用",
  ["#changping__qingwei-reverse"]="倾危：是否受到 %dest 造成的1点伤害，改为你使用同一张牌对其结算？",
  ["#changping__qingwei-collect"]="倾危：令本局未对你发动过首句效果的其他角色各交给你至少一张牌？",
  ["#changping__qingwei-give"]="倾危：交给 %dest 至少一张牌（可多选）",
}
return skill

-- Both variants share one rules implementation. The second skeleton really has
-- the Compulsory tag: no global tag mutation and no effect on another Fan Ju.
return function(locked)
  local base, modified = "changping__yazi", "changping__yazi_locked"
  local name = locked and modified or base
  local skill = fk.CreateSkill { name=name, related_skills=not locked and {modified} or nil, tags=locked and {Skill.Switch, Skill.Compulsory} or {Skill.Switch} }
  local function enabled(player)
    return not player.dead and player:hasSkill(name)
  end
  local function activeEffect(player, index)
    local active = player:hasSkill(modified) and modified or base
    return Fk.skill_skels[active].effects[index]
  end
  local function sources(player, data)
    local counts, result = {}, {}
    for _, move in ipairs(data) do
      if move.from and move.from ~= player and move.to == player and move.toArea == Card.PlayerHand then
        counts[move.from] = (counts[move.from] or 0) + #move.moveInfo
      end
    end
    for p, n in pairs(counts) do
      if n >= 2 and not p.dead then table.insert(result,p) end
    end
    player.room:sortByAction(result)
    return result
  end
  local function cost(self,event,target,player,data)
    if locked or player.room:askToSkillInvoke(player, {skill_name=name,
      prompt="#changping__yazi-invoke::"..target.id}) then
      event:setCostData(self,{tos={target},state=player:getSwitchSkillState(name)})
      return true
    end
  end
  local function finish(player,state)
    if player.dead then return end
    local room = player.room
    if state == fk.SwitchYang then
      room:askToDiscard(player,{min_num=1,max_num=1,include_equip=true,
        cancelable=false,skill_name=name,prompt="#changping__yazi-discard"})
      if not locked and not player.dead and player:hasSkill(base,true) then
        -- Copy the current state, including any nested conversions during discard.
        local nextState=player:getSwitchSkillState(base)
        room:setPlayerMark(player,"@@changping__yazi_locked",1)
        room:handleAddLoseSkills(player,modified.."|-"..base)
        room:setPlayerMark(player,MarkEnum.SwithSkillPreName..modified,nextState)
      end
    elseif player:isWounded() then
      room:recover{who=player,num=1,recoverBy=player,skillName=name}
    end
  end
  skill:addEffect(fk.AfterCardsMove, {
    audio_index=1,
    can_trigger=function(self,event,target,player,data)
      return enabled(player) and not (data.changping_yazi_done or {})[player.id]
        and #sources(player,data)>0
    end,
    on_trigger=function(self,event,target,player,data)
      data.changping_yazi_done=data.changping_yazi_done or {}
      data.changping_yazi_done[player.id]=true
      for _,p in ipairs(sources(player,data)) do
        if player.dead or not (player:hasSkill(base) or player:hasSkill(modified)) then break end
        if not p.dead then activeEffect(player,1):doCost(event,p,player,data) end
      end
    end,
    on_cost=cost,
    on_use=function(self,event,target,player,data)
      local state=event:getCostData(self).state
      if not target.dead then target:drawCards(1,name) end
      finish(player,state)
    end,
  })
  skill:addEffect(fk.Damaged, {
    audio_index=2,
    can_trigger=function(self,event,target,player,data)
      return target==player and enabled(player) and data.from and not data.from.dead
        and not (data.changping_yazi_damage_done or {})[player.id]
    end,
    on_trigger=function(self,event,target,player,data)
      data.changping_yazi_damage_done=data.changping_yazi_damage_done or {}
      data.changping_yazi_damage_done[player.id]=true
      -- Resolve per point, even if the first point upgrades the skeleton.
      for _=1,data.damage do
        if player.dead or data.from.dead or not (player:hasSkill(base) or player:hasSkill(modified)) then break end
        activeEffect(player,2):doCost(event,data.from,player,data)
      end
    end,
    on_cost=cost,
    on_use=function(self,event,target,player,data)
      local state=event:getCostData(self).state
      local room=player.room
      local ids=room:askToCards(target,{min_num=1,max_num=1,include_equip=false,
        cancelable=true,skill_name=name,prompt="#changping__yazi-give:"..player.id})
      if #ids>0 then
        local heart=Fk:getCardById(ids[1]).suit==Card.Heart
        room:moveCardTo(ids,Card.PlayerHand,player,fk.ReasonGive,name,nil,false,target)
        if not heart and not player.dead then player:drawCards(1,name) end
      else
        room:loseHp(target,1,name)
      end
      finish(player,state)
    end,
  })
  local effect="当你获得一名其他角色至少两张牌后，令其摸一张牌；当你受到1点伤害后，令伤害来源交给你一张手牌或失去1点体力，若交给你的牌不是红桃牌，你摸一张牌。然后，阳：弃置一张牌，将此技能永久修改为锁定技；阴：回复1点体力。"
  Fk:loadTranslationTable{
    ["$"..name.."1"]="昔受一饭之恩，今当千金以报！",
    ["$"..name.."2"]="尔昔辱我于堂下，可曾料有今日？",
    [name]="睚眦",[":"..name]=(locked and "锁定技，转换技，" or "转换技，你可于下述时机发动：")..effect,
    ["@@changping__yazi_locked"]="睚眦·锁定",
    ["#changping__yazi-invoke"]="睚眦：是否对 %dest 发动恩怨，并执行当前转换项？",
    ["#changping__yazi-discard"]="睚眦（阳）：弃置一张牌，此技能永久锁定",
    ["#changping__yazi-give"]="睚眦：交给 %src 一张手牌，否则失去1点体力；非红桃牌令其摸一张牌",
  }
  return skill
end

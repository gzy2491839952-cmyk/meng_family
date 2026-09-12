local skill = fk.CreateSkill {name="daxi__jiaodu"}
local last = "daxi__jiaodu_last_gain"
local stopped = "@@daxi__jiaodu_stopped"

-- Capture the previous recipient BEFORE updating the global gain history.
-- This runs once per move batch, even when no current owner can invoke Jiaodu.
skill:addEffect(fk.AfterCardsMove, {
  audio_index = 0, -- Play only after a recipient accepts the optional draw.
  global=true,
  can_refresh=function(self,event,target,player,data)
    return data.daxi__jiaodu_pairs == nil
  end,
  on_refresh=function(self,event,target,player,data)
    local room=player.room
    local prev=room:getBanner(last)
    local pairs={}
    for _,move in ipairs(data) do
      if move.to and (move.toArea==Card.PlayerHand or move.toArea==Card.PlayerEquip) and table.find(move.moveInfo,function(info)
        return move.from~=move.to or info.fromArea~=move.toArea
      end) then
        -- Jiaodu draws still update gain history, but cannot trigger Jiaodu again.
        if move.moveReason==fk.ReasonDraw and move.skillName~=skill.name and prev then
          table.insert(pairs,{drawer=move.to.id,previous=prev})
        end
        prev=move.to.id
      end
    end
    data.daxi__jiaodu_pairs=pairs
    room:setBanner(last,prev)
  end,
  can_trigger=function(self,event,target,player,data)
    return player:hasSkill(skill.name) and player:getMark(stopped)==0
      and table.find(data.daxi__jiaodu_pairs or {},function(pair)
        local a=player.room:getPlayerById(pair.drawer)
        local b=player.room:getPlayerById(pair.previous)
        return (pair.drawer==player.id or pair.previous==player.id)
          and a and b and not a.dead and not b.dead
      end)
  end,
  on_cost=function() return true end,
  on_use=function(self,event,target,player,data)
    local room=player.room
    local voiced = false
    for _,pair in ipairs(data.daxi__jiaodu_pairs or {}) do
      if not player:hasSkill(skill.name) or player:getMark(stopped)>0 then break end
      local drawer=room:getPlayerById(pair.drawer)
      local previous=room:getPlayerById(pair.previous)
      if (pair.drawer==player.id or pair.previous==player.id)
        and drawer and previous and not drawer.dead and not previous.dead
        and room:askToSkillInvoke(drawer, {
          skill_name=skill.name, prompt="#daxi__jiaodu-draw::"..previous.id,
        }) then
        if not voiced then
          player:broadcastSkillInvoke(skill.name, math.random(2))
          voiced = true
        end
        if drawer==player and previous==player then
          -- Stop BEFORE drawing to prevent immediate recursive self-draws.
          room:setPlayerMark(player,stopped,1)
          room:invalidateSkill(player,skill.name,nil,skill.name)
        end
        previous:drawCards(1,skill.name)
      end
    end
  end,
})
skill:addEffect(fk.HpChanged, {
  global=true,
  can_refresh=function(self,event,target,player,data)
    return target==player and player:getMark(stopped)>0 and data.num~=0
      and player:hasSkill(skill.name,true,true)
  end,
  on_refresh=function(self,event,target,player,data)
    local room=player.room
    room:setPlayerMark(player,stopped,0)
    room:validateSkill(player,skill.name,nil,skill.name)
    player:broadcastSkillInvoke(skill.name, 3)
    local current=room.current
    if current and not current.dead and current:isWounded() then
      room:recover {who=current,num=1,recoverBy=player,skillName=skill.name}
    end
  end,
})
-- Cosmetic victory playback; use the engine winner list, including dead winners.
skill:addEffect(fk.GameFinished, {
  global = true,
  can_refresh = function(self, event, target, player, data)
    return (player.general == "daxi__sunkewang" or player.deputyGeneral == "daxi__sunkewang")
      and table.contains(data.players or {}, player)
      and player:getMark("daxi__sunkewang_victory_voice") == 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "daxi__sunkewang_victory_voice", 1)
    player.room:broadcastPlaySound("./packages/meng_family/audio/win/daxi__sunkewang")
  end,
})
Fk:loadTranslationTable {
  ["$daxi__jiaodu1"] = "同舟未必同心，利合亦可共渡。",
  ["$daxi__jiaodu2"] = "半生功业，岂肯尽付残明？今当北面，另取封侯！",
  ["$daxi__jiaodu3"] = "沉舟尚有回澜日，岂许旁人论废兴！",
  ["~daxi__sunkewang"] = "故人已绝……新主亦不容我……",
  ["!daxi__sunkewang"] = "定国徒有战功，安邦终须孤手！",
  ["daxi__jiaodu"]="狡渡",
  [":daxi__jiaodu"]="一名角色不因此摸牌后，其可以令上一名获得牌的角色摸一张牌，上述两名角色中至少一名需为你。若均为你，则令“狡渡”失效至你下一次体力值变化，且再次生效时，本回合角色回复1点体力。",
  [stopped]="狡渡失效",
  ["#daxi__jiaodu-draw"]="狡渡：是否令上一名获得牌的角色%dest摸一张牌？",
}
return skill

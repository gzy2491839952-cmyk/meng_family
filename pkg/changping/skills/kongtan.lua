local skill=fk.CreateSkill{name="changping__kongtan"}
skill:addEffect(fk.EventPhaseStart,{
  anim_type="offensive",
  can_trigger=function(self,event,target,player,data)
    return target==player and player:hasSkill(skill.name) and (player.phase==Player.Start or player.phase==Player.Finish)
  end,
  on_cost=function(self,event,target,player,data)
    local use=player.room:askToUseVirtualCard(player,{name=Fk:getAllCardNames("b"),skill_name=skill.name,
      cancelable=true,skip=true,prompt="#changping__kongtan-use"})
    if use then event:setCostData(self,{use=use});return true end
  end,
  on_use=function(self,event,target,player,data)
    local room=player.room
    local use=event:getCostData(self).use
    local previous=#room.logic:getEventsOfScope(GameEvent.UseCard,1,function(e)
      return e.data.card.trueName==use.card.trueName
    end,Player.HistoryTurn)>0
    use.extra_data=use.extra_data or {}
    use.extra_data.changping_kongtan_changed={}
    room:useCard(use)
    local ids=use.extra_data.changping_kongtan_changed
    local targets={}
    for _,id in ipairs(ids) do table.insert(targets,room:getPlayerById(id)) end
    room:sortByAction(targets)
    for _,to in ipairs(targets) do
      if player.dead then break end
      if not to.dead and not to:isNude() then
        local cid=room:askToChooseCard(player,{target=to,flag="he",skill_name=skill.name,prompt="#changping__kongtan-discard::"..to.id})
        if cid then room:throwCard({cid},skill.name,to,player) end
      end
    end
    if previous and not player.dead then room:loseHp(player,1,skill.name) end
  end,
})
skill:addEffect(fk.HpChanged,{
  global=true,
  can_refresh=function(self,event,target,player,data)
    return target==player and data.num~=0 and not data.prevented
      and not (data.damageEvent and data.damageEvent.isVirtualDMG)
  end,
  on_refresh=function(self,event,target,player,data)
    -- Include nested effects caused while this particular use is resolving.
    local parent=player.room.logic:getCurrentEvent()
    while parent do
      local useEvent=parent:findParent(GameEvent.UseCard,true)
      if not useEvent then break end
      local ex=useEvent.data.extra_data
      if ex and ex.changping_kongtan_changed then table.insertIfNeed(ex.changping_kongtan_changed,player.id) end
      parent=useEvent.parent
    end
  end,
})
Fk:loadTranslationTable{
  ["changping__kongtan"]="空谈",
  [":changping__kongtan"]="准备阶段或结束阶段，你可以视为使用一张基本牌。然后若有角色体力值因此变化，你弃置其一张牌；若本回合此前有与此牌同名的牌被使用过，你失去1点体力。",
  ["#changping__kongtan-use"]="空谈：你可以视为使用一张基本牌",
  ["#changping__kongtan-discard"]="空谈：弃置%dest的一张牌",
}
Fk:loadTranslationTable{
 ["$changping__kongtan1"]="兵法烂熟于胸，破秦何须久议！",
 ["$changping__kongtan2"]="如此这般，这般如此，尽歼秦军，易如反掌！",
}
skill:addEffect(fk.GameFinished,{
 global=true,
 can_refresh=function(self,event,target,player,data)
  return (player.general=="changping__zhaokuo" or player.deputyGeneral=="changping__zhaokuo")
   and table.contains(data.players or {},player) and player:getMark("changping__zhaokuo_victory_voice")==0
 end,
 on_refresh=function(self,event,target,player,data)
  player.room:setPlayerMark(player,"changping__zhaokuo_victory_voice",1)
  player.room:broadcastPlaySound("./packages/meng_family/audio/win/changping__zhaokuo")
 end,
})
Fk:loadTranslationTable{
 ["!changping__zhaokuo"]="父亲未竟之功，儿当继之！",
 ["~changping__zhaokuo"]="箭尽粮绝……已无退路……",
}
return skill

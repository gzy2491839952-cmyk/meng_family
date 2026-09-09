local skill=fk.CreateSkill{name="changping__yuanfa"}
local disabled="@@changping__yuanfa_disabled"
skill:addEffect(fk.EventPhaseEnd,{
  can_trigger=function(self,event,target,player,data)
    return target and target~=player and target.phase==Player.Play and not target.dead
      and player:hasSkill(skill.name) and player:getMark(disabled)==0 and player:canPindian(target)
  end,
  on_cost=function(self,event,target,player,data)
    if player.room:askToSkillInvoke(player,{skill_name=skill.name,prompt="#changping__yuanfa::"..target.id}) then
      event:setCostData(self,{tos={target},x=player:distanceTo(target)})
      return true
    end
  end,
  on_use=function(self,event,target,player,data)
    local room,x=player.room,event:getCostData(self).x
    local pd={from=player,tos={target},reason=skill.name,results={},changping_yuanfa_x=x}
    room:pindian(pd)
    local result=pd.results[target]
    if not result then return end
    if result.winner==target then
      room:setPlayerMark(player,disabled,1)
      room:invalidateSkill(player,skill.name,nil,skill.name)
    elseif result.winner==player and not player.dead and not target.dead then
      local card=Fk:cloneCard("changping__enemy_at_the_gates")
      card.skillName=skill.name
      if player:canUseTo(card,target,{bypass_times=true}) then
        room:useCard{from=player,tos={target},card=card,extraUse=true,
          extra_data={changping_yuanfa_x=x}}
      end
    end
  end,
})
skill:addEffect(fk.PindianCardsDisplayed,{
  can_refresh=function(self,event,target,player,data)
    return data.from==player and data.reason==skill.name and data.changping_yuanfa_x~=nil
      and not data.changping_yuanfa_adjusted
  end,
  on_refresh=function(self,event,target,player,data)
    data.changping_yuanfa_adjusted=true
    player.room:changePindianNumber(data,player,-data.changping_yuanfa_x,skill.name)
  end,
})
skill:addEffect(fk.TurnStart,{
  global=true,
  can_refresh=function(self,event,target,player,data)
    return target==player and player:getMark(disabled)>0
  end,
  on_refresh=function(self,event,target,player,data)
    player.room:setPlayerMark(player,disabled,0)
    player.room:validateSkill(player,skill.name,nil,skill.name)
  end,
})
Fk:loadTranslationTable{
  ["changping__yuanfa"]="远伐",
  [":changping__yuanfa"]="其他角色出牌阶段结束时，你可以与其拼点且你此次拼点牌点数-X：若你赢，你视为对其使用一张额外亮出X张牌的【兵临城下】（X为你计算与其距离）；若其赢，“远伐”失效至你下回合开始。",
  [disabled]="远伐失效",
  ["#changping__yuanfa"]="远伐：是否与 %dest 拼点？你的拼点牌点数减去你至其的距离",
}
return skill

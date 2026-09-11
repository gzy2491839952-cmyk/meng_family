local skill = fk.CreateSkill {name="weekly__zhuojian"}
local function useRecorded(room, who, id, owner, area)
  if who.dead or not id or room:getCardArea(id)~=area then return false end
  if owner and room:getCardOwner(id)~=owner then return false end
  local use=room:askToUseRealCard(who,{pattern={id},expand_pile={id},skill_name=skill.name,
    cancelable=false,skip=true,extra_data={bypass_times=true,extraUse=true},prompt="#weekly__zhuojian-use"})
  if not use or who.dead or room:getCardArea(id)~=area then return false end
  if owner and room:getCardOwner(id)~=owner then return false end
  use.disresponsiveList=table.simpleClone(room.players)
  room:useCard(use)
  return true
end
skill:addEffect("active",{
 audio_index={1,2},
  anim_type="offensive",card_num=0,target_num=1,max_phase_use_time=1,
  can_use=function(self,player)
    return player.phase==Player.Play and player:usedSkillTimes(skill.name,Player.HistoryPhase)==0
      and player:canUse(Fk:cloneCard("fire_attack"))
  end,
  target_filter=function(self,player,to_select,selected)
    return #selected==0 and to_select~=player and player:canUseTo(Fk:cloneCard("fire_attack"),to_select)
  end,
  on_use=function(self,room,effect)
    local player,to=effect.from,effect.tos[1]
    local hand=player:getCardIds("h")
    if #hand>0 then player:showCards(hand)end
    local card=Fk:cloneCard("fire_attack");card.skillName=skill.name
    if player.dead or to.dead or not player:canUseTo(card,to)then return end
    local use={from=player,tos={to},card=card,extraUse=true,
      extra_data={weekly_zhuojian_records={},weekly_zhuojian=true}}
    room:useCard(use)
    for _,r in ipairs(use.extra_data.weekly_zhuojian_records)do
      if useRecorded(room,player,r.shown,r.to,Card.PlayerHand)then
        if not player.dead then player:drawCards(1,skill.name)end
        if not r.to.dead then r.to:drawCards(1,skill.name)end
      end
      if useRecorded(room,r.to,r.discarded,nil,Card.DiscardPile) and not r.to.dead and r.to:isWounded()then
        room:recover{who=r.to,num=1,recoverBy=r.to,skillName=skill.name}
      end
    end
  end,
})
-- Capture the engine's actual fire-attack choices, rather than guessing from hand/discard history.
skill:addEffect(fk.BeforeCardEffect,{
  global=true,
  can_refresh=function(self,event,target,player,data)
    return data.from==player and data.card.trueName=="fire_attack" and data.extra_data and data.extra_data.weekly_zhuojian
  end,
  on_refresh=function(self,event,target,player,data)
    data.weekly_zhuojian_started=true
    data.extra_data.fire_attack_show=nil
    data.extra_data.fire_attack_discard=nil
  end,
})
skill:addEffect(fk.CardEffectFinished,{
  global=true,
  can_refresh=function(self,event,target,player,data)
    return data.from==player and data.weekly_zhuojian_started and data.extra_data
      and data.extra_data.weekly_zhuojian_records and data.extra_data.fire_attack_show
  end,
  on_refresh=function(self,event,target,player,data)
    table.insert(data.extra_data.weekly_zhuojian_records,{to=data.to,
      shown=data.extra_data.fire_attack_show[1],discarded=(data.extra_data.fire_attack_discard or {})[1]})
    data.weekly_zhuojian_started=nil
  end,
})
Fk:loadTranslationTable{
 ["weekly__zhuojian"]="灼谏",
 [":weekly__zhuojian"]="出牌阶段限一次，你可以展示所有手牌并视为对一名其他角色使用一张【火攻】。结算完成后，你使用其展示牌并与其各摸一张牌，其使用弃置牌并回复1点体力（均不可响应）。<br><font color='gray'>后续使用对应的实体牌；若无法使用，则不执行对应的摸牌或回复。</font>",
 ["#weekly__zhuojian-use"]="灼谏：使用此牌（不可被响应）",
}
return skill

local skill = fk.CreateSkill { name = "changping__qijie" }
local used, pending, shown = "changping__qijie_used-phase", "changping__qijie_pending-phase", "@@changping__qijie-phase"
local function available(player) return player:getMark(used) == 0 end
skill:addEffect("viewas", {
  pattern = "slash,jink",
  audio_index = 0, -- Select the voice from the actual converted card below.
  prompt = "#changping__qijie",
  interaction = function(self, player)
    local names = player:getViewAsCardNames(skill.name, {"slash", "jink"})
    if #names > 0 then return UI.CardNameBox { choices = names, all_choices = {"slash", "jink"} } end
  end,
  card_filter = function() return false end,
  view_as = function(self, player, cards)
    if #cards ~= 0 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = skill.name
    return card
  end,
  enabled_at_play = function(self, player) return available(player) end,
  enabled_at_response = function(self, player) return available(player) end,
  before_use = function(self, player, use)
    player.room:setPlayerMark(player, used, 1)
    if use.card then
      player:broadcastSkillInvoke(skill.name, (use.card.trueName or use.card.name)=="jink" and 2 or 1)
    end
  end,
  after_use = function(self, player, use)
    if player.dead or player:isNude() then return end
    local room = player.room
    local targets = room:getOtherPlayers(player, false)
    if #targets == 0 then return end
    local ids = room:askToCards(player, {
      min_num=1,max_num=1,include_equip=true,cancelable=false,
      skill_name=skill.name,prompt="#changping__qijie-give",
    })
    if #ids == 0 then return end
    local to = room:askToChoosePlayers(player, {
      targets=targets,min_num=1,max_num=1,cancelable=false,
      skill_name=skill.name,prompt="#changping__qijie-target",
    })[1]
    if not to or to.dead then return end
    local id = ids[1]
    room:moveCardTo(id, Card.PlayerHand, to, fk.ReasonGive, skill.name, nil, true, player)
    if room:getCardOwner(id) == to and room:getCardArea(id) == Card.PlayerHand then
      room:setCardMark(Fk:getCardById(id), shown, to.id)
      room:setPlayerMark(player, pending, {id, to.id})
      to:showCards({id})
    end
  end,
})
skill:addEffect("visibility", {
  card_visible = function(self, viewer, card)
    local id = card:getMark(shown)
    if id == 0 then return end
    local room = Fk:currentRoom()
    local owner = room:getCardOwner(card.id)
    if owner and owner.id == id and room:getCardArea(card.id) == Card.PlayerHand then return true end
  end,
})
-- Leaving the recipient's hand ends this card's pending use and visibility.
skill:addEffect(fk.AfterCardsMove, {
  global = true,
  can_refresh = function(self,event,target,player,data)
    local info = player:getMark(pending)
    if type(info) ~= "table" then return false end
    return table.find(data, function(move)
      return move.from and move.from.id == info[2] and table.find(move.moveInfo,function(m)
        return m.cardId == info[1] and m.fromArea == Card.PlayerHand
      end)
    end)
  end,
  on_refresh = function(self,event,target,player,data)
    local info = player:getMark(pending)
    player.room:setCardMark(Fk:getCardById(info[1]),shown,0)
    player.room:setPlayerMark(player,pending,0)
  end,
})
skill:addEffect(fk.EventPhaseEnd, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self,event,target,player,data)
    if player.dead or not target or target.dead or target == player then return false end
    local info = player:getMark(pending)
    if type(info) ~= "table" then return false end
    local room = player.room
    local owner = room:getCardOwner(info[1])
    if not owner or owner.id ~= info[2] or room:getCardArea(info[1]) ~= Card.PlayerHand then return false end
    local dealt = room.logic:getEventsOfScope(GameEvent.Damage,1,function(e)
      return e.data.from == target and (e.data.damage or 0)>0 and e.data.dealtRecorderId ~= nil
    end,Player.HistoryPhase)
    return #dealt == 0
  end,
  on_cost = function() return true end,
  on_use = function(self,event,target,player,data)
    local room = player.room
    local info = player:getMark(pending)
    room:setPlayerMark(player,pending,0)
    local use = room:askToUseVirtualCard(player, {
      name="slash",subcards={info[1]},skill_name=skill.name,cancelable=true,skip=true,
      prompt="#changping__qijie-slash::"..target.id,
      extra_data={exclusive_targets={target.id},bypass_times=true,extraUse=true},
    })
    if use then
      player:broadcastSkillInvoke(skill.name, 1)
      room:useCard(use)
    end
    room:setCardMark(Fk:getCardById(info[1]),shown,0)
  end,
})
Fk:loadTranslationTable {
  ["$changping__qijie1"]="纵有重关百仞，吾亦长驱而入！",
  ["$changping__qijie2"]="示敌以正，出奇制胜。",
  ["changping__qijie"]="奇截",
  [":changping__qijie"]="每阶段限一次，你可以视为使用或打出【杀】或【闪】，然后交给一名其他角色一张牌并明置之。此阶段结束时，若当前回合角色此阶段未造成过伤害，你可以将此牌当【杀】对其使用。",
  ["#changping__qijie"]="奇截：视为使用或打出杀或闪，结算后交给其他角色一张牌并明置",
  ["#changping__qijie-give"]="奇截：选择一张手牌或装备牌交给其他角色",
  ["#changping__qijie-target"]="奇截：选择获得此牌的角色",
  ["#changping__qijie-slash"]="奇截：你可以将明置牌当杀对 %dest 使用",
  [shown]="奇截明置",
}
return skill

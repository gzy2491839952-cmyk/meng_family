local skill = fk.CreateSkill { name = "meng__lanzheng" }
local used = "meng__lanzheng_used-turn"
local pending = "@meng__lanzheng-round"

-- Count actual cards in the completed move batch, not attempted draws/discards.
local function counts(player, data)
  local draw, discard = 0, 0
  for _, move in ipairs(data) do
    if move.to == player and move.toArea == Card.PlayerHand and move.moveReason == fk.ReasonDraw then
      draw = draw + #move.moveInfo
    end
    if move.from == player and move.moveReason == fk.ReasonDiscard then
      discard = discard + #move.moveInfo
    end
  end
  return draw, discard
end

skill:addEffect(fk.AfterCardsMove, {
  audio_index={1,2},
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skill.name) or player:getMark(used) > 0 then return false end
    local draw, discard = counts(player, data)
    return (draw > 0 or discard > 0) and #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local draw, discard = counts(player, data)
    local action = draw > 0 and "meng__lanzheng_draw" or "meng__lanzheng_discard"
    if draw > 0 and discard > 0 then
      action = room:askToChoice(player, {
        choices = { "meng__lanzheng_draw", "meng__lanzheng_discard", "Cancel" },
        skill_name = skill.name,
      })
      if action == "Cancel" then return false end
    end
    local n = action == "meng__lanzheng_draw" and draw or discard
    local tos = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player, false), min_num = 1, max_num = 1,
      skill_name = skill.name, cancelable = true,
      prompt = (action == "meng__lanzheng_draw" and "#meng__lanzheng-draw:::" or "#meng__lanzheng-discard:::") .. n,
    })
    if #tos > 0 then
      event:setCostData(self, { tos = tos, action = action, n = n })
      return true
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cost = event:getCostData(self)
    room:setPlayerMark(player, used, 1)
    local to = cost.tos[1]
    if not to.dead then
      if cost.action == "meng__lanzheng_draw" then
        to:drawCards(cost.n, skill.name)
      else
        room:askToDiscard(to, {
          min_num = cost.n, max_num = cost.n, include_equip = true,
          skill_name = skill.name, cancelable = false,
        })
      end
    end
    -- Evaluate after the copied action and its nested effects have resolved.
    local alive = room:getAlivePlayers()
    local most = -1
    for _, p in ipairs(alive) do most = math.max(most, p:getHandcardNum()) end
    for _, p in ipairs(alive) do
      -- Union: the owner who is also tied for most cards gains only one mark.
      if p == player or p:getHandcardNum() == most then room:addPlayerMark(p, pending, 1) end
    end
  end,
})

-- The delayed effect remains valid after Hu Hai loses the skill or dies.
skill:addEffect(fk.DamageInflicted, {
  global = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark(pending) > 0 and data.damage > 0
  end,
  on_cost = function() return true end,
  on_use = function(self, event, target, player, data)
    local n = player:getMark(pending)
    player.room:setPlayerMark(player, pending, 0)
    data:changeDamage(n)
  end,
})

skill:addEffect(fk.GameFinished, {
  global=true,
  can_refresh=function(self,event,target,player,data)
    return (player.general=="meng__huhai" or player.deputyGeneral=="meng__huhai")
      and table.contains(data.players or {},player)
      and player:getMark("meng__huhai_victory_voice")==0
  end,
  on_refresh=function(self,event,target,player,data)
    player.room:setPlayerMark(player,"meng__huhai_victory_voice",1)
    player.room:broadcastPlaySound("./packages/meng_family/audio/win/meng__huhai")
  end,
})
Fk:loadTranslationTable {
  ["!meng__huhai"]="什么乱臣贼子，不过扰了朕几日清闲！",
  ["~meng__huhai"]="帝位不要了……只求做个黔首……也不成么……",
  ["$meng__lanzheng1"]="丞相通晓律令，赵高深知朕意，天下之事，付与二卿足矣！",
  ["$meng__lanzheng2"]="朕养百官，难道还须事事亲问？！",

  ["meng__lanzheng"] = "滥政",
  [":meng__lanzheng"] = "每回合限一次，当你摸或弃任意牌时，你可以令一名其他角色亦执行之，然后你与手牌数最多的角色本轮下次受到的伤害+1。",
  ["meng__lanzheng_draw"] = "令其他角色摸等量的牌",
  ["meng__lanzheng_discard"] = "令其他角色弃等量的牌",
  ["#meng__lanzheng-draw"] = "滥政：你可以令一名其他角色摸%arg张牌",
  ["#meng__lanzheng-discard"] = "滥政：你可以令一名其他角色弃%arg张牌",
  [pending] = "滥政增伤",
}
return skill

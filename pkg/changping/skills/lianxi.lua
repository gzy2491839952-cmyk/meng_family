local central = require "packages.meng_family.pkg.changping.central"
local skill = fk.CreateSkill { name = "changping__lianxi", tags = { Skill.Compulsory } }
skill:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  audio_index = {1, 2},
  can_trigger = function(self, event, target, player, data)
    return target == player and not player.dead and player:hasSkill(skill.name)
  end,
  on_cost = function(self, event, target, player, data)
    -- Both predicates are fixed before drawing/discarding changes any areas.
    event:setCostData(self, central.conditions(player, data.card))
    return true
  end,
  on_use = function(self, event, target, player, data)
    local cost = event:getCostData(self)
    if cost.sameSuit then
      data.disresponsiveList = data.disresponsiveList or {}
      for _, p in ipairs(player.room.players) do
        table.insertIfNeed(data.disresponsiveList, p)
      end
    end
    if cost.lowHand then player:drawCards(1, skill.name) end
    if cost.sameSuit and cost.lowHand then
      data.additionalDamage = (data.additionalDamage or 0) + 1
    elseif not player.dead then
      player.room:askToDiscard(player, {
        min_num = 1, max_num = 1, include_equip = true, cancelable = false,
        skill_name = skill.name, prompt = "#changping__lianxi-discard",
      })
    end
  end,
})
-- Cosmetic victory playback, once for each Wang He listed among the winners.
skill:addEffect(fk.GameFinished, {
  global = true,
  can_refresh = function(self, event, target, player, data)
    return (player.general == "changping__wanghe" or player.deputyGeneral == "changping__wanghe")
      and table.contains(data.players or {}, player)
      and player:getMark("changping__wanghe_victory_voice") == 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "changping__wanghe_victory_voice", 1)
    player.room:broadcastPlaySound("./packages/meng_family/audio/win/changping__wanghe")
  end,
})
Fk:loadTranslationTable {
  ["$changping__lianxi1"] = "一垒何足拦我！一胜岂可收兵！",
  ["$changping__lianxi2"] = "奉王命，叩长平，赵军壁垒，吾当先破！",
  ["~changping__wanghe"] = "来时同袍满伍……如今……独留我一人……",
  ["!changping__wanghe"] = "赵垒已破，前路已开，当乘此胜势，再进长平！",
  ["changping__lianxi"] = "连袭",
  [":changping__lianxi"] = "锁定技，当你使用牌时，若中央区含有相同花色的牌，则此牌不可被响应；若你手牌数不大于中央区牌数，则你摸一张牌。若两项均满足，则此牌伤害+1；否则，你弃置一张牌。<br><font color='gray'>中央区：本回合进入弃牌堆且当前仍在弃牌堆中的牌（不含处理区）。两项条件在本技能结算前同时判定。</font>",
  ["#changping__lianxi-discard"] = "连袭：两项条件未同时满足，你须弃置一张手牌或装备牌",
}
return skill

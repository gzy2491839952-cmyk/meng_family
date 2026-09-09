local skill = fk.CreateSkill {name="meng__renjian"}
local used = "meng__renjian_used-turn"
local function slashes(player)
  return table.filter(player:getCardIds("h"), function(id)
    return Fk:getCardById(id).trueName=="slash" and not player:prohibitDiscard(id)
  end)
end
skill:addEffect("active", {
  anim_type="support",
  max_phase_use_time=2,
  card_num=0,
  target_num=0,
  prompt="#meng__renjian",
  can_use=function(self,player)
    return player.phase==Player.Play and player:usedSkillTimes(skill.name,Player.HistoryPhase)<2
  end,
  on_use=function(self,room,effect)
    local player=effect.from
    room:addPlayerMark(player,used,1)
    local choice=room:askToChoice(player, {
      skill_name=skill.name,
      choices={"meng__renjian_discard","meng__renjian_draw"},
      prompt="#meng__renjian-choice",
    })
    local selected=room:askToChoosePlayers(player, {
      targets=room.alive_players,min_num=1,max_num=1,cancelable=false,
      skill_name=skill.name,
      prompt=choice=="meng__renjian_discard" and "#meng__renjian-target-discard" or "#meng__renjian-target-draw",
    })
    local to=selected[1]
    if not to or to.dead then return end
    if choice=="meng__renjian_discard" then
      local ids=slashes(to)
      if #ids==0 then return end
      room:askToDiscard(to, {
        min_num=1,max_num=1,include_equip=false,cancelable=false,
        pattern=tostring(Exppattern{id=ids}),skill_name=skill.name,prompt="#meng__renjian-discard",
      })
    else
      to:drawCards(1,skill.name)
    end
  end,
})
skill:addEffect(fk.EventPhaseStart, {
  mute=true,
  is_delay_effect=true,
  can_trigger=function(self,event,target,player,data)
    return target==player and player:hasSkill(skill.name) and player.phase==Player.Finish
      and 2-player:getMark(used)~=1
  end,
  on_cost=function() return true end,
  on_use=function(self,event,target,player,data)
    player.room:loseHp(player,1,skill.name)
  end,
})
Fk:loadTranslationTable {
  ["meng__renjian"]="仁谏",
  [":meng__renjian"]="出牌阶段限两次，你可以令一名角色弃置一张【杀】或摸一张牌；结束阶段，若你本回合此技能的剩余可发动次数不为一，你失去1点体力值。",
  ["#meng__renjian"]="仁谏：先选择弃置【杀】或摸牌，再选择执行的角色（出牌阶段限两次）",
  ["#meng__renjian-choice"]="仁谏：先选择要执行的效果，再选择一名角色",
  ["#meng__renjian-target-discard"]="仁谏：选择一名角色，令其弃置一张【杀】",
  ["#meng__renjian-target-draw"]="仁谏：选择一名角色，令其摸一张牌",
  ["#meng__renjian-discard"]="仁谏：请选择一张手牌【杀】弃置",
  ["meng__renjian_draw"]="令其摸一张牌",
  ["meng__renjian_discard"]="令其弃置一张【杀】",
}
return skill

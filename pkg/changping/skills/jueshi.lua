local skill=fk.CreateSkill{name="changping__jueshi",tags={Skill.Lord}}
local function payable(player)
  local ids=player:getCardIds("h")
  return #ids>0 and not table.find(ids,function(id)return player:prohibitDiscard(id) end)
end
skill:addEffect(fk.CardUsing,{
  audio_index={1,2},
  can_trigger=function(self,event,target,player,data)
    return target and not player.dead and player:hasSkill(skill.name)
      and player.room.current~=player and data.card.trueName=="slash" and payable(player)
  end,
  on_cost=function(self,event,target,player,data)
    if not player.room:askToSkillInvoke(player,{skill_name=skill.name,prompt="#changping__jueshi::"..target.id}) then return false end
    local choices={"changping__jueshi_unresponsive","changping__jueshi_damage"}
    if target.kingdom=="meng_qin" or target.kingdom=="qin" then table.insert(choices,"changping__jueshi_both") end
    local choice=player.room:askToChoice(player,{choices=choices,skill_name=skill.name})
    event:setCostData(self,{choice=choice})
    return true
  end,
  on_use=function(self,event,target,player,data)
    if not payable(player) then return end
    local choice=event:getCostData(self).choice
    player.room:throwCard(player:getCardIds("h"),skill.name,player,player)
    if choice~="changping__jueshi_damage" then
      data.disresponsiveList=data.disresponsiveList or {}
      for _,p in ipairs(player.room.players) do table.insertIfNeed(data.disresponsiveList,p) end
    end
    if choice~="changping__jueshi_unresponsive" then data.additionalDamage=(data.additionalDamage or 0)+1 end
  end,
})
Fk:loadTranslationTable{
  ["$changping__jueshi1"]="此战所系，乃大秦国运！",
  ["$changping__jueshi2"]="秦人之剑，既已出鞘，岂容空还！",
  ["changping__jueshi"]="决势",
  [":changping__jueshi"]="主公技，你的回合外，当一名角色使用【杀】时，你可以弃置所有手牌并选择一项：1.此【杀】不能被响应；2.此【杀】伤害+1。背水：该角色为秦势力角色。",
  ["#changping__jueshi"]="决势：是否弃置所有手牌，强化 %dest 使用的杀？",
  ["changping__jueshi_unresponsive"]="此杀不能被响应",
  ["changping__jueshi_damage"]="此杀伤害+1",
  ["changping__jueshi_both"]="背水：此杀不能被响应且伤害+1",
}
return skill

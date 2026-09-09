local central=require "packages.meng_family.pkg.changping.central"
local skill=fk.CreateSkill{name="changping__tunshi"}
local used="changping__tunshi_used-turn"
local function missing(player)
  local seen,buckets={},{}
  for _,id in ipairs(player:getCardIds("h")) do seen[Fk:getCardById(id).suit]=true end
  for _,suit in ipairs{Card.Spade,Card.Heart,Card.Club,Card.Diamond} do
    if not seen[suit] then buckets[suit]={} end
  end
  for _,id in ipairs(central.cards(player.room)) do
    local bucket=buckets[Fk:getCardById(id).suit]
    if bucket then table.insert(bucket,id) end
  end
  return buckets
end
skill:addEffect(fk.EnterDying,{
  can_trigger=function(self,event,target,player,data)
    return not player.dead and player:hasSkill(skill.name) and player:getMark(used)==0
  end,
  on_use=function(self,event,target,player,data)
    local room=player.room
    room:setPlayerMark(player,used,1)
    local hand=player:getCardIds("h")
    if #hand>0 then player:showCards(hand) end
    if player.dead then return end
    local buckets=missing(player)
    local chosen={}
    for _,suit in ipairs{Card.Spade,Card.Heart,Card.Club,Card.Diamond} do
      local ids=buckets[suit] or {}
      if #ids>0 then
        local id=ids[1]
        if #ids>1 then
          room:fillAG(player,ids)
          id=room:askToAG(player,{id_list=ids,cancelable=false,skill_name=skill.name})
          room:closeAG(player)
        end
        if id and room:getCardArea(id)==Card.DiscardPile then table.insert(chosen,id) end
      end
    end
    if #chosen>0 and not player.dead then room:obtainCard(player,chosen,true,fk.ReasonPrey,player,skill.name) end
  end,
})
Fk:loadTranslationTable{
  ["changping__tunshi"]="吞世",
  [":changping__tunshi"]="每回合限一次，当一名角色进入濒死状态时，你可以展示所有手牌并获得中央区手牌中缺失的花色的牌各一张，若你没有手牌，则无须展示手牌。",
}
return skill

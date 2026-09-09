local skill=fk.CreateSkill{name="changping__enemy_at_the_gates_skill"}
skill:addEffect("cardskill",{
  target_num=1,
  mod_target_filter=function(self,player,to)return player~=to end,
  target_filter=Util.CardTargetFilter,
  on_effect=function(self,room,effect)
    local from,to=effect.from,effect.to
    if from.dead or to.dead then return end
    local n=4+((effect.extra_data or {}).changping_yuanfa_x or 0)
    local ids=room:getNCards(n)
    if #ids==0 then return end
    room:moveCardTo(ids,Card.Processing,nil,fk.ReasonJustMove,skill.name,nil,true,from)
    room:fillAG(room.players,ids)
    -- Use the real Slashes in reveal order. These mandated uses ignore range
    -- and per-phase count, but still respect use and target prohibitions.
    for _,id in ipairs(ids) do
      if from.dead or to.dead then break end
      if room:getCardArea(id)==Card.Processing then
        local card=Fk:getCardById(id)
        if card.trueName=="slash" and from:canUseTo(card,to,{bypass_times=true,bypass_distances=true}) then
          room:useCard{from=from,tos={to},card=card,extraUse=true}
        end
      end
    end
    for _,p in ipairs(room.players) do room:closeAG(p) end
    local left=table.filter(ids,function(id)return room:getCardArea(id)==Card.Processing end)
    if #left>0 then room:moveCardTo(left,Card.DiscardPile,nil,fk.ReasonPutIntoDiscardPile,skill.name) end
  end,
})
Fk:loadTranslationTable{
  ["changping__enemy_at_the_gates"]="兵临城下",
  ["changping__enemy_at_the_gates_skill"]="兵临城下",
  [":changping__enemy_at_the_gates"]="锦囊牌。出牌阶段，对一名其他角色使用。你亮出牌堆顶四张牌，然后依次对目标角色使用其中的【杀】。",
}
return skill

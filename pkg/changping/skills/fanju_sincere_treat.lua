-- Skill-only card definition; no physical copy is inserted into the draw pile.
-- Rule reference: https://www.sanguosha.cn/pc/news-detail-882.html
local skill=fk.CreateSkill{name="changping__sincere_treat_skill"}
skill:addEffect("cardskill",{
  target_num=1,distance_limit=1,
  mod_target_filter=function(self,player,to,selected,card,extra)
    return to~=player and not to:isAllNude() and
      ((extra and extra.bypass_distances) or self:withinDistanceLimit(player,false,card,to))
  end,
  target_filter=Util.CardTargetFilter,
  on_effect=function(self,room,effect)
    local from,to=effect.from,effect.to
    if from.dead or to.dead or to:isAllNude() then return end
    local ids=room:askToChooseCards(from,{target=to,flag="hej",min=1,max=2,
      skill_name=skill.name,cancelable=false})
    if #ids==0 then return end
    room:obtainCard(from,ids,false,fk.ReasonPrey,from,skill.name)
    if from.dead or to.dead or from:isKongcheng() then return end
    local n=math.min(#ids,from:getHandcardNum())
    local give=room:askToCards(from,{min_num=n,max_num=n,include_equip=false,
      skill_name=skill.name,cancelable=false,prompt="#changping__sincere-return::"..to.id..":"..n})
    if #give>0 then room:moveCardTo(give,Card.PlayerHand,to,fk.ReasonGive,skill.name,nil,false,from) end
  end,
})
Fk:loadTranslationTable{
  ["changping__sincere_treat"]="推心置腹",
  ["changping__sincere_treat_skill"]="推心置腹",
  [":changping__sincere_treat"]="锦囊牌。对距离为1的一名其他角色使用，获得其区域里的至多两张牌，然后交给其等量的手牌。",
  ["#changping__sincere-return"]="推心置腹：交给 %dest %arg 张手牌",
}
return skill

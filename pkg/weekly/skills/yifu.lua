local M=require "packages.meng_family.pkg.weekly.zhaoyong"
local skill=fk.CreateSkill{name=M.name}
for _,timing in ipairs{fk.TargetSpecified,fk.TargetConfirmed}do
 skill:addEffect(timing,{
  can_trigger=function(self,event,target,player,data)
   return target==player and player:hasSkill(skill.name) and data.card.is_damage_card and #M.basics(player)>0
  end,
  on_cost=function(self,event,target,player,data)
   local ids=M.basics(player)
   local selected=player.room:askToCards(player,{min_num=1,max_num=#ids,include_equip=false,
    pattern=tostring(Exppattern{id=ids}),skill_name=skill.name,cancelable=true,prompt="#weekly__yifu-place"})
   if #selected>0 then event:setCostData(self,{cards=selected});return true end
  end,
  on_use=function(self,event,target,player,data)
   local room=player.room
   for _,id in ipairs(event:getCostData(self).cards)do
    if player.dead then break end
    if table.contains(player:getCardIds("h"),id)then
     local slots=M.slotsFor(player,id)
     if #slots>0 then
      local choices=table.map(slots,function(s)return "weekly_yifu_slot"..s end)
      local choice=room:askToChoice(player,{choices=choices,skill_name=skill.name,prompt="#weekly__yifu-slot"})
      local subtype=tonumber(choice:match("(%d+)$"))
      room:moveCardIntoEquip(player,M.equip(id,subtype),skill.name,true,player)
     end
    end
   end
  end,
 })
end
skill:addEffect(fk.TurnEnd,{
 can_trigger=function(self,event,target,player,data)return player:hasSkill(skill.name) and #M.slashes(player)>0 end,
 on_cost=function(self,event,target,player,data)
  return player.room:askToSkillInvoke(player,{skill_name=skill.name,prompt="#weekly__yifu-retrieve"})
 end,
 on_use=function(self,event,target,player,data)
  local room=player.room;local pending=M.slashes(player)
  room:moveCardTo(pending,Card.Processing,nil,fk.ReasonJustMove,skill.name,nil,true,player)
  while not player.dead do
   pending=table.filter(pending,function(id)return room:getCardArea(id)==Card.Processing end)
   if #pending==0 then break end
   local use=room:askToUseRealCard(player,{pattern=pending,expand_pile=pending,skill_name=skill.name,cancelable=false,skip=true,
    extra_data={bypass_distances=true,bypass_times=true,extraUse=true},prompt="#weekly__yifu-use"})
   if not use then break end
   for _,id in ipairs(Card:getIdList(use.card))do table.removeOne(pending,id)end
   room:useCard(use)
  end
  local rest=table.filter(pending,function(id)return room:getCardArea(id)==Card.Processing end)
  if #rest>0 then room:moveCardTo(rest,Card.DiscardPile,nil,fk.ReasonPutIntoDiscardPile,skill.name)end
 end,
})
Fk:loadTranslationTable{
 ["weekly__yifu"]="易服",
 [":weekly__yifu"]="当你指定或被指定为伤害牌目标时，你可以将手牌中任意张基本牌依次置入任意装备栏；一个回合结束时，你可以移去中央区中你不因使用而进入的【杀】并依次使用（无距离限制）。",
 ["#weekly__yifu-place"]="易服：选择基本牌，依次放入装备栏",
 ["#weekly__yifu-slot"]="易服：选择装备栏（替换原装备，无装备效果）",
 ["#weekly__yifu-retrieve"]="易服：取出中央区中自己的、非因使用进入的杀，然后依次使用？",
 ["#weekly__yifu-use"]="易服：依次使用取回的杀（无距离限制）",
}
local names={"武器栏","防具栏","防御坐骑栏","进攻坐骑栏","宝物栏"}
for i,s in ipairs(M.slots)do
 Fk:loadTranslationTable{["weekly_yifu_slot"..s]=names[i],["weekly__yifu_slot"..s]="易服·"..names[i],
 [":weekly__yifu_slot"..s]="易服置入的基本牌：占据"..names[i].."，无装备效果。"}
end
return skill

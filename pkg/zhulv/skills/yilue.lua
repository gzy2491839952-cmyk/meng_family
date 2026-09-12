local skill=fk.CreateSkill{name="zhulv__yilue"}
local function options(a,b)
 local choices={}
 if not a or not b or a==b or a.dead or b.dead then return choices end
 if not a:isKongcheng() then table.insert(choices,"zhulv_yilue_forward_h")end
 if not b:isKongcheng() then table.insert(choices,"zhulv_yilue_reverse_h")end
 if table.find(a:getCardIds("ej"),function(id)return a:canMoveCardInBoardTo(b,id)end)then table.insert(choices,"zhulv_yilue_forward_board")end
 if table.find(b:getCardIds("ej"),function(id)return b:canMoveCardInBoardTo(a,id)end)then table.insert(choices,"zhulv_yilue_reverse_board")end
 return choices
end
local spec={
 can_trigger=function(self,event,target,player,data)
  if target~=player or not player:hasSkill(skill.name) or player:usedSkillTimes(skill.name,Player.HistoryTurn)>0 then return false end
  if data.card.type~=Card.TypeBasic and not data.card:isCommonTrick()then return false end
  local tos=data:getAllTargets()
  return #tos==1 and #options(data.from,tos[1])>0
 end,
 on_cost=function(self,event,target,player,data)
  local c=player.room:askToChoice(player,{choices=table.connect(options(data.from,data:getAllTargets()[1]),{"Cancel"}),skill_name=skill.name,prompt="#zhulv__yilue-move"})
  if c~="Cancel"then event:setCostData(self,c);return true end
 end,
 on_use=function(self,event,target,player,data)
  local room=player.room;local c=event:getCostData(self)
  local a,b=data.from,data:getAllTargets()[1]
  if c:find("reverse")then a,b=b,a end
  if not a or not b or a.dead or b.dead then return end
  local moved=false
  if c:sub(-1)=="h"then
   if a:isKongcheng()then return end
   local id=room:askToChooseCard(player,{target=a,flag="h",skill_name=skill.name})
   if room:getCardOwner(id)==a and room:getCardArea(id)==Card.PlayerHand then
    room:moveCardTo(id,Card.PlayerHand,b,fk.ReasonPrey,skill.name,nil,false,player)
    moved=true
   end
  else
   if not table.find(a:getCardIds("ej"),function(id)return a:canMoveCardInBoardTo(b,id)end)then return end
   moved=room:askToMoveCardInBoard(player,{target_one=a,target_two=b,move_from=a,skill_name=skill.name})~=nil
  end
  if not moved or a.dead then return end
  local choice=room:askToChoice(a,{choices={"zhulv_yilue_cancel","zhulv_yilue_repeat","Cancel"},skill_name=skill.name,prompt="#zhulv__yilue-result"})
  if choice=="zhulv_yilue_cancel"then
   data.extra_data=data.extra_data or {};data.use.extra_data=data.extra_data;data.extra_data.zhulv_yilue_nullified=true
   data.use.nullifiedTargets=table.simpleClone(room.players)
  elseif choice=="zhulv_yilue_repeat"then data.use.additionalEffect=(data.use.additionalEffect or 0)+1 end
 end,
}
skill:addEffect(fk.TargetSpecified,spec)
skill:addEffect(fk.TargetConfirmed,spec)
skill:addEffect(fk.PreCardEffect,{
 global=true,
 can_refresh=function(self,event,target,player,data)return data.from==player and data.extra_data and data.extra_data.zhulv_yilue_nullified end,
 on_refresh=function(self,event,target,player,data)data.nullified=true end,
})
Fk:loadTranslationTable{
 ["zhulv__yilue"]="移略",
 [":zhulv__yilue"]="每回合限一次，你指定或成为基本牌或普通锦囊牌的唯一目标后，你可以将使用者或目标区域内一张牌置入对方的相同区域，因此失去牌的角色可以令此牌无效或额外结算一次。",
 ["#zhulv__yilue-move"]="移略：选择移动方向与区域",
 ["zhulv_yilue_forward_h"]="使用者的手牌 → 目标的手牌区",
 ["zhulv_yilue_reverse_h"]="目标的手牌 → 使用者的手牌区",
 ["zhulv_yilue_forward_board"]="使用者的装备/判定牌 → 目标的相同区域",
 ["zhulv_yilue_reverse_board"]="目标的装备/判定牌 → 使用者的相同区域",
 ["#zhulv__yilue-result"]="移略：你可以令当前使用的牌无效或额外结算一次",
 ["zhulv_yilue_cancel"]="令此牌无效",["zhulv_yilue_repeat"]="令此牌额外结算一次",
}
return skill

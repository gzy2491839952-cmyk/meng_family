local M=require("packages.meng_family.pkg.weekly.gaojianli")
local skill=M.build(false)
skill:addEffect(fk.GameStart,{
 can_refresh=function(self,event,target,player,data)return player:hasSkill(M.name)end,
 on_refresh=function(self,event,target,player,data)player.room:setPlayerMark(player,M.state,"平")end,
})
skill:addEffect(fk.AfterCardsMove,{
 can_refresh=function(self,event,target,player,data)
  if not player:hasSkill(M.name)or M.isRevised(player)then return false end
  return table.find(data,function(move)
   return move.from==player and table.find(move.moveInfo,function(info)
    return (info.fromArea==Card.PlayerHand or info.fromArea==Card.PlayerEquip)
     and Fk:getCardById(info.cardId).color==Card.Black
   end)
  end)~=nil
 end,
 on_refresh=function(self,event,target,player,data)
  local ids={}
  for _,move in ipairs(data)do if move.from==player then
   for _,info in ipairs(move.moveInfo)do
    if (info.fromArea==Card.PlayerHand or info.fromArea==Card.PlayerEquip)
     and Fk:getCardById(info.cardId).color==Card.Black then table.insertIfNeed(ids,info.cardId)end
   end
  end end
  local room=player.room
  if #ids%2==1 then
   local state=player:getSwitchSkillState(M.name,true)
   room:setPlayerMark(player,MarkEnum.SwithSkillPreName..M.name,state)
  end
  room:setPlayerMark(player,M.state,player:getSwitchSkillState(M.name)==fk.SwitchYang and "平"or"仄")
  room:setPlayerMark(player,M.used,0)
 end,
})
-- These rules remain active after the original skill has been replaced.
skill:addEffect(fk.CardEffecting,{
 global=true,
 audio_index=0,
 can_refresh=function(self,event,target,player,data)
  return target==player and data.card.trueName=="analeptic"and data.extra_data
   and data.extra_data.weekly_zhuangxing_wine and not player.dead
 end,
 on_refresh=function(self,event,target,player,data)
  if player:isWounded()then player.room:recover{who=player,num=1,recoverBy=data.from,skillName=M.name}end
 end,
})
skill:addEffect(fk.CardEffectCancelledOut,{
 global=true,
 audio_index=0,
 can_trigger=function(self,event,target,player,data)
  return target==player and data.extra_data and data.extra_data.weekly_zhuangxing_stab
   and data.isCancellOut and not data.weekly_zhuangxing_stab_checked
   and data.to and not data.to.dead and not data.to:isKongcheng()
   and table.find(data.cardsResponded or{},function(c)return c.trueName=="jink"end)~=nil
 end,
 on_cost=function()return true end,
 on_use=function(self,event,target,player,data)
  data.weekly_zhuangxing_stab_checked=true
  local ids=player.room:askToDiscard(data.to,{min_num=1,max_num=1,include_equip=false,
   cancelable=true,skill_name=M.name,prompt="#weekly_zhuangxing-stab-discard"})
  if #ids==0 then data.isCancellOut=false end
 end,
})
skill:addEffect(fk.Damage,{
 global=true,
 audio_index=0,
 can_refresh=function(self,event,target,player,data)
  return target==player and data.from==player and data.damage>0 and not data.isVirtualDMG
 end,
 on_refresh=function(self,event,target,player,data)
  player.room:setPlayerMark(player,M.damage,1)
 end,
 can_trigger=function(self,event,target,player,data)
  if target~=player or data.from~=player or player.dead or data.damage<=0 or data.isVirtualDMG then return false end
  local use=player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard,true)
  return use and use.data.card==data.card and use.data.extra_data
   and use.data.extra_data.weekly_zhuangxing_stab and (use.data.extra_data.weekly_zhuangxing_draw or 0)>0
 end,
 on_cost=function()return true end,
 on_use=function(self,event,target,player,data)
  local use=player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard,true)
  player:drawCards(use.data.extra_data.weekly_zhuangxing_draw,M.name)
 end,
})
skill:addEffect(fk.TurnEnd,{
 global=true,
 audio_index=0,
 can_trigger=function(self,event,target,player,data)return not player.dead and #player:getTableMark(M.pending)>0 end,
 on_cost=function()return true end,
 on_use=function(self,event,target,player,data)
  local room=player.room;local pending=player:getTableMark(M.pending)
  room:setPlayerMark(player,M.pending,0)
  for _,id in ipairs(pending)do
   local to=room:getPlayerById(id)
   if not player.dead and to and to:getMark(M.damage)==0 then room:loseHp(player,1,M.name)end
  end
 end,
})
Fk:loadTranslationTable{
 [M.name]="壮行",[M.revised]="壮行",[M.state]="壮行",
 [":"..M.name]="韵律技，每回合限一次，其他角色的准备阶段：平，你可以将一张牌当作触发两种效果的【酒】对其使用，回合结束若其未造成伤害你失去1点体力；仄，你可以与其重铸共计至多三张牌，然后其可以将一张同花色牌当作造成伤害摸其重铸量张牌的刺【杀】使用。转韵：你失去一张黑色牌。",
 [":"..M.revised]="每回合限一次，其他角色的准备阶段，你可以选择一项：1.将一张牌当作同时回复1点体力并令下一张【杀】伤害+1的【酒】对你使用，回合结束若你未造成伤害，你失去1点体力；2.你重铸至多三张牌，然后你可以将一张与重铸牌中任一张花色相同的牌当刺【杀】使用，此【杀】造成伤害后你摸等同于你本次重铸牌数的牌。背水：你弃置一张黑色牌。",
 ["#weekly_zhuangxing-wine"]="壮行：选择一张牌当双效果【酒】对 %dest 使用",
 ["#weekly_zhuangxing-allocate"]="壮行：分配你与 %dest 的重铸张数（合计至多三张）",
 ["#weekly_zhuangxing-recast"]="壮行：选择 %arg 张牌重铸",
 ["#weekly_zhuangxing-stab"]="壮行：你可以将同花色牌当刺【杀】使用，造成伤害后摸 %arg 张牌",
 ["#weekly_zhuangxing-stab-discard"]="刺杀：弃置一张手牌，否则刚才的【闪】不能抵消此【杀】",
 ["#weekly_zhuangxing-revised"]="壮行：选择效果，或背水执行两项",
 ["#weekly_zhuangxing-backwater"]="背水：弃置一张黑色牌，执行两项效果",
 ["weekly_zhuangxing_wine"]="将一张牌当双效果酒对自己使用",
 ["weekly_zhuangxing_recast"]="重铸至多三张牌，然后可以使用刺杀",
 ["weekly_zhuangxing_both"]="背水：弃置一张黑色牌，执行两项",
}
return skill

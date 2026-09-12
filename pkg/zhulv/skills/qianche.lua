local M=require "packages.meng_family.pkg.zhulv.revealed"
local skill=fk.CreateSkill{name="zhulv__qianche"}
local function useful(player)
 local shown=#M.cards(player,true)
 local desired=math.max(0,player.hp)
 if shown<desired and #M.cards(player,false)>0 then return true end
 if shown>desired and table.find(M.cards(player,true),function(id)return not player:prohibitDiscard(id)end)then return true end
 return #M.cards(player,false)==0 and M.refillCount(player)>0
end
skill:addEffect("active",{
 anim_type="drawcard",card_num=0,target_num=0,
 can_use=function(self,player)return player.phase==Player.Play and useful(player)end,
 on_use=function(self,room,effect)M.adjust(effect.from)end,
})
skill:addEffect(fk.Damaged,{
 can_trigger=function(self,event,target,player,data)return target==player and player:hasSkill(skill.name) and useful(player)end,
 on_cost=function(self,event,target,player,data)return player.room:askToSkillInvoke(player,{skill_name=skill.name})end,
 on_use=function(self,event,target,player,data)M.adjust(player)end,
})
skill:addEffect("maxcards",{
 exclude_from=function(self,player,card)
  return player:hasSkill(skill.name) and card.color==Card.Black and M.shown(player,card.id)
 end,
})
Fk:loadTranslationTable{
 ["zhulv__qianche"]="谦澈",
 [":zhulv__qianche"]="出牌阶段，或当你受到伤害后，你可以将明置手牌数调整至体力值（明置或弃置），然后若你手牌均明置，你将手牌摸至手牌上限；你的黑色明置牌不计入手牌上限。",
 [M.mark]="明置",
 ["#zhulv__qianche-show"]="谦澈：明置手牌，将明置数调整至体力值",
 ["#zhulv__qianche-discard"]="谦澈：弃置多出的明置手牌",
}
return skill

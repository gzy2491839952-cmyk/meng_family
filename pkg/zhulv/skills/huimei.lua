local skill=fk.CreateSkill{name="zhulv__huimei"}
local function legal(player,to,mode)
 if to==player or to.dead then return false end
 if mode=="e"then return to:getHandcardNum()<player:getHandcardNum()
 else return #to:getCardIds("e")<#player:getCardIds("e")end
end
local function modeTargets(room,player,mode,excluded)
 return table.filter(room.alive_players,function(p)return p~=excluded and legal(player,p,mode)end)
end
local function swap(room,player,to,mode)room:swapAllCards(player,{player,to},skill.name,mode)end
skill:addEffect("active",{
 anim_type="control",card_num=0,target_num=1,max_phase_use_time=1,
 can_use=function(self,player)
  return player.phase==Player.Play and player:usedSkillTimes(skill.name,Player.HistoryPhase)==0
   and table.find(Fk:currentRoom().alive_players,function(p)return legal(player,p,"e") or legal(player,p,"h")end)~=nil
 end,
 target_filter=function(self,player,to,selected)return #selected==0 and (legal(player,to,"e") or legal(player,to,"h"))end,
 on_use=function(self,room,effect)
  local player,to=effect.from,effect.tos[1]
  local choices={}
  if legal(player,to,"e")then table.insert(choices,"zhulv_huimei_e")end
  if legal(player,to,"h")then table.insert(choices,"zhulv_huimei_h")end
  if #choices==0 then return end
  local c=room:askToChoice(player,{choices=choices,skill_name=skill.name})
  local mode=c=="zhulv_huimei_e" and "e" or "h"
  swap(room,player,to,mode)
  if player.dead then return end
  local otherMode=mode=="e" and "h" or "e"
  local tos=modeTargets(room,player,otherMode,to)
  if #tos>0 then
   local nextTo=room:askToChoosePlayers(player,{targets=tos,min_num=1,max_num=1,skill_name=skill.name,
    cancelable=true,prompt=otherMode=="e" and "#zhulv__huimei-second-e" or "#zhulv__huimei-second-h"})[1]
   if nextTo then swap(room,player,nextTo,otherMode)end
  end
  if player.dead then return end
  local max=-1;local leaders={}
  for _,p in ipairs(room.alive_players)do
   local n=#p:getCardIds("hej")
   if n>max then max=n;leaders={p}elseif n==max then table.insert(leaders,p)end
  end
  if #leaders~=1 or leaders[1]==player then return end
  local card=Fk:cloneCard("slash");card.skillName=skill.name
  if player:canUseTo(card,leaders[1],{bypass_times=true})then
   room:useCard{from=player,tos={leaders[1]},card=card,extraUse=true}
  end
 end,
})
Fk:loadTranslationTable{
 ["zhulv__huimei"]="挥袂",
 [":zhulv__huimei"]="出牌阶段限一次，你可以与一名手牌数小于你的角色交换装备区里的牌，或与一名装备区内牌数小于你的角色交换手牌。然后你可以对另一名角色发动另一项，最后视为对区域总牌数唯一最大的角色使用一张【杀】。",
 ["zhulv_huimei_e"]="交换装备区里的牌",["zhulv_huimei_h"]="交换手牌",
 ["#zhulv__huimei-second-e"]="挥袂：可选择另一名手牌数小于你的角色交换装备",
 ["#zhulv__huimei-second-h"]="挥袂：可选择另一名装备数小于你的角色交换手牌",
}
return skill

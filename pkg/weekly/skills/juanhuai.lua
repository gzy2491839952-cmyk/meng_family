local skill=fk.CreateSkill{name="weekly__juanhuai"}
skill:addEffect("active",{
 anim_type="offensive",card_num=0,target_num=0,max_phase_use_time=1,
 can_use=function(self,player)
  return player.phase==Player.Play and player:usedSkillTimes(skill.name,Player.HistoryPhase)==0
    and not player:isKongcheng() and table.find(Fk:currentRoom().alive_players,function(p)
      return p~=player and p:getHandcardNum()==player:getHandcardNum()
    end)~=nil
 end,
 on_use=function(self,room,effect)
  local player=effect.from
  local participants=table.filter(room.alive_players,function(p)return p:getHandcardNum()==player:getHandcardNum()end)
  local result=room:askToJointCards(player,{players=participants,min_num=1,max_num=1,
    include_equip=false,skill_name=skill.name,cancelable=false,prompt="#weekly__juanhuai-debate"})
  local opinions,shown,count={},{},{[Card.Red]=0,[Card.Black]=0}
  for _,p in ipairs(participants)do
   local id=(result[p] or {})[1]
   if id then
    local color=Fk:getCardById(id).color
    opinions[p.id]=color;shown[id]=true;count[color]=(count[color] or 0)+1
   end
  end
  for _,p in ipairs(participants)do if result[p] and #result[p]>0 then p:showCards(result[p])end end
  if player.dead or not opinions[player.id] then return end
  local unique=table.filter(participants,function(p)
   return not p.dead and p:getHandcardNum()>=2 and opinions[p.id]
     and opinions[p.id]~=Card.NoColor and count[opinions[p.id]]==1
  end)
  if #unique==0 then return end
  local donor=room:askToChoosePlayers(player,{targets=unique,min_num=1,max_num=1,skill_name=skill.name,
    cancelable=true,prompt="#weekly__juanhuai-donor"})[1]
  if not donor then return end
  local ids=room:askToChooseCards(player,{target=donor,flag="h",min=2,max=2,
    skill_name=skill.name,cancelable=false,prompt="#weekly__juanhuai-cards"})
  if #ids~=2 then return end
  local card=Fk:cloneCard("duel");card.skillName=skill.name;card:addSubcards(ids)
  local targets=table.filter(participants,function(p)
   return not p.dead and p~=player and opinions[p.id] and opinions[p.id]~=Card.NoColor
    and opinions[p.id]~=opinions[player.id] and player:canUseTo(card,p)
  end)
  if #targets==0 then return end
  local to=room:askToChoosePlayers(player,{targets=targets,min_num=1,max_num=1,skill_name=skill.name,
    cancelable=false,prompt="#weekly__juanhuai-target"})[1]
  if not to or player.dead or donor.dead or not player:canUseTo(card,to) then return end
  for _,id in ipairs(ids)do if not table.contains(donor:getCardIds("h"),id)then return end end
  room:useCard{from=player,tos={to},card=card,additionalDamage=(shown[ids[1]] or shown[ids[2]]) and 1 or 0}
 end,
})
Fk:loadTranslationTable{
 ["weekly__juanhuai"]="狷怀",
 [":weekly__juanhuai"]="出牌阶段限一次，你可以与手牌数与你相等的所有其他角色议事。然后你可以将意见唯一的一名角色的两张手牌当【决斗】对一名意见与你不同的议事角色使用，且若底牌中含议事牌，此牌伤害+1。",
 ["#weekly__juanhuai-debate"]="狷怀：选择一张手牌议事（红色或黑色为意见）",
 ["#weekly__juanhuai-donor"]="狷怀：选择意见唯一的角色，以其两张手牌当决斗使用",
 ["#weekly__juanhuai-cards"]="狷怀：选择两张手牌作为决斗底牌",
 ["#weekly__juanhuai-target"]="狷怀：选择一名意见与你不同的议事角色",
}
return skill

local C=require "packages.meng_family.pkg.changping.central"
local M=require "packages.meng_family.pkg.changping.mibazi_rules"
local skill=fk.CreateSkill{name="changping__sichen"}
skill:addEffect(fk.TurnEnd,{
 can_trigger=function(self,e,t,p,d)
  if not p:hasSkill(skill.name) or p:usedSkillTimes(skill.name,Player.HistoryRound)>0 or #C.cards(p.room)==0 then return false end
  local _,lost=M.losses(p.room);return lost[p]==true
 end,
 on_cost=function(self,e,t,p,d)return p.room:askToSkillInvoke(p,{skill_name=skill.name})end,
 on_use=function(self,e,t,p,d)
  local room=p.room;local order=table.simpleClone(room.alive_players);room:sortByAction(order)
  for _,who in ipairs(order)do
   if not who.dead then
    local ids=C.cards(room);if #ids==0 then break end
    local chosen=room:askToChooseCards(who,{target=who,flag={card_data={{"中央区",ids}}},
     min=1,max=1,cancelable=false,skill_name=skill.name,prompt="#hqsichen-obtain"})
    local id=chosen[1]
    if not table.contains(ids,id)then id=ids[1]end
    local losses=M.losses(room);local owners=losses[id] or {}
    local own=table.contains(owners,who)
    room:obtainCard(who,id,true,fk.ReasonPrey,who,skill.name)
    if not own and not who.dead then
     room:sortByAction(owners)
     for _,owner in ipairs(owners)do
      if who.dead then break end
      if not owner.dead and owner~=who then
       local use=room:askToUseCard(owner,{skill_name=skill.name,pattern="slash",prompt="#hqsichen-slash::"..who.id,
        cancelable=true,extra_data={not_passive=true,exclusive_targets={who.id},must_targets={who.id},bypass_times=true,extraUse=true}})
       if use then room:useCard(use)end
      end
     end
    end
   end
  end
 end,
})
Fk:loadTranslationTable{
 ["changping__sichen"]="司晨",
 [":changping__sichen"]="每轮限一次，一名角色回合结束时，若你于本回合内失去过牌，则你可以令所有角色依次获得中央区一张牌；若不为其本回合失去的牌，则本回合失去此牌的角色可以对其使用【杀】。",
 ["#hqsichen-obtain"]="司晨：选择一张中央区的牌获得",
 ["#hqsichen-slash"]="司晨：%dest 获得了你本回合失去的牌，你可以对其使用杀",
}
return skill

local R=require "packages.meng_family.pkg.zhulv.revealed"
local skill=fk.CreateSkill{name="hqgod__tuqian"}
skill:addEffect("active",{
 card_num=0,target_num=0,max_phase_use_time=1,
 can_use=function(self,p)return p.phase==Player.Play and p:usedSkillTimes(skill.name,Player.HistoryPhase)==0 end,
 on_use=function(self,room,e)
  local p=e.from
  local name=room:askToChoice(p,{choices={"fire__slash","fire_attack"},skill_name=skill.name,prompt="#hqtuqian-declare"})
  local participants=table.simpleClone(room.alive_players);room:sortByAction(participants)
  local eligible={}
  for _,who in ipairs(participants)do
   if not who.dead then
    local n=math.min(2,who:getHandcardNum());local ids={}
    if n>0 then ids=room:askToCards(who,{min_num=n,max_num=n,include_equip=false,cancelable=false,skill_name=skill.name,prompt="#hqtuqian-show"});R.reveal(who,ids,skill.name)end
    if not table.find(ids,function(id)return Fk:getCardById(id).color==Card.Red end)then table.insert(eligible,who)end
   end
  end
  if p.dead then return end
  local card=Fk:cloneCard(name);card.skillName=skill.name
  local legal=table.filter(eligible,function(who)return not who.dead and p:canUseTo(card,who,{bypass_times=true})end)
  local tos={}
  if #legal>0 then tos=room:askToChoosePlayers(p,{targets=legal,min_num=1,max_num=#legal,cancelable=true,skill_name=skill.name,prompt="#hqtuqian-target"})end
  if #tos==0 then tos=table.simpleClone(room.alive_players)end
  room:useCard{from=p,tos=tos,card=card,extraUse=true,additionalDamage=#tos==1 and 1 or 0}
 end,
})
Fk:loadTranslationTable{
 ["hqgod__tuqian"]="屠愆",
 [":hqgod__tuqian"]="出牌阶段限一次，你可以声明将视为使用一张火【杀】或【火攻】，令所有角色明置两张牌，对任意名未明置红色牌的角色使用之。若目标唯一，此牌伤害+1；若没有目标，则所有角色皆成为目标（无视合法性，包含你自己）。",
 ["#hqtuqian-declare"]="屠愆：声明要使用的牌",
 ["#hqtuqian-show"]="屠愆：明置两张手牌（不足则全部）",
 ["#hqtuqian-target"]="屠愆：选择目标；取消则以所有角色为目标（包含自己）",
}
return skill

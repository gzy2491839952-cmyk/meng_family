local U=require "packages.meng_family.pkg.changping.zhaodan_util"
local skill=fk.CreateSkill{name="changping__xiaocheng_other&"}
local used="changping_xiaocheng_used-phase"
skill:addEffect("active",{
 mute=true,
 anim_type="support",card_num=2,target_num=1,
 can_use=function(self,player)
  local room=player.room or Fk:currentRoom()
  return player.phase==Player.Play and player:getMark(used)==0 and #player:getCardIds("he")>=2
    and table.find(room.alive_players,function(p)return U.xiaochengEligible(player,p)end)~=nil
 end,
 card_filter=function(self,player,id,selected)return #selected<2 and table.contains(player:getCardIds("he"),id)end,
 target_filter=function(self,player,to,selected,cards)return #selected==0 and #cards==2 and U.xiaochengEligible(player,to)end,
 on_use=function(self,room,effect)
  local from,to=effect.from,effect.tos[1]
  if not U.xiaochengEligible(from,to) then return end
  local flag=U.isZhao(from) and "hej" or "e"
  room:setPlayerMark(from,used,1)
  to:broadcastSkillInvoke("changping__xiaocheng")
  room:moveCardTo(effect.cards,Card.PlayerHand,to,fk.ReasonGive,skill.name,nil,false,from)
  if from.dead or to.dead or #to:getCardIds(flag)==0 then return end
  local id=room:askToChooseCard(from,{target=to,flag=flag,skill_name="changping__xiaocheng"})
  if id then room:obtainCard(from,id,true,fk.ReasonPrey,from,"changping__xiaocheng")end
 end,
})
Fk:loadTranslationTable{
 ["changping__xiaocheng_other&"]="孝成",
 [":changping__xiaocheng_other&"]="出牌阶段限一次，你可以交给拥有主公技“孝成”的其他角色两张牌，然后获得其一张牌：若你为赵势力，可选择其手牌、装备区或判定区的牌；否则只能选择装备区的牌。",
}
return skill

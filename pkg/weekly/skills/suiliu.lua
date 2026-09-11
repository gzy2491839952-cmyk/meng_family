local skill=fk.CreateSkill{name="weekly__suiliu"}
local suffix="-weekly_suiliu"
local function hand(player)return player:getCardIds("h")end
local function rightBasic(player)
 local ids=hand(player)
 return #ids>0 and Fk:getCardById(ids[#ids]).type==Card.TypeBasic
end
skill:addAcquireEffect(function(self,player)player.room:banSortingHandcards(player,suffix)end)
skill:addLoseEffect(function(self,player)player.room:unbanSortingHandcards(player,suffix)end)
skill:addEffect(fk.GameStart,{
 can_refresh=function(self,event,target,player,data)return player:hasSkill(skill.name,true)end,
 on_refresh=function(self,event,target,player,data)player.room:banSortingHandcards(player,suffix)end,
})
skill:addEffect("prohibit",{
 prohibit_use=function(self,player,card)
  if not player:hasSkill(skill.name) or not rightBasic(player) then return false end
  local ids=Card:getIdList(card);local h=hand(player)
  return #ids~=1 or ids[1]~=h[#h]
 end,
})
skill:addEffect("active",{
 anim_type="control",card_num=0,target_num=0,
 can_use=function(self,player)return player.phase==Player.Play and #hand(player)>0 and not rightBasic(player)end,
 on_use=function(self,room,effect)
  local player=effect.from;local id=hand(player)[1]
  if not id or rightBasic(player)then return end
  local choice=room:askToChoice(player,{choices={"weekly_suiliu_use","weekly_suiliu_recast","Cancel"},skill_name=skill.name})
  if choice=="weekly_suiliu_recast"then
   room:recastCard({id},player,skill.name)
  elseif choice=="weekly_suiliu_use"then
   local use=room:askToUseVirtualCard(player,{name="iron_chain",subcards={id},skill_name=skill.name,
    cancelable=true,skip=true,prompt="#weekly__suiliu-chain"})
   if use and hand(player)[1]==id and not rightBasic(player)then room:useCard(use)end
  end
 end,
})
Fk:loadTranslationTable{
 ["weekly__suiliu"]="随流",
 [":weekly__suiliu"]="你不能整理手牌，且手牌最右侧为基本牌时不能使用此外牌，不为时你可以将最左侧当【铁索连环】使用或重铸。",
 ["weekly_suiliu_use"]="将最左侧手牌当铁索连环使用",
 ["weekly_suiliu_recast"]="重铸最左侧手牌",
 ["#weekly__suiliu-chain"]="随流：将最左侧手牌当铁索连环使用",
}
return skill

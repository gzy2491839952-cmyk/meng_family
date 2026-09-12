local M=require "packages.meng_family.pkg.zhulv.revealed"
local skill=fk.CreateSkill{name="zhulv__choufeng_other&"}
skill:addEffect("viewas",{
 pattern=".|.|.|.|.|basic",
 prompt="#zhulv__choufeng-use",
 expand_pile=function(self,player)return M.materials(player)end,
 card_filter=function(self,player,id,selected)return #selected==0 and table.contains(M.materials(player),id)end,
 view_as=function(self,player,ids)
  if #ids~=1 or not table.contains(M.materials(player),ids[1])then return end
  local source=Fk:getCardById(ids[1])
  local c=Fk:cloneCard(source.name,source.suit,source.number)
  c:addSubcard(ids[1]);c.skillName=skill.name
  return c
 end,
 enabled_at_play=function(self,player)return #M.materials(player)>0 end,
 enabled_at_response=function(self,player,response)return not response and #M.materials(player)>0 end,
 before_use=function(self,player,use)
  local ids=Card:getIdList(use.card)
  if #ids~=1 or not table.contains(M.materials(player),ids[1])then return skill.name end
  local owner=player.room:getCardOwner(ids[1])
  use.extra_data=use.extra_data or {}
  use.extra_data.zhulv_choufeng={owner=owner.id,color=Fk:getCardById(ids[1]).color,resolved=false}
 end,
})
Fk:loadTranslationTable{
 ["zhulv__choufeng_other&"]="酬烽",
 [":zhulv__choufeng_other&"]="你可以使用其他拥有酬烽的角色明置的基本牌（作为实际底牌），其选择明置一张同色手牌，或摸两张牌并令此牌无效。不包含仅打出牌。",
 ["#zhulv__choufeng-use"]="酬烽：使用赵胜明置的一张基本牌",
}
return skill

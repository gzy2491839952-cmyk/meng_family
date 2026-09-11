local M=require("packages.meng_family.pkg.weekly.gaojianli")
local skill=fk.CreateSkill{name="weekly__juezhu",tags={Skill.Limited}}
skill:addEffect(fk.Deathed,{
 anim_type="special",
 audio_index={1,2},
 can_trigger=function(self,event,target,player,data)
  return player:hasSkill(skill.name)and not player.dead and player:getMark(M.awakened)==0
   and target~=player and table.contains(player:getTableMark(M.aided),target.id)
 end,
 on_use=function(self,event,target,player,data)
  local room=player.room
  room:setPlayerMark(player,M.awakened,1)
  room:setPlayerMark(player,M.state,0)
  room:handleAddLoseSkills(player,"-"..M.name.."|"..M.revised,nil,true,false)
 end,
})
Fk:loadTranslationTable{
 ["weekly__juezhu"]="绝筑",
 [":weekly__juezhu"]="限定技，你以“壮行”作用过的其他角色死亡后，你可以删去“壮行”的韵律技及平、仄标签，将其中的“其”改为“你”，将“转韵”改为“背水”，将转韵条件中的“失去”改为“弃置”。",
}
return skill

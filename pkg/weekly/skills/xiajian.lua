local skill=fk.CreateSkill{name="weekly__xiajian",tags={Skill.Compulsory}}
local ban="@@weekly_xiajian-turn"
local heal="@@weekly_xiajian-round"
local function lost(player,data)
 local n=0
 for _,m in ipairs(data)do
  if m.from==player and m.to~=player then n=n+#m.moveInfo end
 end
 return n
end
skill:addEffect(fk.AfterCardsMove,{
 can_trigger=function(self,event,target,player,data)return player:hasSkill(skill.name) and lost(player,data)>1 end,
 on_use=function(self,event,target,player,data)
  player:drawCards(2,skill.name)
  player.room:setPlayerMark(player,ban,1)
 end,
})
skill:addEffect("prohibit",{
 prohibit_use=function(self,player,card)return player:getMark(ban)>0 end,
})
skill:addEffect(fk.Damaged,{
 can_trigger=function(self,event,target,player,data)return target==player and player:hasSkill(skill.name) and data.damage>1 end,
 on_use=function(self,event,target,player,data)
  player.room:recover{who=player,num=1,recoverBy=player,skillName=skill.name}
  player.room:setPlayerMark(player,heal,1)
 end,
})
skill:addEffect(fk.PreHpRecover,{
 global=true,
 can_refresh=function(self,event,target,player,data)return target==player and player:getMark(heal)>0 end,
 on_refresh=function(self,event,target,player,data)data.num=0 end,
})
Fk:loadTranslationTable{
 ["weekly__xiajian"]="狭见",
 [":weekly__xiajian"]="锁定技，当你一次性失去多张牌时，你摸两张牌，然后本回合不能使用牌；当你受到大于1点伤害时，你回复1点体力，然后本轮不能回复体力。",
 [ban]="狭见：不能用牌",[heal]="狭见：不能回复",
}
return skill

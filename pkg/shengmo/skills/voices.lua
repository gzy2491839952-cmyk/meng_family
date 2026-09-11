local skill=fk.CreateSkill{name="shengmo__voice_rules"}
local general="shengmo__shangyang"
local played="shengmo_shangyang_victory_voice"
skill:addEffect(fk.GameFinished,{
 global=true,
 can_refresh=function(self,event,target,player,data)
  return (player.general==general or player.deputyGeneral==general)
    and table.contains(data.players or {},player) and player:getMark(played)==0
 end,
 on_refresh=function(self,event,target,player,data)
  player.room:setPlayerMark(player,played,1)
  player.room:broadcastPlaySound("./packages/meng_family/audio/win/"..general)
 end,
})
Fk:loadTranslationTable{
 ["shengmo__voice_rules"]="商鞅语音",
 ["$shengmo__limu1"]="徙木者，赏五十金！令既出，岂有欺民之理！",
 ["$shengmo__limu2"]="功有大小，赏有轻重，唯信不可有二！",
 ["$shengmo__dingfa1"]="宗室无功，亦不得爵；布衣斩敌，亦可封侯！",
 ["$shengmo__dingfa2"]="公子犯法，与庶民同罪！",
 ["!shengmo__shangyang"]="强秦之法已成，东出之志，今可遂矣！",
 ["~shengmo__shangyang"]="鞅身可死……莫使秦国，复归旧途……",
}
return skill

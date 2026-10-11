local skill=fk.CreateSkill{name="hq_god_baiqi_voice"}
skill:addEffect(fk.GameFinished,{
 global=true,
 can_refresh=function(self,event,target,p,data)
  return (p.general=="hanqing_god__baiqi" or p.deputyGeneral=="hanqing_god__baiqi")
   and table.contains(data.players or {},p) and p:getMark("hq_god_baiqi_win_voice")==0
 end,
 on_refresh=function(self,event,target,p,data)
  p.room:setPlayerMark(p,"hq_god_baiqi_win_voice",1)
  p.room:broadcastPlaySound("./packages/meng_family/audio/win/hanqing_god__baiqi")
 end,
})
Fk:loadTranslationTable{
 ["hq_god_baiqi_voice"]="神白起语音",
 ["$hqgod__tuqian1"]="我以千万徂魂，庇秦亿万黎庶！",
 ["$hqgod__tuqian2"]="独踏奈何桥，操戈生死簿！",
 ["$hqgod__liaofan1"]="燎原烈火炙长平，五脏六腑燔杜邮。",
 ["$hqgod__liaofan2"]="我焚杜邮铮铮骨，二迎阎王入炼狱！",
 ["!hanqing_god__baiqi"]="长平残骨，犹嫌土浅；今开炼狱，再葬苍生！",
 ["~hanqing_god__baiqi"]="业火噬身，万魂索命……本君，一并受领……",
}
return skill

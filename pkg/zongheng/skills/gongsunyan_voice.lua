local skill=fk.CreateSkill{name="hq_gongsunyan_voice"}
skill:addEffect(fk.GameFinished,{
 global=true,
 can_refresh=function(self,event,target,p,data)
  return (p.general=="zongheng__gongsunyan" or p.deputyGeneral=="zongheng__gongsunyan")
   and table.contains(data.players or {},p) and p:getMark("hq_gongsunyan_win_voice")==0
 end,
 on_refresh=function(self,event,target,p,data)
  p.room:setPlayerMark(p,"hq_gongsunyan_win_voice",1)
  p.room:broadcastPlaySound("./packages/meng_family/audio/win/zongheng__gongsunyan")
 end,
})
Fk:loadTranslationTable{["hq_gongsunyan_voice"]="公孙衍语音"}
Fk:loadTranslationTable{
 ["$hqgsy__bingjin1"]="周公未绝祀，庄王犹瓜绵，圉师怎可抗之。",
 ["$hqgsy__bingjin2"]="昔赢秦逢晋，几不自保；今三晋戮力，何犹负隅。",
 ["$hqgsy__bingjin3"]="左肘掣则右手抵，左膝屈则右足撑，岂谓无援！",
 ["$hqgsy__guzhi1"]="绕匝飞，绕匝飞，寒枝难栖胡不归。",
 ["$hqgsy__guzhi2"]="胡不归，胡不归，不顾俗问绕匝飞。",
 ["$hqgsy__guzhi3"]="鸷鸟不群，自前世固然；鸿鹄怀志，怨燕雀不瞰。",
 ["!zongheng__gongsunyan"]="诸侯同心，则函谷可叩，强秦可折！",
 ["~zongheng__gongsunyan"]="衍何为？行间泪。",
}
return skill

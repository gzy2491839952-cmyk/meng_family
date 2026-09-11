local skill=fk.CreateSkill{name="weekly__voice_rules"}
local generals={"weekly__feiyi","weekly__gaojianli","weekly__zhengguo"}
skill:addEffect(fk.GameFinished,{
 global=true,
 can_refresh=function(self,event,target,player,data)
  return table.contains(data.players or {},player) and table.find(generals,function(g)
   return (player.general==g or player.deputyGeneral==g) and player:getMark(g.."_victory_voice")==0
  end)~=nil
 end,
 on_refresh=function(self,event,target,player,data)
  for _,g in ipairs(generals)do
   if (player.general==g or player.deputyGeneral==g) and player:getMark(g.."_victory_voice")==0 then
    player.room:setPlayerMark(player,g.."_victory_voice",1)
    player.room:broadcastPlaySound("./packages/meng_family/audio/win/"..g)
   end
  end
 end,
})
Fk:loadTranslationTable{
 ["weekly__voice_rules"]="周赛语音",
 ["$weekly__zhuojian1"]="臣愿披此肝胆，请君明察祸福！",
 ["$weekly__zhuojian2"]="胡服可强赵兵，大王何必顾忌世人之议！",
 ["$weekly__jieming1"]="主父以少主相托，老臣当以性命相守！",
 ["$weekly__jieming2"]="受命之言犹在耳边，岂能临难而背！",
 ["!weekly__feiyi"]="少主无恙，赵室得安，老臣便不负所托。",
 ["~weekly__feiyi"]="赵章！田不礼！主父在哪，臣要见主父……",
 ["$weekly__zhuangxing1"]="易水风寒，听我击筑相送。",
 ["$weekly__zhuangxing2"]="荆卿但赴咸阳，此间琴声由我尽奏。",
 ["$weekly__zhuangxing3"]="变徵已尽，且奏羽声，为君壮此一行！",
 ["$weekly__zhuangxing4"]="莫作垂泪之音，当使满座皆有赴死之志！",
 ["$weekly__juezhu1"]="荆卿既去，此筑再无人和，便以秦皇之血作结！",
 ["$weekly__juezhu2"]="汝毁我双目，岂能灭我心中未尽之仇！",
 ["$weekly__zhuangxing_revised1"]="昔日击筑送君，今日携筑赴死！",
 ["$weekly__zhuangxing_revised2"]="铅存筑内，恨积胸中，尽付此一击！",
 ["!weekly__gaojianli"]="易水未尽之曲，今日终于奏罢……",
 ["~weekly__gaojianli"]="筑声已绝……耳畔却仍是，故人之歌……",
 ["$weekly__zaoqu1"]="凿近水而东注，化关中为沃野！",
 ["$weekly__zaoqu2"]="秦渠多凿一里，韩地便多存一日!",
 ["!weekly__zhengguo"]="三百里渠水既通，关中百姓可待丰年！",
 ["~weekly__zhengguo"]="身后不必立碑……有这一渠流水，便够了……",
}
return skill

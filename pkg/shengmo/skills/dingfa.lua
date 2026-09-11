local U=require "packages.meng_family.pkg.shengmo.law"
local skill=fk.CreateSkill{name="shengmo__dingfa",tags={Skill.HanqingReform or "HanqingReform"}}
skill:addEffect(fk.RoundStart,{
 audio_index={1,2},
 anim_type="control",
 can_trigger=function(self,event,target,player,data)
   return player:hasSkill(skill.name) and player.room:getCardArea(U.token(player.room,player))==Card.Void
 end,
 on_cost=function(self,event,target,player,data)
   local targets=table.filter(player.room.alive_players,function(p)return not U.holderBook(p) end)
   if #targets==0 then return false end
   local tos=player.room:askToChoosePlayers(player,{targets=targets,min_num=1,max_num=1,cancelable=true,
     skill_name=skill.name,prompt="#shengmo__dingfa-choose"})
   if #tos==1 then event:setCostData(self,{tos=tos});return true end
 end,
 on_use=function(self,event,target,player,data)
   local room=player.room;local to=event:getCostData(self).tos[1];local id=U.token(room,player)
   if not to.dead and not U.holderBook(to) and room:getCardArea(id)==Card.Void then U.place(room,to,id) end
 end,
})
Fk:loadTranslationTable{
 ["shengmo__dingfa"]="定法",
 [":shengmo__dingfa"]="变革技，每轮开始时，你可以洗切一名角色的手牌并将《商君书》置入其手牌区中央。",
 ["#shengmo__dingfa-choose"]="定法：选择一名角色，洗切其手牌并将《商君书》置入中央",
 ["shengmo__shangjunshu"]="商君书",
 [":shengmo__shangjunshu"]="律（无类型、点数、花色）。计入手牌数，不能直接使用或打出。你不能整理手牌；以此牌为中线，当你使用任意一侧的手牌时，若该侧牌数：较多，你将牌堆顶两张牌置入较少侧并令此牌无效；较少，你弃置较多侧的一张牌并令此牌多结算一次。两侧牌数在使用前比较，不计此牌；普通获得的牌置于右侧。此牌离开初始手牌区时，改为移出游戏。",
 ["#shengmo-law-discard"]="商君书：弃置较多侧的一张手牌，此次使用的牌多结算一次",
}
return skill

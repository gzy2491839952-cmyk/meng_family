local skill=fk.CreateSkill{name="shengmo__limu",tags={Skill.Compulsory},
 dynamic_desc=function(self,player)
   local n=player and math.max(1,player:getMark("shengmo_limu_threshold")) or 1
   return "锁定技，当一名角色造成伤害后，若本局所有角色造成伤害值之和达到｛"..n.."｝点，其与你依次摸一张牌直到以此法摸牌数达到｛"..n.."｝张，然后你清空本局伤害记录并令｛｝里的数字+1。"
 end}
local total="shengmo_damage_total"
local base="shengmo_limu_baseline"
local threshold="shengmo_limu_threshold"
local busy="shengmo_limu_busy"
local function refresh(room)
  for _,p in ipairs(room.players) do
    if p:hasSkill(skill.name,true) then
      local n=math.max(1,p:getMark(threshold))
      room:setPlayerMark(p,"@shengmo_limu",tostring((room:getBanner(total) or 0)-p:getMark(base)).."/"..n)
    end
  end
end
skill:addEffect(fk.GameStart,{
 can_refresh=function(self,event,target,player,data)return player:hasSkill(skill.name,true) end,
 on_refresh=function(self,event,target,player,data)refresh(player.room) end,
})
skill:addEffect(fk.Damage,{
 audio_index={1,2},
 global=true,
 can_refresh=function(self,event,target,player,data)
   return data.from~=nil and (data.damage or 0)>0 and not event:getSkillData(self,"counted")
 end,
 on_refresh=function(self,event,target,player,data)
   event:setSkillData(self,"counted",true)
   local room=player.room
   room:setBanner(total,(room:getBanner(total) or 0)+data.damage)
   refresh(room)
 end,
 can_trigger=function(self,event,target,player,data)
   return data.from~=nil and player:hasSkill(skill.name) and player:getMark(busy)==0
     and (player.room:getBanner(total) or 0)-player:getMark(base)>=math.max(1,player:getMark(threshold))
 end,
 on_use=function(self,event,target,player,data)
   local room=player.room;local n=math.max(1,player:getMark(threshold))
   room:setPlayerMark(player,busy,1)
   for i=1,n do
     local who=i%2==1 and data.from or player
     if who and not who.dead then who:drawCards(1,skill.name) end
   end
   room:setPlayerMark(player,base,room:getBanner(total) or 0)
   room:setPlayerMark(player,threshold,n+1)
   room:setPlayerMark(player,busy,0)
   refresh(room)
 end,
})
Fk:loadTranslationTable{
 ["shengmo__limu"]="立木",
 [":shengmo__limu"]="锁定技，当一名角色造成伤害后，若本局所有角色造成伤害值之和达到｛1｝点，其与你依次摸一张牌直到以此法摸牌数达到｛1｝张，然后你清空本局伤害记录并令｛｝里的数字+1。",
 ["@shengmo_limu"]="立木",
}
return skill

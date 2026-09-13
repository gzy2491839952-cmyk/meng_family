local C=require "packages.meng_family.pkg.changping.central"
local skill=fk.CreateSkill{name="hqgod__shuanghai",tags={Skill.Compulsory}}
skill:addEffect("invalidity",{
 global=true,invalidity_func=function(self,p,s)
  return p:getMark("hqshuanghai_invalidity")>0 and s:isPlayerSkill(p) and not s:hasTag(Skill.Compulsory)
 end,
})
skill:addEffect(fk.RoundEnd,{
 can_trigger=function(self,e,t,p,d)return p:hasSkill(skill.name) and #C.fixed(p.room)>#p.room.alive_players end,
 on_use=function(self,e,t,p,d)
  local room=p.room
  local previous={}
  for _,who in ipairs(room.players)do previous[who]=who:getMark("hqshuanghai_invalidity")end
  local cleaned=false
  local function restore()
   if cleaned then return end
   cleaned=true
   for who,value in pairs(previous)do room:setPlayerMark(who,"hqshuanghai_invalidity",value)end
  end
  room.logic:getCurrentEvent():addCleaner(restore)
  for who,value in pairs(previous)do room:setPlayerMark(who,"hqshuanghai_invalidity",value+1)end
  local first=room:askToChoosePlayers(p,{targets=room.alive_players,min_num=1,max_num=1,cancelable=false,skill_name=skill.name,prompt="#hqshuanghai-first"})[1]
  local order={};local start=table.indexOf(room.alive_players,first)
  for i=0,#room.alive_players-1 do table.insert(order,room.alive_players[(start+i-1)%#room.alive_players+1])end
  local own=false
  while #C.fixed(room)>0 do
   local used=false
   for _,who in ipairs(order)do
    if not who.dead then
     local ids=C.fixed(room)
     if #ids==0 then break end
     local use=room:askToUseRealCard(who,{pattern=ids,expand_pile=ids,skill_name=skill.name,cancelable=false,skip=true,extra_data={bypass_times=true,extraUse=true}})
     if use then
      local materials=Card:getIdList(use.card);C.remove(room,materials)
      room:useCard(use);C.remove(room,materials)
      used=true;if who==p then own=true end
     end
    end
   end
   if not used then break end
  end
  if not own and not p.dead then local ids=C.cards(room);if #ids>0 then room:obtainCard(p,ids,true,fk.ReasonPrey,p,skill.name)end end
  restore()
 end,
})
Fk:loadTranslationTable{
 ["hqgod__shuanghai"]="霜骸",
 [":hqgod__shuanghai"]="锁定技，每轮结束时，若固定于中央区的牌数大于场上角色数，你令所有非锁定技失效至此技能结算结束并选择一名角色。从该角色开始，所有角色依次使用中央区固定的一张牌，直到无法使用。若你未因此使用牌，你获得中央区剩余的牌。",
 ["#hqshuanghai-first"]="霜骸：选择开始使用固定牌的角色",
}
return skill

local Room=require "ltk.server.room"
local M={}
local function hiddenCount(ids,extra)
 local n=0;for _,id in ipairs(ids)do if table.contains(extra.hq_sample or {},id)then n=n+1 end end;return n
end
-- Final choice preserves the original total count while requiring exactly
-- the announced number of cards from the privately viewed sample.
Fk:addPoxiMethod{
 name="hqshenhui_final",
 card_filter=function(id,selected,data,e)
  if #selected>=e.max then return false end
  return not table.contains(e.hq_sample,id) or hiddenCount(selected,e)<e.hq_hidden_count
 end,
 feasible=function(selected,data,e)return #selected>=e.min and #selected<=e.max and hiddenCount(selected,e)==e.hq_hidden_count end,
 prompt=function()return "#hqshenhui-final"end,
 default_choice=function(data,e)
  local chosen={}
  for i=1,e.hq_hidden_count do table.insert(chosen,e.hq_sample[i])end
  for _,row in ipairs(data)do for _,id in ipairs(row[2])do
   if #chosen>=e.min then return chosen end
   if not table.contains(e.hq_sample,id) and not table.contains(chosen,id)then table.insert(chosen,id)end
  end end
  return chosen
 end,
}
function M.install()
 if Room.hanqing_shenhui_installed then return end
 Room.hanqing_shenhui_installed=true
 local originalPoxi=Room.askToPoxi
 local originalOne=Room.askToChooseCard
 function Room:askToPoxi(player,params)
  local e=params.extra_data or {}
  if params.poxi_type~="AskForCardsChosen" or not player:hasSkill("changping__shenhui") or not e.visible_data or e.pattern then
   return originalPoxi(self,player,params)
  end
  local hidden,known={},{}
  for _,row in ipairs(params.data)do for _,id in ipairs(row[2])do
   if e.visible_data[tostring(id)]==false then table.insertIfNeed(hidden,id)else table.insertIfNeed(known,id)end
  end end
  if #hidden<2 or (e.max or 0)<1 then return originalPoxi(self,player,params)end
  -- Invoke BEFORE any original card-selection request is issued.
  if not self:askToSkillInvoke(player,{skill_name="changping__shenhui",prompt="#hqshenhui-invoke"})then
   return originalPoxi(self,player,params)
  end
  local minHidden=math.max(1,(e.min or 1)-#known)
  local maxHidden=math.min(e.max,#hidden)
  if minHidden>maxHidden then return originalPoxi(self,player,params)end
  local counts={};for i=minHidden,maxHidden do table.insert(counts,tostring(i))end
  local n=tonumber(#counts==1 and counts[1] or self:askToChoice(player,{choices=counts,skill_name="changping__shenhui",prompt="#hqshenhui-count"})) or minHidden
  if n<minHidden or n>maxHidden then n=minHidden end
  local size=math.min(2*n,#hidden)
  local sample
  if size==#hidden then sample=table.simpleClone(hidden)
  else
   local invisible={};for _,id in ipairs(hidden)do invisible[tostring(id)]=false end
   sample=originalPoxi(self,player,{poxi_type="AskForCardsChosen",data={{"$Hand",hidden}},
    extra_data={min=size,max=size,to=player.id,skillName="changping__shenhui",visible_data=invisible,prompt="#hqshenhui-watch"},cancelable=false})
  end
  player:broadcastSkillInvoke("changping__shenhui")
  local sampled={};for _,id in ipairs(sample)do if table.contains(hidden,id)then table.insertIfNeed(sampled,id)end end
  for _,id in ipairs(hidden)do if #sampled>=size then break end;table.insertIfNeed(sampled,id)end
  local data={};local visible={}
  for _,row in ipairs(params.data)do
   local ids=table.filter(row[2],function(id)return table.contains(known,id) or table.contains(sampled,id)end)
   if #ids>0 then table.insert(data,{row[1],ids})end
   for _,id in ipairs(ids)do visible[tostring(id)]=true end
  end
  local finalExtra={min=e.min,max=e.max,to=e.to,skillName="changping__shenhui",visible_data=visible,
   hq_sample=sampled,hq_hidden_count=n}
  local result=originalPoxi(self,player,{poxi_type="hqshenhui_final",data=data,extra_data=finalExtra,cancelable=false})
  local valid=#result>=e.min and #result<=e.max and hiddenCount(result,finalExtra)==n
  local seen={};for _,id in ipairs(result)do
   if seen[id] or not(table.contains(known,id) or table.contains(sampled,id))then valid=false end;seen[id]=true
  end
  if not valid then return Fk.poxi_methods.hqshenhui_final.default_choice(data,finalExtra)end
  return result
 end
 function Room:askToChooseCard(player,params)
  if not player:hasSkill("changping__shenhui") or type(params.flag)~="string" or not params.target then return originalOne(self,player,params)end
  local ids=params.target:getCardIds(params.flag);local visibility={};local hidden=0
  for _,id in ipairs(ids)do if not player:cardVisible(id)then visibility[tostring(id)]=false;hidden=hidden+1 end end
  if hidden<2 then return originalOne(self,player,params)end
  local result=self:askToPoxi(player,{poxi_type="AskForCardsChosen",data={{"$Hand",ids}},
   extra_data={to=params.target.id,min=1,max=1,skillName=params.skill_name,prompt=params.prompt,visible_data=visibility},cancelable=false})
  return result[1] or originalOne(self,player,params)
 end
end
Fk:loadTranslationTable{
 ["#hqshenhui-invoke"]="神慧：是否在选牌前，先观看双倍数量的暗牌？",
 ["#hqshenhui-count"]="神慧：本次要从暗牌中选取几张？",
 ["#hqshenhui-watch"]="神慧：选择要观看的双倍数量暗牌",
 ["#hqshenhui-final"]="神慧：从观看的牌中选定原定数量的牌",
}
return M

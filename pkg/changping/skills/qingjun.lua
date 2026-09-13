local skill=fk.CreateSkill{name="changping__qingjun"}
local function names(event,who,data,ids)
 local result={}
 for _,name in ipairs{"slash","jink"}do
  local card=Fk:cloneCard(name);card.skillName=skill.name
  card:addSubcards(ids or {})
  if Exppattern:Parse(data.pattern):match(card) and
    not (event:isInstanceOf(fk.AskForCardResponse) and who:prohibitResponse(card)) and
    not (event:isInstanceOf(fk.AskForCardUse) and who:prohibitUse(card))then table.insert(result,name)end
 end
 return result
end
local spec={
 can_trigger=function(self,e,t,p,d)
  return p:hasSkill(skill.name) and p.room.current==p and t and not t.dead and not d.result
   and #t:getCardIds("he")>=2 and #names(e,t,d)>0
 end,
 on_cost=function(self,e,t,p,d)return p.room:askToSkillInvoke(p,{skill_name=skill.name,prompt="#hqqingjun-invoke::"..t.id})end,
 on_use=function(self,e,t,p,d)
  local room=p.room
  while not t.dead and not p.dead do
   local ids=room:askToChooseCards(p,{target=t,flag="he",min=2,max=2,cancelable=true,skill_name=skill.name})
   if #ids~=2 then return end
   local owned=t:getCardIds("he")
   if not table.every(ids,function(id)return table.contains(owned,id)end)then return end
   local choices=names(e,t,d,ids)
   local extra=table.simpleClone(d.extraData or {})
   if extra.bypass_times==nil then extra.bypass_times=true end
   local active=e:isInstanceOf(fk.AskForCardUse) and extra.not_passive==true
   if active then
    choices=table.filter(choices,function(name)
     local c=Fk:cloneCard(name);c:addSubcards(ids);c.skillName=skill.name
     return #c:getAvailableTargets(t,extra)>0
    end)
   end
   if #choices>0 then
    local name=#choices==1 and choices[1] or room:askToChoice(p,{choices=choices,skill_name=skill.name})
    local card=Fk:cloneCard(name);card:addSubcards(ids);card.skillName=skill.name
    if not active then
     d.result={from=t,card=card}
     if e:isInstanceOf(fk.AskForCardUse)then d.result.tos={}end
    else
     local available=card:getAvailableTargets(t,extra)
     local required=extra.must_targets or extra.fix_targets or {}
     local tos={}
     for _,id in ipairs(required)do
      local who=room:getPlayerById(id)
      if table.contains(available,who)then table.insertIfNeed(tos,who)end
     end
     if #required>0 and #tos~=#required then return end
     if #tos==0 then
      if #available==1 then tos={available[1]}
      else tos=room:askToChoosePlayers(t,{targets=available,min_num=1,max_num=1,cancelable=false,skill_name=skill.name,prompt="#hqqingjun-target"})end
     end
     if #tos>0 then d.result={from=t,tos=tos,card=card,extraUse=extra.extraUse~=false}end
    end
    break
   end
   local retry=room:askToChoice(p,{choices={"hqqingjun_retry","Cancel"},skill_name=skill.name,prompt="#hqqingjun-illegal"})
   if retry~="hqqingjun_retry"then return end
  end
  if d.result then return true end
 end,
}
skill:addEffect(fk.AskForCardUse,spec)
skill:addEffect(fk.AskForCardResponse,spec)
Fk:loadTranslationTable{
 ["changping__qingjun"]="请君",
 [":changping__qingjun"]="你的回合内，有角色需要使用或打出【杀】或【闪】时，你可以选择其两张牌，并令其将这些牌当此牌使用或打出。",
 ["hqqingjun_retry"]="重新选择素材牌",
 ["#hqqingjun-illegal"]="请君：这两张牌无法合法转化用于本次请求（请检查距离及用牌限制），是否重选？",
 ["#hqqingjun-target"]="请君：为转化的牌选择目标",
 ["#hqqingjun-invoke"]="请君：是否选择 %dest 的两张手牌或装备牌，替其转化为所需的杀或闪？",
}
return skill

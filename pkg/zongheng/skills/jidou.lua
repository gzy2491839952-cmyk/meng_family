local M=require "packages.meng_family.pkg.zongheng.alliance"
local skill=fk.CreateSkill{name="hqzhangyi__jidou"}
skill:addEffect(fk.EventPhaseStart,{
 can_trigger=function(self,e,t,p,d)return t==p and p.phase==Player.Start and p:hasSkill(skill.name)end,
 on_cost=function(self,e,t,p,d)
  local tos=table.filter(p.room.alive_players,function(q)return #M.options(q)>0 end)
  if #tos==0 then return false end
  tos=p.room:askToChoosePlayers(p,{targets=tos,min_num=1,max_num=math.min(3,#tos),cancelable=true,
   skill_name=skill.name,prompt="#hq-jidou-players"})
  if #tos>0 then e:setCostData(self,tos);return true end
 end,
 on_use=function(self,e,t,p,d)M.jidou(p,e:getCostData(self))end,
})
Fk:loadTranslationTable{
 ["hqzhangyi__jidou"]="犄斗",
 [":hqzhangyi__jidou"]="准备阶段，你可选择至多三名角色，其同时将一张牌当【铁索连环】【纵横捭阖】或任意属性【杀】使用，并按你指定的顺序依次结算，先使角色重置的一方获得所有底牌。",
 ["#hq-jidou-players"]="犄斗：选择至多三名角色，同时提交转化牌与目标",
 ["#hq-jidou-submit"]="犄斗：选择一张手牌或装备牌、转化牌名及使用目标",
 ["#hq-jidou-order"]="犄斗：选择下一名结算的角色（全部顺序确定后开始结算）",
}
return skill

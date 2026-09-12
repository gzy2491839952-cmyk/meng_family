local M=require "packages.meng_family.pkg.changping.zhaokuo_dream"
local skill=fk.CreateSkill{name="dream__pishi",tags={Skill.Compulsory}}
skill:addEffect(fk.TargetConfirmed,{
 can_trigger=function(self,event,target,p,data)
  return target==p and p:hasSkill(skill.name) and data.card.is_damage_card and not M.hasName(p,data.card.name)
 end,
 on_use=function(self,event,target,p,data)
  -- Nullify even when the used card has no collectible physical counterpart.
  data.use.nullifiedTargets=table.simpleClone(p.room.players)
  local id=M.collectible(p.room,data.card)
  if id then p:addToPile(M.pile,id,true,skill.name)end
 end,
})
Fk:loadTranslationTable{
 ["dream__pishi"]="披矢",[M.pile]="披矢",
 [":dream__pishi"]="锁定技，当你成为伤害牌的目标时，若你武将牌上未有相同牌名的牌，你将此牌置于武将牌上并无效之。（其他牌转化的伤害牌仍无效，但不置于武将牌上。）",
}
return skill

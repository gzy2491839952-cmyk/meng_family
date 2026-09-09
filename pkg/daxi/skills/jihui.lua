local R = require "packages.meng_family.pkg.daxi.liuwenxiu_util"
local skill = fk.CreateSkill {name="daxi__jihui",tags={Skill.Compulsory}}
skill:addEffect(fk.EventPhaseStart, {
  anim_type="offensive",
  can_trigger=function(self,event,target,player,data)
    return target==player and player:hasSkill(skill.name) and player.phase==Player.Finish
  end,
  on_cost=function() return true end,
  on_use=function(self,event,target,player,data)
    local room=player.room
    local pool=R.pool(player)
    if #pool==0 then return end
    local hp=math.huge
    for _,p in ipairs(pool) do hp=math.min(hp,p.hp) end
    local candidates=table.filter(pool,function(p) return p.hp==hp end)
    local chosen=room:askToChoosePlayers(player, {
      targets=candidates,min_num=1,max_num=1,cancelable=false,
      skill_name=skill.name,prompt="#daxi__jihui-target",
    })
    if #chosen==0 then return end
    local victim=chosen[1]
    room:damage {from=player,to=victim,damage=1,skillName=skill.name}
    if not victim.dead then
      local use=room:askToUseCard(victim, {
        skill_name=skill.name,pattern="slash",prompt="#daxi__jihui-slash",cancelable=true,
        extra_data={bypass_times=true,extraUse=true},
      })
      if use then room:useCard(use) end
      if not victim.dead then
        room:recover {who=victim,num=1,recoverBy=player,skillName=skill.name}
      end
    end
    -- This exclusion starts after damage, optional Slash and recovery resolve.
    room:setPlayerMark(player,R.excluded,victim.id)
  end,
})
Fk:loadTranslationTable {
  ["daxi__jihui"]="忣恢",
  [":daxi__jihui"]="锁定技，结束阶段，你须对体力值最少的一名角色造成1点伤害，令其可以使用一张【杀】并回复1点体力，使你下次发动技能计算排名不包含其。",
  [R.excluded]="忣恢·下次排名排除",
  ["#daxi__jihui-target"]="忣恢：对参与本次排名且体力值最少的一名角色造成1点伤害",
  ["#daxi__jihui-slash"]="忣恢：你可以使用一张【杀】，之后回复1点体力",
}
return skill

local skill = fk.CreateSkill {name="changping__huiguo",tags={Skill.Compulsory}}
for _, timing in ipairs{fk.Damage,fk.Damaged} do
  skill:addEffect(timing, {
    anim_type="offensive",
    audio_index={1,2},
    can_trigger=function(self,event,target,player,data)
      -- Self-inflicted damage is processed only at Damaged, not twice.
      return target == player and player:hasSkill(skill.name) and not player.dead
        and not data.to.dead and (timing ~= fk.Damage or data.to ~= player)
        and data.to:getLostHp()>0
    end,
    on_use=function(self,event,target,player,data)
      local room, victim = player.room, data.to
      local lost = victim:getLostHp()
      if lost == 1 then
        if victim:isNude() then return end
        if victim == player then
          room:askToDiscard(player,{min_num=1,max_num=1,include_equip=true,cancelable=false,skill_name=skill.name})
        else
          local id=room:askToChooseCard(player,{target=victim,flag="he",skill_name=skill.name})
          if id then room:throwCard({id},skill.name,victim,player) end
        end
      elseif lost == 2 then
        player:drawCards(2,skill.name)
      elseif lost >= 3 then
        room:changeMaxHp(victim,-1)
      end
    end,
  })
end
skill:addEffect(fk.GameFinished, {
  global=true,
  can_refresh=function(self,event,target,player,data)
    return (player.general=="changping__baiqi" or player.deputyGeneral=="changping__baiqi")
      and table.contains(data.players or {},player)
      and player:getMark("changping__baiqi_victory_voice")==0
  end,
  on_refresh=function(self,event,target,player,data)
    player.room:setPlayerMark(player,"changping__baiqi_victory_voice",1)
    player.room:broadcastPlaySound("./packages/meng_family/audio/win/changping__baiqi")
  end,
})
Fk:loadTranslationTable {
  ["$changping__huiguo1"]="百万枯骨，方铸九鼎！",
  ["$changping__huiguo2"]="六国以血肉拒秦，吾便以此剑，问其国祚！",
  ["!changping__baiqi"]="长平既下，邯郸可期！大秦东出之势，岂能止于此地！",
  ["~changping__baiqi"]="为秦征战半生……竟无一寸归土……",
  ["changping__huiguo"]="隳国",
  [":changping__huiguo"]="锁定技，当你造成或受到伤害后，若受伤角色已损失体力值为：1，你弃置其一张牌；2，你摸两张牌；3或更多，你令其减1点体力上限。",
}
return skill

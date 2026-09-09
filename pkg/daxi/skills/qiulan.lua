local R = require "packages.meng_family.pkg.daxi.liuwenxiu_util"
local skill = fk.CreateSkill {name="daxi__qiulan"}
local cause = "@daxi__qiulan_cause"
local receive = "@daxi__qiulan_receive"

local function settle(owner, original)
  if original.dead then return end
  local room = owner.room
  local recipient, x = original, 0
  if not owner.dead then
    local max = #owner:getCardIds("he")
    if max>0 then
      local cards = room:askToDiscard(owner, {
        min_num=1, max_num=max, include_equip=true, cancelable=true,
        pattern=".|.|red", skill_name=skill.name, prompt="#daxi__qiulan-discard::"..original.id,
      })
      x = #cards
    end
    if x>0 and not owner.dead then
      local candidates = R.handRank(R.pool(owner),x)
      if #candidates>0 then
        local chosen = room:askToChoosePlayers(owner, {
          targets=candidates,min_num=1,max_num=1,cancelable=false,
          skill_name=skill.name,prompt="#daxi__qiulan-rank:::"..x,
        })
        if #chosen>0 then recipient=chosen[1] end
      end
    end
  end
  if not recipient.dead then
    recipient:drawCards(2+(recipient==original and x or 0),skill.name)
  end
end

for _, pair in ipairs {{fk.Damage,cause},{fk.Damaged,receive}} do
  local timing, mark = pair[1], pair[2]
  skill:addEffect(timing, {
    global=true,
    -- Resolve old promises before allowing this event to create a new promise.
    -- Snapshot/clear every owner before drawing can trigger nested damage.
    can_refresh=function(self,event,target,player,data)
      return target~=nil and not event:getSkillData(self,"daxi__qiulan_resolved")
    end,
    on_refresh=function(self,event,target,player,data)
      event:setSkillData(self,"daxi__qiulan_resolved",true)
      local tickets={}
      for _,owner in ipairs(player.room.players) do
        local n=owner:getMark(mark)
        if n>0 then
          player.room:setPlayerMark(owner,mark,0)
          table.insert(tickets,{owner=owner,n=n})
        end
      end
      for _,ticket in ipairs(tickets) do
        for i=1,ticket.n do settle(ticket.owner,target) end
      end
    end,
    can_trigger=function(self,event,target,player,data)
      return target==player and player:hasSkill(skill.name) and not player.dead
    end,
    on_cost=function(self,event,target,player,data)
      return player.room:askToSkillInvoke(player, {
        skill_name=skill.name,
        prompt=mark==cause and "#daxi__qiulan-cause" or "#daxi__qiulan-receive",
      })
    end,
    on_use=function(self,event,target,player,data)
      player.room:addPlayerMark(player,mark,1)
    end,
  })
end
Fk:loadTranslationTable {
  ["daxi__qiulan"]="泅澜",
  [":daxi__qiulan"]="当你造成/受到伤害后，可以令下一名造成/受到伤害的角色摸两张牌；且摸牌时，你可弃置任意张红色牌，改为由手牌数第X多的一名角色摸牌，不变则多摸X张。（X为弃牌数）",
  [cause]="泅澜·下次造成",
  [receive]="泅澜·下次受到",
  ["#daxi__qiulan-cause"]="泅澜：是否令下一名造成伤害的角色摸两张牌？",
  ["#daxi__qiulan-receive"]="泅澜：是否令下一名受到伤害的角色摸两张牌？",
  ["#daxi__qiulan-discard"]="泅澜：你可弃置任意张红色牌改变%dest的摸牌对象；取消则其摸两张牌",
  ["#daxi__qiulan-rank"]="泅澜：选择手牌数第%arg多的一名角色摸牌（对象不变则额外摸%arg张）",
}
return skill

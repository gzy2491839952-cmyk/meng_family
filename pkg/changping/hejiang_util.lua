local M={mark="changping_hejiang_card",used="changping_hejiang_names-phase"}
M.slots={Player.WeaponSlot,Player.ArmorSlot,Player.OffensiveRideSlot,Player.DefensiveRideSlot,Player.TreasureSlot}
M.types={Card.SubtypeWeapon,Card.SubtypeArmor,Card.SubtypeOffensiveRide,Card.SubtypeDefensiveRide,Card.SubtypeTreasure}
function M.slotIndex(slot)for i,s in ipairs(M.slots)do if s==slot then return i end end end
function M.available(p)
  local t={};for _,s in ipairs(p:getAvailableEquipSlots())do table.insertIfNeed(t,s)end;return t
end
function M.install(extension)
  for i,subtype in ipairs(M.types)do
    extension:loadCardSkels{fk.CreateCard{
      name="changping__hejiang_equip"..i,type=Card.TypeEquip,sub_type=subtype,attack_range=1,
      dynamic_name=function(self,player)
        local id=self:getEffectiveId()
        if id and id>=0 then return Fk:translate(Fk:getCardById(id,true).name) end
        return "和将"
      end,
    }}
    Fk:loadTranslationTable{["changping__hejiang_equip"..i]="和将",
      [":changping__hejiang_equip"..i]="此牌仅占据装备栏，不提供装备效果。离开装备区后恢复为原基本牌。"}
  end
end
return M

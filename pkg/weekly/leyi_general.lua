local M={}
function M.install(extension)
 local g=General:new(extension,"hanqing_god__leyi","god",2,2,General.Male)
 g:addSkills{"hqleyi__sancun","hqleyi__genxi","hqleyi__haishan","hqleyi__lianyao"}
 Fk:addDamageNature("hanqing_light","hanqing_light_damage",true)
 Fk:loadTranslationTable{
  ["hanqing_god__leyi"]="神乐毅",["#hanqing_god__leyi"]="铸日之金乌",
  ["designer:hanqing_god__leyi"]="小叶子",["illustrator:hanqing_god__leyi"]="大大大煌",
  ["hanqing_light_damage"]="光属性",
 }
end
return M

local M={}
function M.install(extension)
 local g=General:new(extension,"hanqing_god__tiandan","god",5,5,General.Male)
 g:addSkills{"hqtiandan__chimai","hqtiandan__duangu","hqtiandan__cuipo"}
 Fk:loadTranslationTable{
  ["hanqing_god__tiandan"]="神田单",["#hanqing_god__tiandan"]="燎世的残炬",
  ["designer:hanqing_god__tiandan"]="食饿不赦",["illustrator:hanqing_god__tiandan"]="sier",
 }
end
return M

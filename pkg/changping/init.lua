local extension = Package:new("meng_changping_pack")
extension.extensionName = "meng_family"
extension:loadSkillSkelsByPath("./packages/meng_family/pkg/changping/skills")
require("packages.meng_family.pkg.changping.hejiang_util").install(extension)
local general = General:new(extension, "changping__wanghe", "meng_qin", 4, 4, General.Male)
general:addSkills { "changping__lianxi" }
local baiqi = General:new(extension, "changping__baiqi", "meng_qin", 4, 4, General.Male)
baiqi:addSkills { "changping__qijie", "changping__huiguo" }
local fanju = General:new(extension, "changping__fanju", "meng_qin", 3, 3, General.Male)
fanju:addSkills { "changping__yazi", "changping__qingwei" }
-- A definition for Qingwei only, without adding cards to the deck.
extension:loadCardSkels { fk.CreateCard {
  name="changping__sincere_treat",type=Card.TypeTrick,
  skill="changping__sincere_treat_skill",
} }
local yingji = General:new(extension, "changping__yingji", "meng_qin", 4, 4, General.Male)
yingji:addSkills { "changping__yuanfa", "changping__tunshi", "changping__jueshi" }
extension:loadCardSkels { fk.CreateCard {
  name="changping__enemy_at_the_gates",type=Card.TypeTrick,
  skill="changping__enemy_at_the_gates_skill",
} }
local lianpo = General:new(extension, "changping__lianpo", "meng_zhao", 4, 4, General.Male)
lianpo:addSkills { "changping__zhulei", "changping__beishi" }
local zhaokuo=General:new(extension,"changping__zhaokuo","meng_zhao",5,5,General.Male)
zhaokuo:addSkills{"changping__kongtan"}
local linxiangru=General:new(extension,"changping__linxiangru","meng_zhao",3,3,General.Male)
linxiangru:addSkills{"changping__hejiang","changping__guibi"}
local zhaodan=General:new(extension,"changping__zhaodan","meng_zhao",3,3,General.Male)
zhaodan:addSkills{"changping__zeshuai","changping__zhuimeng","changping__xiaocheng"}
extension:loadCardSkels{fk.CreateCard{name="changping__zhaoshuaifu",type=Card.TypeEquip,sub_type=Card.SubtypeTreasure,equip_skill="#changping__zhaoshuaifu_skill"}}
local dreamZhaokuo=General:new(extension,"dream__zhaokuo","meng_zhao",4,4,General.Male)
dreamZhaokuo:addSkills{"dream__pishi","dream__xiwei"}
dreamZhaokuo:addRelatedSkill("dream__yiqi")
Fk:loadTranslationTable {
 ["dream__zhaokuo"]="梦赵括",["#dream__zhaokuo"]="逆转长平",
 ["designer:dream__zhaokuo"]="头发好借好还",["illustrator:dream__zhaokuo"]="黑羽C",
 ["changping__zhaodan"]="赵丹",["#changping__zhaodan"]="无断的坠龙",
 ["designer:changping__zhaodan"]="头发好借好还",["illustrator:changping__zhaodan"]="黄球球",
 ["changping__zhaokuo"]="赵括",["#changping__zhaokuo"]="纸上谈兵",
 ["changping__linxiangru"]="蔺相如",["#changping__linxiangru"]="智挟虎狼",
 ["designer:changping__zhaokuo"]="苍苍苍淇",["illustrator:changping__zhaokuo"]="有硬币有果",
 ["designer:changping__linxiangru"]="苍苍苍淇",["illustrator:changping__linxiangru"]="有硬币有果",
  ["meng_zhao"]="赵",
  ["changping__lianpo"]="廉颇", ["#changping__lianpo"]="君心难守",
  ["designer:changping__lianpo"]="头发好借好还",
  ["illustrator:changping__lianpo"]="有硬币有果",
  ["changping__yingji"]="嬴稷", ["#changping__yingji"]="东出的霸主",
  ["designer:changping__yingji"]="黑寡妇无敌",
  ["illustrator:changping__yingji"]="有硬币有果",
  ["changping__fanju"]="范雎", ["#changping__fanju"]="谋倾九州",
  ["designer:changping__fanju"]="苍苍苍淇",
  ["illustrator:changping__fanju"]="梦想君j",
  ["changping__baiqi"] = "白起",
  ["#changping__baiqi"] = "血铸国命",
  ["designer:changping__baiqi"] = "头发好借好还",
  ["illustrator:changping__baiqi"] = "特异型安妮",
  ["meng_changping_pack"] = "喋血长平",
  ["changping__wanghe"] = "王龁",
  ["#changping__wanghe"] = "秦锋",
  ["designer:changping__wanghe"] = "苍苍苍淇",
  ["illustrator:changping__wanghe"] = "特异型安妮",
}
return extension

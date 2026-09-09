local extension = Package:new("meng_changping_pack")
extension.extensionName = "meng_family"
extension:loadSkillSkelsByPath("./packages/meng_family/pkg/changping/skills")
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
Fk:loadTranslationTable {
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

local extension = Package:new("meng_xingming_pack")
extension.extensionName = "meng_family"
extension:loadSkillSkelsByPath("./packages/meng_family/pkg/xingming/skills")

-- Register future generals here.
Fk:loadTranslationTable{
 ["meng_xingming_pack"] = "刑名鉴正",
}
return extension

local extension = Package:new("meng_liuhe_pack")
extension.extensionName = "meng_family"
extension:loadSkillSkelsByPath("./packages/meng_family/pkg/liuhe/skills")

-- Register future generals here.
Fk:loadTranslationTable{
 ["meng_liuhe_pack"] = "六合一统",
}
return extension

local extension = Package:new("meng_zishi_pack")
extension.extensionName = "meng_family"
extension:loadSkillSkelsByPath("./packages/meng_family/pkg/zishi/skills")

-- Register future generals here.
Fk:loadTranslationTable{
 ["meng_zishi_pack"] = "生于紫室",
}
return extension

local extension = Package:new("meng_zongheng_pack")
extension.extensionName = "meng_family"
extension:loadSkillSkelsByPath("./packages/meng_family/pkg/zongheng/skills")

-- Register future generals here.
Fk:loadTranslationTable{
 ["meng_zongheng_pack"] = "纵横捭阖",
}
return extension

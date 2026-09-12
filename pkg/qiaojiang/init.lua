local extension = Package:new("meng_qiaojiang_pack")
extension.extensionName = "meng_family"
extension:loadSkillSkelsByPath("./packages/meng_family/pkg/qiaojiang/skills")

-- Register future generals here.
Fk:loadTranslationTable{
 ["meng_qiaojiang_pack"] = "巧匠益世",
}
return extension

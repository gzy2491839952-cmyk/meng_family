local extension = Package:new("huating_daxi_pack")
extension.extensionName = "meng_family"
extension:loadSkillSkelsByPath("./packages/meng_family/pkg/daxi/skills")
local general = General:new(extension, "daxi__zhangxianzhong", "huating_daxi", 4, 4, General.Male)
general:addSkills { "daxi__qisha", "daxi__bawang", "daxi__jianxi" }
local ainengqi = General:new(extension, "daxi__ainengqi", "huating_daxi", 4, 4, General.Male)
ainengqi:addSkills { "daxi__shewei" }
local sunkewang = General:new(extension, "daxi__sunkewang", "huating_daxi", 4, 4, General.Male)
sunkewang:addSkills { "daxi__xuanshi", "daxi__jiaodu" }
local liuwenxiu = General:new(extension, "daxi__liuwenxiu", "huating_daxi", 4, 4, General.Male)
liuwenxiu:addSkills { "daxi__qiulan", "daxi__jihui" }
Fk:loadTranslationTable {
  ["daxi__liuwenxiu"] = "刘文秀",
  ["#daxi__liuwenxiu"] = "晦夜孤旌",
  ["designer:daxi__liuwenxiu"] = "屑",
  ["illustrator:daxi__liuwenxiu"] = "黄球球",
  ["cv:daxi__liuwenxiu"] = "暂无",
  ["daxi__sunkewang"] = "孙可望",
  ["#daxi__sunkewang"] = "秦晋难好",
  ["designer:daxi__sunkewang"] = "屑",
  ["illustrator:daxi__sunkewang"] = "sier",
  ["cv:daxi__sunkewang"] = "暂无",
  ["daxi__ainengqi"] = "艾能奇",
  ["#daxi__ainengqi"] = "翼折三迆",
  ["designer:daxi__ainengqi"] = "头发好借好还",
  ["illustrator:daxi__ainengqi"] = "sier",
  ["cv:daxi__ainengqi"] = "暂无",
  ["huating_daxi_pack"] = "骁勍大西",
  ["huating_daxi"] = "大西",
  ["daxi"] = "西",
  ["daxi__zhangxianzhong"] = "张献忠",
  ["#daxi__zhangxianzhong"] = "嗜杀的黄虎",
  ["designer:daxi__zhangxianzhong"] = "kami",
  ["illustrator:daxi__zhangxianzhong"] = "摩羯",
  ["cv:daxi__zhangxianzhong"] = "暂无",
}
return extension

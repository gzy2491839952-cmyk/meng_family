local extension = Package:new("meng_family_generals")
extension.extensionName = "meng_family"
extension:loadSkillSkelsByPath("./packages/meng_family/pkg/meng/skills")

local general = General:new(extension, "meng__mengtianmengyi", "meng_qin", 4, 4, General.Male)
general:addSkills { "meng__gongyao", "meng__diewang" }

local huhai = General:new(extension, "meng__huhai", "meng_qin", 3, 4, General.Male)
huhai:addSkills { "meng__lanzheng", "meng__siyu", "meng__qianwang" }

local fusu = General:new(extension, "meng__fusu", "meng_qin", 4, 4, General.Male)
fusu:addSkills { "meng__renjian", "meng__fenyi" }

Fk:loadTranslationTable {
  ["meng__fusu"] = "扶苏",
  ["#meng__fusu"] = "孤德悲风",
  ["designer:meng__fusu"] = "头发好借好还",
  ["illustrator:meng__fusu"] = "特异型安妮",
  ["cv:meng__fusu"] = "暂无",
  ["meng_family_generals"] = "华亭鹤唳",
  ["meng"] = "秦",
  ["meng_qin"] = "秦",
  ["meng__mengtianmengyi"] = "蒙恬蒙毅",
  ["#meng__mengtianmengyi"] = "帝国双璧",
  ["designer:meng__mengtianmengyi"] = "头发好借好还",
  ["illustrator:meng__mengtianmengyi"] = "黄球球",
  ["cv:meng__mengtianmengyi"] = "暂无",
  ["meng__huhai"] = "胡亥",
  ["#meng__huhai"] = "天下嚣嚣",
  ["designer:meng__huhai"] = "头发好借好还",
  ["illustrator:meng__huhai"] = "XXX",
  ["cv:meng__huhai"] = "暂无",
}
return extension

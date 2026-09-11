local extension=Package:new("meng_weekly_pack")
extension.extensionName="meng_family"
extension:loadSkillSkelsByPath("./packages/meng_family/pkg/weekly/skills")
local general=General:new(extension,"weekly__kuangzhang","meng_qi",4,4,General.Male)
general:addSkills{"weekly__chenxu","weekly__zaowei"}
local zhengguo=General:new(extension,"weekly__zhengguo","meng_qin",4,4,General.Male)
zhengguo.subkingdom="meng_han"
zhengguo:addSkills{"weekly__zaoqu"}
local feiyi=General:new(extension,"weekly__feiyi","meng_zhao",3,3,General.Male)
feiyi:addSkills{"weekly__zhuojian","weekly__jieming"}
local gaojianli=General:new(extension,"weekly__gaojianli","meng_yan",4,4,General.Male)
gaojianli:addSkills{"weekly__zhuangxing","weekly__juezhu"}
Fk:loadTranslationTable{
 ["meng_yan"]="燕",["weekly__gaojianli"]="高渐离",["#weekly__gaojianli"]="鸣筑一掷",
 ["designer:weekly__gaojianli"]="MIRACLE☆",["illustrator:weekly__gaojianli"]="采藤",
 ["weekly__feiyi"]="肥义",["#weekly__feiyi"]="武灵股肱",
 ["designer:weekly__feiyi"]="临渊",["illustrator:weekly__feiyi"]="banana",
 ["meng_han"]="韩",
 ["weekly__zhengguo"]="郑国",["#weekly__zhengguo"]="疲秦硕渠",
 ["designer:weekly__zhengguo"]="玄不可注",["illustrator:weekly__zhengguo"]="banana",
 ["meng_weekly_pack"]="周赛",["meng_qi"]="齐",
 ["weekly__kuangzhang"]="匡章",["#weekly__kuangzhang"]="累战齐威",
 ["designer:weekly__kuangzhang"]="可余雪",["illustrator:weekly__kuangzhang"]="啪啪三国",
}
return extension

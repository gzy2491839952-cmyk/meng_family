local extension = Package:new("meng_zhulv_pack")
extension.extensionName = "meng_family"
extension:loadSkillSkelsByPath("./packages/meng_family/pkg/zhulv/skills")
local tianwen = General:new(extension, "zhulv__tianwen", "meng_qi", 3, 3, General.Male)
tianwen:addSkills{"zhulv__quzong", "zhulv__shiyi", "zhulv__zhenxi"}
local weiwuji = General:new(extension, "zhulv__weiwuji", "meng_wei", 4, 4, General.Male)
weiwuji:addSkills{"zhulv__huimei"}
local zhaosheng = General:new(extension, "zhulv__zhaosheng", "meng_zhao", 3, 3, General.Male)
zhaosheng:addSkills{"zhulv__qianche", "zhulv__choufeng"}
local huangxie = General:new(extension, "zhulv__huangxie", "meng_chu", 4, 4, General.Male)
huangxie:addSkills{"zhulv__yilue", "zhulv__xunyi"}
local tiandi = General:new(extension, "dream__tiandi", "meng_qi", 4, 4, General.Male)
tiandi:addSkills{"dream__pianxiang", "dream__pizhi", "dream__tunmeng", "dream__lingjue"}
Fk:loadTranslationTable{
 ["dream__tiandi"]="梦田地", ["#dream__tiandi"]="齐始皇",
 ["designer:dream__tiandi"]="食马者", ["illustrator:dream__tiandi"]="美术生啊",
 ["meng_chu"]="楚",
 ["zhulv__huangxie"]="黄歇", ["#zhulv__huangxie"]="春申君",
 ["designer:zhulv__huangxie"]="拉普拉斯", ["illustrator:zhulv__huangxie"]="有硬币有果",
 ["meng_zhulv_pack"]="珠履三千",
 ["zhulv__tianwen"]="田文", ["#zhulv__tianwen"]="孟尝君",
 ["designer:zhulv__tianwen"]="拉普拉斯", ["illustrator:zhulv__tianwen"]="有硬币有果",
 ["zhulv__weiwuji"]="魏无忌", ["#zhulv__weiwuji"]="信陵君",
 ["designer:zhulv__weiwuji"]="易大剧", ["illustrator:zhulv__weiwuji"]="不爱吃&有硬币有果",
 ["zhulv__zhaosheng"]="赵胜", ["#zhulv__zhaosheng"]="平原君",
 ["designer:zhulv__zhaosheng"]="yyuan", ["illustrator:zhulv__zhaosheng"]="黄球球",
 ["@zhulv_revealed"]="明置",
}
return extension

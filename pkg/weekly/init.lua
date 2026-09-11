local extension=Package:new("meng_weekly_pack")
extension.extensionName="meng_family"
extension:loadSkillSkelsByPath("./packages/meng_family/pkg/weekly/skills")
-- Slot-only virtual equipment: no equipped skill, no mount distance modifier.
local yifuSlots=require "packages.meng_family.pkg.weekly.zhaoyong"
local slotCards={}
for _,subtype in ipairs(yifuSlots.slots)do
 table.insert(slotCards,fk.CreateCard{name="weekly__yifu_slot"..subtype,type=Card.TypeEquip,
  sub_type=subtype,attack_range=1,
  dynamic_name=function(card,player,lang)
   local id=card.subcards[1]
   return id and Fk:translate(Fk:getCardById(id,true).name,lang) or Fk:translate(card.name,lang)
  end})
end
extension:loadCardSkels(slotCards)
local zhaoyong=General:new(extension,"weekly__zhaoyong","meng_zhao",4,4,General.Male)
zhaoyong:addSkills{"weekly__yifu","weekly__tanqin","weekly__yangxiong"}
local longyangjun=General:new(extension,"weekly__longyangjun","meng_wei",3,3,General.Male)
longyangjun:addSkills{"weekly__aili","weekly__suiliu"}
local general=General:new(extension,"weekly__kuangzhang","meng_qi",4,4,General.Male)
general:addSkills{"weekly__chenxu","weekly__zaowei"}
local zhengguo=General:new(extension,"weekly__zhengguo","meng_qin",4,4,General.Male)
zhengguo.subkingdom="meng_han"
zhengguo:addSkills{"weekly__zaoqu"}
local feiyi=General:new(extension,"weekly__feiyi","meng_zhao",3,3,General.Male)
feiyi:addSkills{"weekly__zhuojian","weekly__jieming"}
local gaojianli=General:new(extension,"weekly__gaojianli","meng_yan",4,4,General.Male)
gaojianli:addSkills{"weekly__zhuangxing","weekly__juezhu"}
local zhongwuyan=General:new(extension,"weekly__zhongwuyan","meng_qi",4,4,General.Female)
zhongwuyan:addSkills{"weekly__jianmei","weekly__suiwan"}
local hankui=General:new(extension,"weekly__hankui","meng_han",4,4,General.Male)
hankui:addSkills{"weekly__juanhuai","weekly__xiajian"}
Fk:loadTranslationTable{
 ["meng_wei"]="魏",
 ["weekly__zhaoyong"]="赵雍",["#weekly__zhaoyong"]="巡疆辟郡",
 ["designer:weekly__zhaoyong"]="鹭",["illustrator:weekly__zhaoyong"]="六龙争霸",
 ["weekly__longyangjun"]="龙阳君",["#weekly__longyangjun"]="君泣江流",
 ["designer:weekly__longyangjun"]="shui",["illustrator:weekly__longyangjun"]="banana",
 ["weekly__zhongwuyan"]="钟无艳",["#weekly__zhongwuyan"]="智勇定齐",
 ["designer:weekly__zhongwuyan"]="食恶不赦",["illustrator:weekly__zhongwuyan"]="摩羯",
 ["weekly__hankui"]="韩傀",["#weekly__hankui"]="叱朝倾野",
 ["designer:weekly__hankui"]="皇埃及",["illustrator:weekly__hankui"]="豪杰banana",
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

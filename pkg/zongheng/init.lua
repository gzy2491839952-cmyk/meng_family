local extension=Package:new("meng_zongheng_pack")
extension.extensionName="meng_family"
extension:loadSkillSkelsByPath("./packages/meng_family/pkg/zongheng/skills")
extension:loadCardSkels{fk.CreateCard{name="hq__zongheng",type=Card.TypeTrick,skill="hq_zongheng_card",multiple_targets=true}}
extension:loadCardSkels{fk.CreateCard{name="hqzhangyi_light__slash",type=Card.TypeBasic,
 is_damage_card=true,damage_type="hanqing_light",skill="hqzhangyi_light_slash"}}
if not Fk:getDamageNature("hanqing_light")then Fk:addDamageNature("hanqing_light","hanqing_light_damage",true)end
-- Derived only: granted by the two alliance skill types, not added to the deck.
local g=General:new(extension,"zongheng__zhangyi","meng_qin",3,3,General.Male)
g:addSkills{"hqzhangyi__jidou","hqzhangyi__erxi","hq_alliance_convert"}
local gsy=General:new(extension,"zongheng__gongsunyan","meng_wei",3,3,General.Male)
gsy.subkingdom="meng_qin"
gsy:addSkills{"hqgsy__bingjin","hqgsy__guzhi","hq_alliance_convert"}
require("packages.meng_family.pkg.zongheng.alliance").install()
Fk:loadTranslationTable{
 ["zongheng__gongsunyan"]="公孙衍",["#zongheng__gongsunyan"]="犀首",
 ["designer:zongheng__gongsunyan"]="意何味",["illustrator:zongheng__gongsunyan"]="黄球球",
 ["meng_zongheng_pack"]="纵横捭阖",["zongheng__zhangyi"]="张仪",["#zongheng__zhangyi"]="登驾群材",
 ["designer:zongheng__zhangyi"]="点点",["illustrator:zongheng__zhangyi"]="哥达耀&小猫°",
 ["hq__zongheng"]="纵横捭阖",
 ["hqzhangyi_light__slash"]="光杀",[":hqzhangyi_light__slash"]="对目标造成1点光属性伤害。",
 ["hanqing_light_damage"]="光属性",
 [":hq__zongheng"]="出牌阶段，对至多两名角色使用。若其处于连横状态，重置其武将牌；否则，若其处于横置或合纵状态，其进入连横状态；否则其进入合纵状态。合纵和连横互斥，进入或切换这两种状态不会解除铁索连环。",
 ["@hq_alliance"]="纵横",["hq_hezong"]="合纵",["hq_lianheng"]="连横",
 ["@hq_shared_erxi"]="共享饵戏",
 [":@hq_shared_erxi"]="连横状态：视为拥有其他连横角色【饵戏】中捭阖描述前的效果。",
 ["#hq-alliance-nowin"]="%from 发动【饵戏·捭阖】，令此次拼点双方均视为没赢",
 ["#hq-jidou-prize"]="%from 最先使角色重置，获得此次【犄斗】的底牌",
}
return extension

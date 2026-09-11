local extension = Package:new("meng_shengmo_pack")
extension.extensionName = "meng_family"
Skill.HanqingReform = Skill.HanqingReform or "HanqingReform"
extension:loadSkillSkelsByPath("./packages/meng_family/pkg/shengmo/skills")
-- A genuine typeless Card prototype; no extra basic/trick/equipment type.
local book = fk.CreateCard{name="shengmo__shangjunshu"}
function book:createCardPrototype()
  local card = Card:new(self.spec.name, Card.NoSuit, 0)
  fk.readCardSpecToCard(card, {skill="shengmo__law_card_skill", is_passive=true})
  card.is_derived = true
  return card
end
extension:loadCardSkels{book}
require("packages.meng_family.pkg.shengmo.client").install()
local general = General:new(extension, "shengmo__shangyang", "meng_qin", 4, 4, General.Male)
general:addSkills{"shengmo__limu", "shengmo__dingfa"}
Fk:loadTranslationTable{
 ["meng_shengmo_pack"]="绳墨之度",
 ["shengmo__shangyang"]="商鞅", ["#shengmo__shangyang"]="鼎法革世",
 ["designer:shengmo__shangyang"]="o.0", ["illustrator:shengmo__shangyang"]="黄球球",
 ["HanqingReform"]="变革技",
 [":HanqingReform"]="拥有此技能的武将拥有专属律牌。变革技可将律牌置入指定位置；专属律牌均在游戏内时，此变革技不能发动。",
 ["shengmo_law"]="律", [":shengmo_law"]="无类型、点数、花色的特殊牌；以任意方式离开初始区域时，改为移出游戏。革制：律牌移出游戏后立即触发的效果。",
}
return extension

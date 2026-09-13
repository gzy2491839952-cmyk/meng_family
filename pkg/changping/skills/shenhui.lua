local skill=fk.CreateSkill{name="changping__shenhui"}
Fk:loadTranslationTable{
 ["changping__shenhui"]="神慧",
 [":changping__shenhui"]="你从多张不可见的牌中选择任意数量张牌时，你可以先观看其中双倍数量张牌，再从观看的牌中进行选择。",
 ["#hqshenhui-invoke"]="神慧：先查看双倍数量的暗牌，再确定本次选牌？",
 ["#hqshenhui-more"]="神慧：选择额外观看的暗牌",
 ["#hqshenhui-final"]="神慧：从已观看的牌中确定原定数量的牌",
}
return skill

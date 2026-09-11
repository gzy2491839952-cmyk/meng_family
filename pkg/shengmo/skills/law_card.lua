local skill=fk.CreateSkill{name="shengmo__law_card_skill"}
skill:addEffect("cardskill",{
 can_use=function()return false end,
})
return skill

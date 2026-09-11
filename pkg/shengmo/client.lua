-- Extension-local client adapter. Does not overwrite any engine files.
local M={}
-- Hide the suit/color overlay in UI data only. The law keeps NoSuit,
-- NoColor and number 0 for every rule, pattern, log and serialized move.
local function installLawAppearance()
  local function hide(data)
    if data and data.name=="shengmo__shangjunshu" and data.number==0 then
      data.suit=""
      data.color=""
    end
    return data
  end
  for _,module in ipairs{"ltk.client.util", "packages.freekill-core.ltk.client.util"} do
    local ok,util=pcall(require,module)
    if ok and type(util)=="table" and type(util.getCardData)=="function"
      and not util._hanqing_law_appearance then
      util._hanqing_law_appearance=true
      local original=util.getCardData
      function util:getCardData(...)
        return hide(original(self,...))
      end
    end
  end
  -- Virtual previews and Lua-created CardItems use __toqml instead of getCardData.
  if Card and Card.__toqml and not Card._hanqing_law_appearance then
    Card._hanqing_law_appearance=true
    local original=Card.__toqml
    function Card:__toqml(...)
      local data=original(self,...)
      if data and data.model then hide(data.model.prop) end
      return data
    end
  end
end
function M.install()
  installLawAppearance()
  local klass=Client
  if not klass or klass._hanqing_law_installed then return end
  klass._hanqing_law_installed=true
  local function register(client)
    client:addCallback("HanqingLawHandOrder",function(self,data)
      local player=self:getPlayerById(data[1]);if not player then return end
      local ids=data[2]
      player.player_cards[Player.Hand]=table.simpleClone(ids)
      if not Self or Self.id~=player.id then return end
      -- An in-place UI move preserves CardModels and selection state.
      -- It is deliberately NOT passed to Client:moveCards (no log/tracker changes).
      local visual={merged={{ids=ids,from=player.id,to=player.id,
        fromArea=Card.PlayerHand,toArea=Card.PlayerHand}},event_id=0}
      for _,id in ipairs(ids) do visual[tostring(id)]=true end
      self:notifyUI("MoveCards",visual)
      -- Same-area visual moves do not animate/reflow on their own.
      self:notifyUI("UpdateRequestUI",{_type="Room"})
    end)
  end
  local initialize=klass.initialize
  function klass:initialize(...)
    initialize(self,...)
    register(self)
  end
  if ClientInstance and ClientInstance.addCallback then register(ClientInstance) end
end
return M

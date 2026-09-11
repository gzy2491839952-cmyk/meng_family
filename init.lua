-- Capture only the module value: Lua 5.4 require also returns loader data.
Fk:loadTranslationTable { ["meng_family"] = "汗青" }
local extension = require "packages.meng_family.pkg.meng"
local daxi = require "packages.meng_family.pkg.daxi"
local xi = require "packages.meng_family.pkg.xi"
local changping = require "packages.meng_family.pkg.changping"
local weekly = require "packages.meng_family.pkg.weekly"
local packages = { extension, daxi, xi, changping, weekly }
-- Use a dedicated display key; preserve faction and state translations.
for _, pack in ipairs(packages) do
  for _, general in ipairs(pack.generals) do
    general.prefix = "meng_family"
  end
end
return packages

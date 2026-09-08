-- Capture only the module value: Lua 5.4 require also returns loader data.
Fk:loadTranslationTable { ["meng_family"] = "汗青" }
local extension = require "packages.meng_family.pkg.meng"
local daxi = require "packages.meng_family.pkg.daxi"
local xi = require "packages.meng_family.pkg.xi"
return { extension, daxi, xi }

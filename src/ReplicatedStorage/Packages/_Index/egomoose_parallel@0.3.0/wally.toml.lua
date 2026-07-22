return {
  ["dependencies"] = {
  ["Future"] = "egomoose/future@1.0.0",
  ["Trove"] = "sleitnick/trove@=1.5.1",
},
  ["dev-dependencies"] = {
  ["Jest"] = "jsdotlua/jest@3.10.0",
  ["JestGlobals"] = "jsdotlua/jest-globals@3.10.0",
},
  ["package"] = {
  ["include"] = {
  [1] = "src",
  [2] = "src/**",
  [3] = "wally.toml",
  [4] = "wally.lock",
  [5] = "default.project.json",
  [6] = "LICENSE",
},
  ["registry"] = "https://github.com/UpliftGames/wally-index",
  ["description"] = "An abstraction layer for actor-based parallel execution on Roblox.",
  ["version"] = "0.3.0",
  ["repository"] = "https://github.com/EgoMoose/rbx-parallel",
  ["exclude"] = {
  [1] = "**",
},
  ["license"] = "MIT",
  ["name"] = "egomoose/parallel",
  ["realm"] = "shared",
},
}
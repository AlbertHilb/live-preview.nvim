local utils = require("livepreview.utils")

print("Test module livepreview.utils")

print()
print("supported_filetype()")
assert(utils.supported_filetype("test.html") == "html", "should return `html`")
assert(utils.supported_filetype("test.md") == "markdown", "should return `markdown`")
assert(utils.supported_filetype("test.markdown") == "markdown", "should return `markdown`")
assert(utils.supported_filetype("test.adoc") == "asciidoc", "should return `asciidoc`")
assert(utils.supported_filetype("test.asciidoc") == "asciidoc", "should return `asciidoc`")
assert(utils.supported_filetype("test.txt") == nil, "should return `nil`")
assert(utils.supported_filetype("test/test.html") == "html", "should return `html`")
assert(utils.supported_filetype("test/test.md") == "markdown", "should return `markdown`")
assert(utils.supported_filetype("test/test.markdown") == "markdown", "should return `markdown`")
assert(utils.supported_filetype("test/test.adoc") == "asciidoc", "should return `asciidoc`")
assert(utils.supported_filetype("test/test.asciidoc") == "asciidoc", "should return `asciidoc`")
assert(utils.supported_filetype("test/test.txt") == nil, "should return `nil`")
assert(utils.supported_filetype("test/test test with spaces.md") == "markdown", "should return `markdown`")

print()
print("get_plugin_path()")
vim.cmd.cd()
local plugin_path = utils.get_plugin_path()
assert(plugin_path:match("live%-preview%.nvim$"), "should return the path where live-preview.nvim is installed")
vim.cmd.cd("-")

print()
print("list_supported_files()")
local supported_files = utils.list_supported_files(plugin_path)
assert(
	type(supported_files) == "table" and #supported_files > 0,
	"should return a table with values instead we get " .. type(supported_files)
)

print()
print("read_file()")
local raw_packspec = utils.read_file(vim.fs.joinpath(plugin_path, "pkg.json"))
assert(type(raw_packspec) == "string" and #raw_packspec > 0, "should return a string with content")
assert(vim.json.decode(raw_packspec), "The content of pkg.json should be a valid JSON string")

print()
print("get_relative_path()")
local relative_path =
	utils.get_relative_path("/home/user/.config/nvim/lua/livepreview/utils.lua", "/home/user/.config/nvim/")
assert(relative_path == "lua/livepreview/utils.lua", "should return the relative path")

print()
print("is_absolute_path()")
assert(utils.is_absolute_path("/home/user/.config/nvim/lua/livepreview/utils.lua"), "should return true in Unix")
assert(
	utils.is_absolute_path("C:\\Users\\user\\AppData\\Local\\nvim\\lua\\livepreview\\utils.lua"),
	"should return true in Windows"
)
assert(not utils.is_absolute_path("lua/livepreview/utils.lua"), "should return false")

------------------------------------------------------------------------------------------------------------------------------
print()
local health = require("livepreview.health")

print("Test module livepreview.health")

print()
print("spec()")
assert(type(health.spec()) == "table", "should return a table")

print()
print("Test module livepreview.template - assets")
local template = require("livepreview.template")
local cfg = require("livepreview.config")
cfg.set({
	assets = {
		markdown = { css = { "/tmp/custom-md.css" }, js = { "/tmp/custom-md.js" } },
		asciidoc = { css = "/tmp/custom-adoc.css", js = "/tmp/custom-adoc.js" },
		html = { css = "/tmp/custom-html.css", js = "/tmp/custom-html.js" },
		svg = { js = "/tmp/custom-svg.js" },
	},
})

local md_html = template.md2html("# hi")
assert(md_html:match('<link rel="stylesheet" href="/tmp/custom%-md%.css">'), "markdown custom css injected")
assert(md_html:match('<script defer src="/tmp/custom%-md%.js"></script>'), "markdown custom js injected")

local adoc_html = template.adoc2html("= hi")
assert(adoc_html:match('<link rel="stylesheet" href="/tmp/custom%-adoc%.css">'), "asciidoc custom css injected")
assert(adoc_html:match('<script defer src="/tmp/custom%-adoc%.js"></script>'), "asciidoc custom js injected")

local html_out = template.handle_body("<html><head></head><body></body></html>")
assert(html_out:match('<link rel="stylesheet" href="/tmp/custom%-html%.css">'), "html custom css injected")
assert(html_out:match('<script defer src="/tmp/custom%-html%.js"></script>'), "html custom js injected")

local svg_out = template.svg2html("<svg></svg>")
assert(svg_out:match('<script defer src="/tmp/custom%-svg%.js"></script>'), "svg custom js injected")

cfg.set({ assets = {} })


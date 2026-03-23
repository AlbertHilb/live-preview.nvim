local M = {}

local config = require("livepreview.config").config
local assets = config.assets or {}

-- HTML escape function using table-based substitution for better performance
local html_escapes = {
	["&"] = "&amp;",
	["<"] = "&lt;",
	[">"] = "&gt;",
	['"'] = "&quot;",
	["'"] = "&#39;",
}

local function assets(type, paths, base_path)
	local result = ""
	for _, path in ipairs(paths) do
		if type == "css" then
			result = result .. '<link rel="stylesheet" href="/live-preview.nvim/' .. base_path .. '/' .. html_escape(path) .. '">'
		elseif type == "js" then
			result = result .. '<script defer src="/live-preview.nvim/' .. base_path .. '/' .. html_escape(path) .. '"></script>'
		end
	end
	return result
end

local function html_escape(text)
	if not text or text == "" then
		return ""
	end
	-- Use table lookup which is faster than multiple gsub calls
	return (text:gsub("[&<>\"']", html_escapes))
end

local html_template = function(body, stylesheet, script_tag)
	return [[
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Live preview</title>
]] .. stylesheet .. [[
			<link rel="stylesheet" href="/live-preview.nvim/static/katex/katex.min.css">	
            <script defer src="/live-preview.nvim/static/katex/katex.min.js"></script>
            <script src="/live-preview.nvim/static/mermaid/mermaid.min.js"></script>
			<link rel="stylesheet" href="/live-preview.nvim/static/highlight/main.css">
			<script defer src="/live-preview.nvim/static/highlight/highlight.min.js"></script>
			<style>
				.katex-display{margin:1em 0;text-align:center;overflow-x:auto;overflow-y:hidden}
				.katex{font-size:1.21em}
				.katex .array{border-collapse:collapse}
				.katex .array>tbody>tr>td{padding:0}
				.katex .delimsizing{font-family:KaTeX_Size1,KaTeX_Size2,KaTeX_Size3,KaTeX_Size4,serif}
			</style>
]] .. script_tag .. [[
			<script defer src='/live-preview.nvim/static/ws-client.js'></script>
        </head>

        <body>
            <div class="markdown-body">
]] .. body .. [[
            </div>
            <script defer src="/live-preview.nvim/static/mermaid/main.js"></script>
        </body>
        </html>
    ]]
end

M.md2html = function(md)
	local js = {
		"markdown/line-numbers.js",
		"markdown/markdown-it-emoji.min.js",
		"markdown/markdown-it.min.js",
		"markdown/markdown-it-katex.js",
		"markdown/main.js"
	}
	local user_js = assets.markdown and assets.markdown.js or {}
	local css = {
		"markdown/github-markdown.min.css"
	}
	local user_css = assets.markdown and assets.markdown.css or {}

	return html_template(html_escape(md), assets('css', css, 'static') .. assets('css', user_css, 'static/user'), assets('js', js, 'static') .. assets('js', user_js, 'static/user'))
end

M.adoc2html = function(adoc)
	local js = {
		"static/asciidoc/asciidoctor.min.js",
		"static/asciidoc/main.js"
	}
	local user_js = assets.asciidoc and assets.asciidoc.js or {}
	local css = {
		"static/asciidoc/asciidoctor.min.css"
	}
	local user_css = assets.asciidoc and assets.asciidoc.css or {}

	return html_template(adoc, assets('css', css, 'static') .. assets('css', user_css, 'static/user'), assets('js', js, 'static') .. assets('js', user_js, 'static/user'))
end

M.svg2html = function(svg)
	local user_css = assets.svg and assets.svg.css or {}
	local user_js = assets.svg and assets.svg.js or {}
	return "<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"><title>Live preview</title>"
		.. assets('css', user_css, 'static/user')
		.. "<script defer src='/live-preview.nvim/static/ws-client.js'></script>"
		.. assets('js', user_js, 'static/user')
		.. "</head><body><div class='markdown-body'>"
		.. svg:gsub("<%?xml[^>]*%?>%s*", "")
		.. "</div></body></html>"
end

M.toHTML = function(text, filetype)
	if filetype == "markdown" then
		return M.md2html(text)
	elseif filetype == "asciidoc" then
		return M.adoc2html(text)
	elseif filetype == "svg" then
		return M.svg2html(text)
	end
end

M.handle_body = function(data)
	local ws_script = "<script src='/live-preview.nvim/static/ws-client.js'></script>"
	local user_css = assets.html and assets.html.css or {}
	local user_js = assets.html and assets.html.js or {}
	local body
	if data:match("<head>") then
		body = data:gsub("<head>", "<head>" .. assets('css', user_css, 'static/user') .. ws_script .. assets('js', user_js, 'static/user'))
	else
		body = "<head>" .. assets('css', user_css, 'static/user') .. ws_script .. assets('js', user_js, 'static/user') .. "</head>" .. data
	end
	return body
end

return M

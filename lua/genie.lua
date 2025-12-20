--@field config GenieConfig
local Genie = {}

--@field URL ollama api url
--@field model ollama model
local Config = {}

function Genie:get_context()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	local prompt_context = vim.fn.getregion(start_pos, end_pos)
	return prompt_context
end

function Genie:generate_snippet()
	-- local prompt_context = self:get_context()
	local curl = require("plenary.curl")
	local lang = vim.api.nvim_get_option_value("filetype", {})
	local prompt_code = table.concat(self:get_context(), "\n")
	vim.print(prompt_code)
	local parser = vim.treesitter.get_string_parser(prompt_code, lang)
	local tree = parser:parse(true)[1]

	local query = vim.treesitter.query.parse(
		lang,
		[[
            (comment)@comment
        ]]
	)

	for id, node, metadata in query:iter_captures(tree:root(), prompt_code) do
		-- Print the node name and source text.
		vim.print({ node:type(), vim.treesitter.get_node_text(node, prompt_code) })
	end

	local prompt = {
		model = "codegemma:2b",
		prompt = parser:parse(),
		stream = false,
	}
	local result = curl.post(self.config.URL, { body = vim.json.encode(prompt) })
	if result.exit ~= 0 or result.status ~= 200 then
		vim.notify("API error", vim.log.levels.ERROR)
	else
		local response = vim.json.decode(result.body)
		vim.print(response.response)
	end
end

function Genie.setup(self, opts)
	if self ~= Genie then
		opts = self
		self = Genie
	end
	Config.URL = opts.URL
	Config.model = opts.model
	self.config = Config
	vim.api.nvim_create_user_command("GenieGen", function()
		self:generate_snippet()
	end, {})
end

return Genie

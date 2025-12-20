local M = {}

--@return start_pos, end_pos
function M.get_visual_selection()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	-- get the start and end line number
	return start_pos[2], end_pos[2]
end

--@return text string[]
function M.get_prompt_code(buf, start_pos, end_pos)
	local prompt_code = vim.api.nvim_buf_get_lines(buf, start_pos, end_pos + 1, true)
	return table.concat(prompt_code, "\n")
end

--@param buf integer
--@param row integer
--@param col integer
--@param text string[]
function M.insert_code(buf, row, col, text)
	vim.api.nvim_buf_set_text(buf, row, col, row, col, text)
end

return M

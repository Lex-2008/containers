fromdom = odkim.get_fromdomain(ctx)
odkim.log(ctx, "mail from domain: " .. fromdom)
if fromdom == "shpakovsky.ru" then
	allrcpts = odkim.get_rcptarray(ctx)
	-- odkim.log(ctx, "all rcpts: " .. table.concat(allrcpts, ", "))
	for n, rcpt in ipairs(allrcpts) do
		-- odkim.log(ctx, "rcpt " .. n .. " is: " .. rcpt)
		-- if string.find(rcpt, "port25", 1, true) ~= nil then
		if string.find(rcpt, "mailop.org", 1, true) ~= nil then
			odkim.log(ctx, "receiver would benefit from changing From header: " .. rcpt)
			odkim.log(ctx, odkim.get_header(ctx, "From", 0))
			odkim.replace_header(ctx, "From", 0, "Alexey Shpakovsky via mailop <mailop@mailop.org>")
			-- return nil
		end
	end
end

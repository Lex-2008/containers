fromdom = odkim.get_fromdomain(ctx)
odkim.log(ctx, "mail from domain: " .. fromdom)
if fromdom == "shpakovsky.ru" then
	nrcpts = odkim.rcpt_count(ctx)
	for n = 1, nrcpts do
		rcpt = odkim.get_rcpt(ctx, n - 1)
		if string.find(rcpt, "mailop.org", 1, true) ~= nil then
			odkim.log(ctx, "receiver would benefit from changing From header: " .. rcpt)
			odkim.replace_header(ctx, "From", 0, "Alexey Shpakovsky via mailop <mailop@mailop.org>")
			-- return nil
		end
	end
end

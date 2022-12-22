import JSON3

function hfun_bar(vname)
    val = Meta.parse(vname[1])
    return round(sqrt(val), digits=2)
end

function hfun_m1fill(vname)
    var = vname[1]
    return pagevar("index", var)
end

function lx_baz(com, _)
    # keep this first line
    brace_content = Franklin.content(com.braces[1]) # input string
    # do whatever you want here
    return uppercase(brace_content)
end

function papersjson()
    JSON3.read(read(joinpath(@__DIR__, "papers.json"), String))
end

function hfun_papers()
    papersjson()["papers"]
end

function withauthors(paper)
	c = IOBuffer()
	if isempty(paper.coauthors)
		# write(c, "")
	else
		write(c, " (with ")
		for i in 1:length(paper.coauthors)
			a = paper.coauthors[i]
			if i == 1 
				prefix = " "
			elseif i == length(paper.coauthors)
				prefix = " and "
			else
				prefix = ", "
			end

			# write(c, """$prefix<a href="$(a.website)" target="_blank">$(a.name)</a>""")
			write(c, "$prefix [$(a.name)]($(a.website))")
		end
		write(c, ")")
	end
	String(take!(c))
end

function paperstatus(c, p)
	pub = p.publication
	write(c, "*")
	if isempty(pub)
		write(c, "Working paper")
	else
		write(c, pub)
	end

	# add cite
	write(c, " | [Citation](javascript:cite($(p.url)); return false;)* \n")
end

function papertitle(c, p)
	write(c, "#### [$(p.title)]($(p.url)) \\style{font-weight:normal}{$(withauthors(p))}\n")
end

function hfun_data()
	papers = papersjson()["papers"]
	ix = haskey.(papers, "data")
	c = IOBuffer()
	for p in papers[ix]
		write(c, "#### [$(p.title)]($(p.url)) \\style{font-weight:normal}{$(withauthors(p))}\n")
		paperstatus(c, p)
		for d in p.data
			write(c, "* [$(d.text)]($(d.link)) $(d.comment)\n")
		end
	end
	write(c, "\n")
	markdown = String(take!(c))
	return fd2html(markdown, internal=true)
end

function hfun_papers(sections)
	papers = papersjson()["papers"]
	ix = [in(p.section, sections) for p in papers]
	c = IOBuffer()
	for p in papers[ix]
		papertitle(c, p)
		paperstatus(c, p)
		# paperabstract(c, p)
	end
	write(c, "\n")
	markdown = String(take!(c))
	return fd2html(markdown, internal=true)
end

hfun_social_email() = """<a href="mailto:amanela@wustl.edu" title="email"><svg width="30" height="30" viewBox="0 0 24 24"><path fill="currentColor" d="M12 12.713l-11.985-9.713h23.971l-11.986 9.713zm-5.425-1.822l-6.575-5.329v12.501l6.575-7.172zm10.85 0l6.575 7.172v-12.501l-6.575 5.329zm-1.557 1.261l-3.868 3.135-3.868-3.135-8.11 8.848h23.956l-8.11-8.848z"/></svg></a>"""

hfun_social_linkedin() = """<a href="https://linkedin.com/in/asafmanela" title="linkedin"><svg width="30" height="30" viewBox="0 50 512 512"><path fill="currentColor" d="M150.65 100.682c0 27.992-22.508 50.683-50.273 50.683-27.765 0-50.273-22.691-50.273-50.683C50.104 72.691 72.612 50 100.377 50c27.766 0 50.273 22.691 50.273 50.682zm-7.356 86.651H58.277V462h85.017V187.333zm135.901 0h-81.541V462h81.541V317.819c0-38.624 17.779-61.615 51.807-61.615 31.268 0 46.289 22.071 46.289 61.615V462h84.605V288.085c0-73.571-41.689-109.131-99.934-109.131s-82.768 45.369-82.768 45.369v-36.99z"/></svg></a>"""

hfun_social_github() = """<a href="https://twitter.com/AsafManela" title="twitter"><svg width="30" height="30" viewBox="0 0 25 25" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22"/></svg></a>"""

hfun_social_twitter() = """<a href="https://github.com/AsafManela" title="github"><svg width="30" height="30" viewBox="0 0 335 276" fill="currentColor"><path d="M302 70A195 195 0 0 1 3 245a142 142 0 0 0 97-30 70 70 0 0 1-58-47 70 70 0 0 0 31-2 70 70 0 0 1-57-66 70 70 0 0 0 28 5 70 70 0 0 1-18-90 195 195 0 0 0 141 72 67 67 0 0 1 116-62 117 117 0 0 0 43-17 65 65 0 0 1-31 38 117 117 0 0 0 39-11 65 65 0 0 1-32 35"/></svg></a>"""

hfun_social_scholar() = """<a href="https://scholar.google.com/citations?user=jXlDHhsAAAAJ&hl=en" title="scholar"><svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="30" height="30" x="0px" y="0px" viewBox="0 0 122.88 122.88" fill="currentColor" style="enable-background:new 0 0 122.88 122.88" xml:space="preserve"><style type="text/css"><![CDATA[
	.st0{fill:#356AC3;}
	.st1{fill:#A0C3FF;}
	.st2{fill:#76A7FA;}
	.st3{fill:#4285F4;}
]]></style><g><polygon class="st3" points="61.44,98.67 0,48.64 61.44,0 61.44,98.67"/><polygon class="st0" points="61.44,98.67 122.88,48.64 61.44,0 61.44,98.67"/><path class="st1" d="M97.28,87.04c0-19.79-16.05-35.84-35.84-35.84c-19.79,0-35.84,16.05-35.84,35.84s16.05,35.84,35.84,35.84 C81.23,122.88,97.28,106.83,97.28,87.04L97.28,87.04z"/><path class="st2" d="M29.05,71.68C34.8,59.57,47.14,51.2,61.44,51.2c14.3,0,26.64,8.37,32.39,20.48H29.05L29.05,71.68z"/></g></svg></a>"""

hfun_social_scholar2() = """
	<a href="https://scholar.google.com/citations?user=jXlDHhsAAAAJ&hl=en" title="scholar">
		<svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="30" height="30" x="0px" y="0px" viewBox="0 0 122.88 122.88" fill="currentColor" xml:space="preserve">
		<g>
			<polygon points="61.44,98.67 0,48.64 61.44,0 61.44,98.67"/>
			<polygon points="61.44,98.67 122.88,48.64 61.44,0 61.44,98.67"/>
			<path d="M97.28,87.04c0-19.79-16.05-35.84-35.84-35.84c-19.79,0-35.84,16.05-35.84,35.84s16.05,35.84,35.84,35.84 C81.23,122.88,97.28,106.83,97.28,87.04L97.28,87.04z"/>
			<path d="M29.05,71.68C34.8,59.57,47.14,51.2,61.44,51.2c14.3,0,26.64,8.37,32.39,20.48H29.05L29.05,71.68z"/>
		</g>
		</svg>
	</a>"""

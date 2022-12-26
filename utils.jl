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

function urlanchor(url)
	replace(url, "/"=>"-")
end

function papersjson()
    JSON3.read(read(joinpath(@__DIR__, "papers.json"), String))
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

# status link handlers
function cite(c, p, l)
	write(c, " | [$(l.text)](javascript:$(l.type)('/papers/$(p.url)');)")
end

function slides(c, p, l)
	write(c, " | [$(l.text)](/papers/$(p.url)/$(l.type).pdf)")
end

function data(c, p, l)
	write(c, " | [$(l.text)](/data#$(urlanchor(p.url)))")
end

function wp(c, p, l)
	write(c, " | [$(l.text)](/papers/$(p.url)/$(l.type))")
end

# version used for any paper without a publication
function wp(c, p)
	write(c, "[Working Paper](/papers/$(p.url)/)")
end

function goto(c, p, l)
	write(c, " | [$(l.text)]($(l.page))")
end

# paper status blurb
function paperstatus(c, p; includedlinks=["cite", "slides", "data", "wp", "goto"])
	pub = p.publication
	write(c, "*")
	if isempty(pub)
		wp(c, p)
	else
		write(c, pub)
	end
	write(c, "*")

	for l in p.links
		if l.type in includedlinks
			linkfun = eval(Meta.parse(l.type))
			linkfun(c, p, l)
		end
	end

	write(c, "\n")
end

function papertitle(c, p)
	write(c, "### ~~~<a name=\"$(urlanchor(p.url))\"><a>~~~[$(p.title)]($(p.url)) \\style{font-weight:normal}{$(withauthors(p))}\n")
end

function hfun_data()
	papers = papersjson()["papers"]
	ix = haskey.(papers, "data")
	c = IOBuffer()
	for p in papers[ix]
		papertitle(c, p)
		paperstatus(c, p; includedlinks=["cite"])
		for d in p.data
			if startswith(d.link, "http")
				prefix = ""
			else
				prefix = "/papers/"
			end
			
			write(c, "* [$(d.text)]($prefix$(d.link)) $(d.comment)\n")
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

function discussionsjson()
    JSON3.read(read(joinpath(@__DIR__, "discussions.json"), String))
end

function hfun_discussions()
	discussions = discussionsjson()
	c = IOBuffer()
	for p in discussions
		write(c, "- [$(p.title)]($(p.url)) by $(p.authors)\n")
	end
	write(c, "\n")
	markdown = String(take!(c))
	return fd2html(markdown, internal=true)
end

function hfun_news(sections; n=2)
	papers = papersjson()["papers"]
	ix = [in(p.section, sections) && haskey(p, "feature") for p in papers] 
	c = IOBuffer()
	i = 1
	for p in papers[ix]
		write(c, """
		<div class="feature__item">
			<div class="archive__item">
			<div class="archive__item-teaser">
				<img src="/papers/$(p.url)/$(p.feature.figure)" alt="$(p.feature.caption)" />
			</div>
			<div class="archive__item-body">
				<h2 class="archive__item-title">$(p.feature.caption)</h2>
				<div class="archive__item-excerpt">
				<p>This figure is from a recent paper titled <i>$(p.title)</i>. $(p.abstract)</p>
				</div>
				<p><a href="/papers#$(urlanchor(p.url))" class="btn btn--primary">Learn more</a></p>
			</div>
			</div>
		</div>
		""")
		i+=1
		if i>n
			break
		end
	end
	return String(take!(c))
end

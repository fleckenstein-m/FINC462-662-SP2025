### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# ╔═╡ d160a115-56ed-4598-998e-255b82ec37f9
# ╠═╡ show_logs = false
#Set-up packages
begin
	#using Pkg
	#Pkg.upgrade_manifest()
	#Pkg.resolve()
	
	using DataFrames, HTTP,  Dates, PlutoUI, Printf, LaTeXStrings, HypertextLiteral

	#using Plots
	#gr();
	


	#Define html elements
	nbsp = html"&nbsp" #non-breaking space
	vspace = html"""<div style="margin-bottom:2cm;"></div>"""
	br = html"<br>"

	#Sets the height of displayed tables
	html"""<style>
		pluto-output.scroll_y {
			max-height: 650px; /* changed this from 400 to 550 */
		}
		"""
	
	#Two-column cell
	struct TwoColumn{A, B}
		left::A
		right::B
	end
	
	function Base.show(io, mime::MIME"text/html", tc::TwoColumn)
		write(io,
			"""
			<div style="display: flex;">
				<div style="flex: 50%;">
			""")
		show(io, mime, tc.left)
		write(io,
			"""
				</div>
				<div style="flex: 50%;">
			""")
		show(io, mime, tc.right)
		write(io,
			"""
				</div>
			</div>
		""")
	end

	#Creates a foldable cell
	struct Foldable{C}
		title::String
		content::C
	end
	
	function Base.show(io, mime::MIME"text/html", fld::Foldable)
		write(io,"<details><summary>$(fld.title)</summary><p>")
		show(io, mime, fld.content)
		write(io,"</p></details>")
	end
	
	
	#helper functions
	#round to digits, e.g. 6 digits then prec=1e-6
	roundmult(val, prec) = (inv_prec = 1 / prec; round(val * inv_prec) / inv_prec); 

	using Logging
	global_logger(NullLogger());
	display("")
end

# ╔═╡ a5de5746-3df0-45b4-a62c-3daf36f015a5
begin 
	html"""
	<p style="padding-bottom:0.01cm"> </p>
	<div align=center style="font-size:25px; font-family:family:Georgia"> FINC-462/662: Fixed Income Securities </div>
	<p style="padding-bottom:0.01cm"> </p>
	<p align=center style="font-size:25px; font-family:family:Georgia"> <b> Assignment 09
	</b> <p>
	<p style="padding-bottom:0.01cm"> </p>
	<p align=center style="font-size:25px; font-family:family:Georgia"> Spring 2025 </p>
	<p style="padding-bottom:0.01cm"> </p>
	<div align=center style="font-size:20px; font-family:family:Georgia"> Prof. Matt Fleckenstein </div>
	<p style="padding-bottom:0.01cm"> </p>
	<div align=center style="font-size:20px; font-family:family:Georgia"> University of Delaware, 
	Lerner College of Business and Economics </div>
	<p style="padding-bottom:0cm"> </p>
	"""
end

# ╔═╡ 3eeb383c-7e46-46c9-8786-ab924b475d45
# ╠═╡ show_logs = false
begin
 function getBondPrice(y,c,T,F)
	dt = collect(0.5:0.5:T)
	C = (c/200)*F
	CF = C.*ones(length(dt))
	CF[end] = F+C
	PV = CF./(1+y/200).^(2 .* dt)
	return sum(PV)
 end

 function getModDuration(y,c,T,F)
	P0 = getBondPrice(y,c,T,F)
	deltaY = 0.10 
	Pplus  = getBondPrice(y+deltaY,c,T,F)
	Pminus = getBondPrice(y-deltaY,c,T,F)
	return -(Pplus-Pminus)./(2 * deltaY * P0)
 end
 display("")
	
end

# ╔═╡ 9f9d1928-5806-46e9-8dab-2961da605826
vspace

# ╔═╡ 7ad75350-14a4-47ee-8c6b-6a2eac09ebb1
md"""
# Question 1
"""

# ╔═╡ caad8479-654b-4a15-a994-56c8764728c7
begin
	r05_2 = 2.00
	r10_2 = 3.00
	r15_2 = 3.50
	r20_2 = 3.00
	r25_2 = 4.00 
	r30_2 = 4.50
	r35_2 = 4.75
	r40_2 = 5.00
	r45_2 = 5.10
	r50_2 = 5.25
	
	rVec_2 = [r05_2,r10_2,r15_2,r20_2,r25_2,r30_2,r35_2,r40_2,r45_2,r50_2]
	
	f05_10_2 = 2*((1+r10_2/200)^(2*1.0)/(1+r05_2/200)^(2*0.5) -1)
	f10_15_2 = 2*((1+r15_2/200)^(2*1.5)/(1+r10_2/200)^(2*1.0) -1)
	f15_20_2 = 2*((1+r20_2/200)^(2*2.0)/(1+r15_2/200)^(2*1.5) -1)
	f20_25_2 = 2*((1+r25_2/200)^(2*2.5)/(1+r20_2/200)^(2*2.0) -1)
	f25_30_2 = 2*((1+r30_2/200)^(2*3.0)/(1+r25_2/200)^(2*2.5) -1)
	f30_35_2 = 2*((1+r35_2/200)^(2*3.5)/(1+r30_2/200)^(2*3.0) -1)
	f35_40_2 = 2*((1+r40_2/200)^(2*4.0)/(1+r35_2/200)^(2*3.5) -1)
	f40_45_2 = 2*((1+r45_2/200)^(2*4.5)/(1+r40_2/200)^(2*4.0) -1)
	f45_50_2 = 2*((1+r50_2/200)^(2*5.0)/(1+r45_2/200)^(2*4.5) -1)
	fVec_2 = [f05_10_2,f10_15_2,f15_20_2,f20_25_2,f25_30_2,f30_35_2,f35_40_2,f40_45_2,f45_50_2]

	
	f10_30_2 = (((1+r30_2/200)^(2*3)/(1+r10_2/200)^(2*1))^(1/(2*2))-1)*2
	f20_40_2 = (((1+r40_2/200)^(2*4)/(1+r20_2/200)^(2*2))^(1/(2*2))-1)*2
	f30_50_2 = (((1+r50_2/200)^(2*5)/(1+r30_2/200)^(2*3))^(1/(2*2))-1)*2

	f10_50_2 = (((1+r50_2/200)^(2*5)/(1+r10_2/200)^(2*1))^(1/(2*4))-1)*2
	f20_50_2 = (((1+r50_2/200)^(2*5)/(1+r20_2/200)^(2*2))^(1/(2*3))-1)*2
	
	
	strf05_10_2 = "2*((1+$(roundmult(r10_2/100,1e-6))/2)^{2*1.0}/(1+$(r05_2/100)/2)^{2*0.5} -1)"
	strf10_15_2 = "2*((1+$(roundmult(r15_2/100,1e-6))/2)^{2*1.5}/(1+$(r10_2/100)/2)^{2*1.0} -1)"
	strf15_20_2 = "2*((1+$(roundmult(r20_2/100,1e-6))/2)^{2*2.0}/(1+$(r15_2/100)/2)^{2*1.5} -1)"
	strf20_25_2 = "2*((1+$(roundmult(r25_2/100,1e-6))/2)^{2*2.5}/(1+$(r20_2/100)/2)^{2*2.0} -1)"
	strf25_30_2 = "2*((1+$(roundmult(r30_2/100,1e-6))/2)^{2*3.0}/(1+$(r25_2/100)/2)^{2*2.5} -1)"
	strf30_35_2 = "2*((1+$(roundmult(r35_2/100,1e-6))/2)^{2*3.5}/(1+$(r30_2/100)/2)^{2*3.0} -1)"
	strf35_40_2 = "2*((1+$(roundmult(r40_2/100,1e-6))/2)^{2*4.0}/(1+$(r35_2/100)/2)^{2*3.5} -1)"
	strf40_45_2 = "2*((1+$(roundmult(r45_2/100,1e-6))/2)^{2*4.5}/(1+$(r40_2/100)/2)^{2*4.0} -1)"
	strf45_50_2 = "2*((1+$(roundmult(r50_2/100,1e-6))/2)^{2*5.0}/(1+$(r45_2/100)/2)^{2*4.5} -1)"
	strfVec_2 = [strf05_10_2,strf10_15_2,strf15_20_2,strf20_25_2,strf25_30_2,strf30_35_2,strf35_40_2,strf40_45_2,strf45_50_2]
	html"""<hr>"""
end

# ╔═╡ 23bb9890-718d-42fd-a9fa-51b4a7994ed7
md"""
Suppose spot rates are as given below.

| Tenor $\,T$ | Spot Rate $\,r_t$      |
|:----------|:--------------------|
| 0.5-year  | $r_{0.5}$=$(r05_2)% |
| 1.0-year  | $r_{1.0}$=$(r10_2)%
| 1.5-year  | $r_{1.5}$=$(r15_2)%
| 2.0-year  | $r_{2.0}$=$(r20_2)%
| 2.5-year  | $r_{2.5}$=$(r25_2)%
| 3.0-year  | $r_{3.0}$=$(r30_2)%
| 3.5-year  | $r_{3.5}$=$(r35_2)%
| 4.0-year  | $r_{4.0}$=$(r40_2)%
| 4.5-year  | $r_{4.5}$=$(r45_2)%
| 5.0-year  | $r_{5.0}$=$(r50_2)%

"""

# ╔═╡ 238cfc9b-434a-426e-93e7-419314b7dc41
vspace

# ╔═╡ a473c4cd-0a21-493b-9ec5-55ea66a0ed99
Markdown.parse("
__1.__ Calculate the two-year forward rate starting one year from today (i.e., \$f_{1,3}\$).
")

# ╔═╡ 5d00ce86-142d-4740-91e1-73704382c366
Markdown.parse("
__2.__ Calculate the two-year forward rate starting two years from today (i.e., \$f_{2,4}\$).
")

# ╔═╡ 5f84a5be-dbea-4eab-ba5a-06b8062d5b4b
Markdown.parse("
__3.__ Calculate the two-year forward rate starting three years from today (i.e., \$f_{3,5}\$).
")

# ╔═╡ d74dd608-b367-43f3-b5f1-bd654e5f87e2
Markdown.parse("
__4.__ Calculate the 4-year forward rate starting one year from today (i.e., \$f_{1,5}\$).
")

# ╔═╡ 18252fe4-6aba-4b13-b6fb-6426bd9037ca
Markdown.parse("
__5.__ Calculate the 3-year forward rate starting two years from today (i.e., \$f_{2,5}\$).
")

# ╔═╡ 738b8f7a-3cfd-4792-89e7-96ba3f55be81
vspace

# ╔═╡ e3c1b782-7f23-4c50-af3c-91aa8af0a88e
md"""
# Question 2
"""

# ╔═╡ 3a4ba27e-26d7-40d9-8f9d-8f22535d9287
md"""
Suppose that you are given the following term structure of zero-coupon yields (spot rates). Assume interest rates are semi-annually compounded.

| Maturity | r     |  
|:---------|------:|
|0.5       | 0.02  |
|1         | 0.025 |
|1.5       | 0.03  |
|2         | 0.04  |


"""

# ╔═╡ 86478c8f-aeee-4085-ad39-af31f8c9c037
begin
	r05_3 = 2.00
	r10_3 = 2.50
	r15_3 = 3.00
	r20_3 = 4.00
		
	rVec_3 = [r05_3,r10_3,r15_3,r20_3,r25_2]
	
	f05_10_3 = 2*((1+r10_3/200)^(2*1.0)/(1+r05_3/200)^(2*0.5) -1)
	f10_15_3 = 2*((1+r15_3/200)^(2*1.5)/(1+r10_3/200)^(2*1.0) -1)
	f15_20_3 = 2*((1+r20_3/200)^(2*2.0)/(1+r15_3/200)^(2*1.5) -1)
	f05_20_3 = 2*( ((1+r20_3/200)^(2*2.0)/(1+r05_3/200)^(2*0.5))^(1/(2*1.5)) -1)
	
	fVec_3 = [f05_10_3,f10_15_3,f15_20_3,f05_20_3]

	
	strf05_10_3 = "2*((1+$(roundmult(r10_3/100,1e-6))/2)^{2*1.0}/(1+$(r05_3/100)/2)^{2*0.5} -1)"
	strf10_15_3 = "2*((1+$(roundmult(r15_3/100,1e-6))/2)^{2*1.5}/(1+$(r10_3/100)/2)^{2*1.0} -1)"
	strf15_20_3 = "2*((1+$(roundmult(r20_3/100,1e-6))/2)^{2*2.0}/(1+$(r15_3/100)/2)^{2*1.5} -1)"
	
	strf05_20_3 = "2*( ( (1+$(roundmult(r20_3/100,1e-6))/2)^{2*2.0}/(1+$(r05_3/100)/2)^{2*0.5} )^{1/(2*1.5)} -1)"
	
	 strfVec_3 = [strf05_10_3,strf10_15_3,strf15_20_3,strf05_20_3]
	html"""<hr>"""
end

# ╔═╡ f68b5afd-cf8f-4cba-ad7f-03fcc3f291af
md"""
**1.** From the given spot rates, calculate the forward rates, $f(0.5, 1)$, $f(1, 1.5)$, $f(1.5,2)$, and $f(0.5, 2)$.
"""

# ╔═╡ d419a379-712e-47a6-99ed-d8350fbc1000
vspace

# ╔═╡ 6d1be573-3b15-4a18-89d7-5d887cea7e84
md"""
**2.** Suppose that $f(1, 1.5) = 4.5$%. (This should be almost 0.5 percentage points higher
than what you found in Part 1 above.) Using this value for $f(1, 1.5)$ and the given zero-coupon yields, construct an arbitrage trading strategy to take advantage of this mispricing.
- *Hint: Calculate zero-coupon bond prices for maturities of 1-year and 1.5-years. Then create a synthetic forward contract before forming a strategy.*
"""

# ╔═╡ 9eae2846-7b22-4b6c-91db-ffa7cd67be92
vspace

# ╔═╡ f2ef9979-8f46-4d1d-a8fd-87d1bcb9abee
md"""
**3.** Suppose that we go back to Part 1. You enter into a forward rate agreement to lend \$100 at t = 0.5 and be repaid at t = 2 at the forward rate of $f(0.5, 2)$. What happens to the value of the forward rate agreement if all interest rates decline by one percentage point in the instant after you enter into the forward rate agreement?
- *Hint:* Write down the cash flows to the FRA that you enter into. Then, calculate the NPV using the new discount rates.
"""

# ╔═╡ f5b33f69-5767-44ad-b9fa-4074f15262de
vspace

# ╔═╡ ed20508e-bfe2-4247-8a8a-cbf1860bfaa1
md"""
# Question  3
"""

# ╔═╡ c6270f22-51dc-44a9-80b9-ccd10dbc41ac
md"""
On May 15, 2000, you enter into a forward rate agreement (notional =
\$100 million) with a bank for the period from November 15, 2000 to May 15,
2001 (6 months later to 1 year later). The current price of a
6-month zero coupon bond is \$96.79 and the current price of a
1-year zero coupon bond is \$93.51. Assume semi-annual compounding.

"""

# ╔═╡ 4a8ce7d3-0315-4d13-9734-c47f7b87d21b
md"""
__1.__ What must the forward rate agreed upon be so that there is no arbitrage?
"""

# ╔═╡ 9cc24dc0-811a-4611-a681-7ba24bbbfad8
vspace

# ╔═╡ 95a7fe7f-f580-4f26-b47e-a5dac16d49f5
md"""
__2.__  What is the value of the forward at inception?
"""

# ╔═╡ 875a73c8-4c11-4821-b256-6bd3b9ef437d
vspace

# ╔═╡ 16f078b5-a050-4876-9048-a06d3e2733be
md"""
__3.__ Suppose that three months have passed, so it is August 15, 2000. You are given the following discount factors. What is the value of the forward agreement? 

*Hint: Think about what the cashflows to the forward agreement are.*

- August 15, 2000

|Maturity       |   $D(0,T)$
|:--------------|:---------
|Nov 2000 (3mo) |   0.9844
|Feb 2001 (6mo) |   0.9690
|May 2001 (9mo) |   0.9531
|Aug 2001 (12mo)|   0.9386



"""

# ╔═╡ 99b4b3ec-5fde-4728-a49f-7f791ab0e0ad
vspace

# ╔═╡ eb77b6e7-2890-447a-98c7-74b581af4dd9
md"""
__4.__ Now consider November 15, 2000. What is the value of the forward agreement now?

| Maturity         |  $D(0,T)$ |
|:-----------------|:--------|
| Feb 2001 (3mo)   | 0.9848  | 
| May 2001 (6mo)   | 0.9692  |
| Aug 2001 (9mo)   | 0.9545  |
| Nov 2001 (12mo)  | 0.9402  |
"""

# ╔═╡ 885c0fb2-79b7-48c7-9a63-f6d4f4becb68
vspace

# ╔═╡ 9afe4152-2414-4826-9d65-489b6ffa7a8f
vspace

# ╔═╡ 8d4541b1-83ef-485a-9502-336c079516f7
vspace

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
Logging = "56ddb016-857b-54e1-b83d-db4d58db5568"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[compat]
DataFrames = "~1.6.1"
HTTP = "~1.10.5"
HypertextLiteral = "~0.9.5"
LaTeXStrings = "~1.3.1"
PlutoUI = "~0.7.58"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.2"
manifest_format = "2.0"
project_hash = "bf8b750d9cfc776d7018faa735ddd41c147c061c"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "962834c22b66e32aa10f7611c08c8ca4e20749a9"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.8"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "d9d26935a0bcffc87d2613ce14c527c99fc543fd"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.5.0"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "04c738083f29f86e62c8afc341f0967d8717bdb8"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.6.1"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "4e1fe97fdaed23e9dc21d4d664bea76b65fc50a0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.22"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "d36f682e590a83d63d1c7dbd287573764682d12a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.11"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"
version = "1.11.0"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "PrecompileTools", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "f93655dc73d7a0b4a368e3c0bce296ae035ad76e"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.16"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InlineStrings]]
git-tree-sha1 = "6a9fde685a7ac1eb3495f8e812c5a7c3711c2d5e"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.3"

    [deps.InlineStrings.extensions]
    ArrowTypesExt = "ArrowTypes"
    ParsersExt = "Parsers"

    [deps.InlineStrings.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
    Parsers = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.InvertedIndices]]
git-tree-sha1 = "6da3c4316095de0f5ee2ebd875df8721e7e0bdbe"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.1"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "a007feb38b422fbdab534406aeca1b86823cb4d6"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.7.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.6.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "f02b56007b064fbfddb4c9cd60161b6dd0f40df3"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.1.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "38cb508d080d21dc1128f7fb04f20387ed4c0af4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a9697f1d06cc3eb3fb3ad49cc67f2cfabaac31ea"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.16+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "cc4054e898b852042d7b503313f7ad03de99c3dd"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "44f6c1f38f77cafef9450ff93946c53bd9ca16ff"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "d3de2694b52a01ce61a036f18ea9c0f61c4a9230"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.62"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "1101cd475833706e4d0e7b122218257178f48f34"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.4.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "712fb0231ee6f9120e005ccd56297abbc053e7e0"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.8"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "f305871d2f381d21527c770d4788c06c097c9bc1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.2.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "725421ae8e530ec29bcbdddbe91ff8053421d023"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.4.1"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "598cd7c1f68d1e205689b1c2fe65a9f85846f297"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Tricks]]
git-tree-sha1 = "6cae795a5a9313bbb4f60683f7263318fc7d1505"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.10"

[[deps.URIs]]
git-tree-sha1 = "cbbebadbcc76c5ca1cc4b4f3b0614b3e603b5000"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╟─a5de5746-3df0-45b4-a62c-3daf36f015a5
# ╟─3eeb383c-7e46-46c9-8786-ab924b475d45
# ╟─9f9d1928-5806-46e9-8dab-2961da605826
# ╟─7ad75350-14a4-47ee-8c6b-6a2eac09ebb1
# ╟─23bb9890-718d-42fd-a9fa-51b4a7994ed7
# ╟─caad8479-654b-4a15-a994-56c8764728c7
# ╟─238cfc9b-434a-426e-93e7-419314b7dc41
# ╟─a473c4cd-0a21-493b-9ec5-55ea66a0ed99
# ╟─5d00ce86-142d-4740-91e1-73704382c366
# ╟─5f84a5be-dbea-4eab-ba5a-06b8062d5b4b
# ╟─d74dd608-b367-43f3-b5f1-bd654e5f87e2
# ╟─18252fe4-6aba-4b13-b6fb-6426bd9037ca
# ╟─738b8f7a-3cfd-4792-89e7-96ba3f55be81
# ╟─e3c1b782-7f23-4c50-af3c-91aa8af0a88e
# ╟─3a4ba27e-26d7-40d9-8f9d-8f22535d9287
# ╟─86478c8f-aeee-4085-ad39-af31f8c9c037
# ╟─f68b5afd-cf8f-4cba-ad7f-03fcc3f291af
# ╟─d419a379-712e-47a6-99ed-d8350fbc1000
# ╟─6d1be573-3b15-4a18-89d7-5d887cea7e84
# ╟─9eae2846-7b22-4b6c-91db-ffa7cd67be92
# ╟─f2ef9979-8f46-4d1d-a8fd-87d1bcb9abee
# ╟─f5b33f69-5767-44ad-b9fa-4074f15262de
# ╟─ed20508e-bfe2-4247-8a8a-cbf1860bfaa1
# ╟─c6270f22-51dc-44a9-80b9-ccd10dbc41ac
# ╟─4a8ce7d3-0315-4d13-9734-c47f7b87d21b
# ╟─9cc24dc0-811a-4611-a681-7ba24bbbfad8
# ╟─95a7fe7f-f580-4f26-b47e-a5dac16d49f5
# ╟─875a73c8-4c11-4821-b256-6bd3b9ef437d
# ╟─16f078b5-a050-4876-9048-a06d3e2733be
# ╟─99b4b3ec-5fde-4728-a49f-7f791ab0e0ad
# ╟─eb77b6e7-2890-447a-98c7-74b581af4dd9
# ╟─885c0fb2-79b7-48c7-9a63-f6d4f4becb68
# ╟─9afe4152-2414-4826-9d65-489b6ffa7a8f
# ╟─8d4541b1-83ef-485a-9502-336c079516f7
# ╟─d160a115-56ed-4598-998e-255b82ec37f9
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002

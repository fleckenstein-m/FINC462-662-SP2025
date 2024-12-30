### A Pluto.jl notebook ###
# v0.19.19

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

	using Plots
	gr();
	Plots.GRBackend()


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

# ╔═╡ 731c88b4-7daf-480d-b163-7003a5fbd41f
begin 
	html"""
	<p align=left style="font-size:36px; font-family:family:Georgia"> <b> FINC 462/662 - Fixed Income Securities</b> <p>
	"""
end

# ╔═╡ 19b58a85-e443-4f5b-a93a-8d5684f9a17a
TableOfContents(title="Assignment 8", indent=true, depth=2, aside=true)

# ╔═╡ a5de5746-3df0-45b4-a62c-3daf36f015a5
begin 
	html"""
	<p style="padding-bottom:1cm"> </p>
	<div align=center style="font-size:25px; font-family:family:Georgia"> FINC-462/662: Fixed Income Securities </div>
	<p style="padding-bottom:1cm"> </p>
	<p align=center style="font-size:25px; font-family:family:Georgia"> <b> Assignment 8
	</b> <p>
	<p style="padding-bottom:1cm"> </p>
	<p align=center style="font-size:25px; font-family:family:Georgia"> Spring 2023 <p>
	<p style="padding-bottom:1cm"> </p>
	<div align=center style="font-size:20px; font-family:family:Georgia"> Prof. Matt Fleckenstein </div>
	<p style="padding-bottom:0.05cm"> </p>
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
Suppose spot rates are as given below. Calculate 6-month forward rates out to 5 years, i.e. calculate $f_{0.5,1}$, $f_{1.0,1.5}$, ..., $f_{4.5,5}$.

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

# ╔═╡ ac0cf027-4684-4e1e-87df-ac66ecc17461
Foldable("Solution",Markdown.parse("

Forward Rate   | Value                                     | Calculation            
--------------:|------------------------------------------:|----------------------:
``f(0.5,1.0)``  | ``$(roundmult(f05_10_2*100,1e-4))\\%``   | ``$(strfVec_2[1])``
``f(1.0,1.5)``  | ``$(roundmult(f10_15_2*100,1e-4))\\%``   | ``$(strfVec_2[2])``
``f(1.5,2.0)``  | ``$(roundmult(f15_20_2*100,1e-4))\\%``   | ``$(strfVec_2[3])``
``f(2.0,2.5)``  | ``$(roundmult(f20_25_2*100,1e-4))\\%``   | ``$(strfVec_2[4])``
``f(2.5,3.0)``  | ``$(roundmult(f25_30_2*100,1e-4))\\%``   | ``$(strfVec_2[5])``
``f(3.0,3.5)``  | ``$(roundmult(f30_35_2*100,1e-4))\\%``   | ``$(strfVec_2[6])``
``f(3.5,4.0)``  | ``$(roundmult(f35_40_2*100,1e-4))\\%``   | ``$(strfVec_2[7])``
``f(4.0,4.5)``  | ``$(roundmult(f40_45_2*100,1e-4))\\%``   | ``$(strfVec_2[8])``
``f(4.5,5.0)``  | ``$(roundmult(f45_50_2*100,1e-4))\\%``   | ``$(strfVec_2[9])``

"))

# ╔═╡ 238cfc9b-434a-426e-93e7-419314b7dc41
vspace

# ╔═╡ 4302072c-2542-4901-8c3d-ba6170af3744
md"""
# Question 2
"""

# ╔═╡ a473c4cd-0a21-493b-9ec5-55ea66a0ed99
Markdown.parse("
__2.1__ Calculate the two-year forward rate starting one year from today (i.e., \$f_{1,3}\$).
")

# ╔═╡ 1c95f7b3-6ff5-4b5e-bc26-4bf80d98425e
Foldable("Solution",
Markdown.parse("
``\$\\left( 1+ \\frac{f_{1,3}}{2}\\right)^{2\\times 2}  = \\frac{\\left(1+ \\frac{r_{0,3}}{2}\\right)^{2\\times 3}}{\\left( 1+ \\frac{r_{0,1}}{2}\\right)^{2\\times 1}}\$``
	
``\$\\left( 1+ \\frac{f_{1,3}}{2}\\right)^{4}  = \\frac{\\left(1+ \\frac{$(r30_2)\\%}{2}\\right)^{6}}{\\left( 1+ \\frac{$(r10_2)\\%}{2}\\right)^{2}}\$``
	
``\$f_{1,3} = 2\\times \\left( \\frac{\\left(1+ \\frac{$(r30_2)\\%}{2}\\right)^{6/4}}{\\left( 1+ \\frac{$(r10_2)\\%}{2}\\right)^{2/4}} -1\\right)\$``
	
``\$ f_{1,3} = $(roundmult(f10_30_2,1e-6)) = $(roundmult(f10_30_2*100,1e-4)) \\%\$``
"))

# ╔═╡ 5d00ce86-142d-4740-91e1-73704382c366
Markdown.parse("
__2.2__ Calculate the two-year forward rate starting two years from today (i.e., \$f_{2,4}\$).
")

# ╔═╡ 40079ad2-79a8-4d15-906e-b4fdd8b6a88d
Foldable("Solution",Markdown.parse("
``\$\\left( 1+ \\frac{f_{2,4}}{2}\\right)^{2\\times 2}  = \\frac{\\left(1+ \\frac{r_{0,4}}{2}\\right)^{2\\times 4}}{\\left( 1+ \\frac{r_{0,2}}{2}\\right)^{2\\times 2}}\$``
	
``\$\\left( 1+ \\frac{f_{2,4}}{2}\\right)^{4}  = \\frac{\\left(1+ \\frac{$(r40_2)\\%}{2}\\right)^{8}}{\\left( 1+ \\frac{$(r20_2)\\%}{2}\\right)^{4}}\$``
	
``\$f_{2,4} = 2\\times \\left( \\frac{\\left(1+ \\frac{$(r40_2)\\%}{2}\\right)^{8/4}}{\\left( 1+ \\frac{$(r20_2)\\%}{2}\\right)^{4/4}} -1\\right)\$``
	
``\$f_{2,4} = $(roundmult(f20_40_2,1e-6)) = $(roundmult(f20_40_2*100,1e-4))\\%\$``
"))

# ╔═╡ 5f84a5be-dbea-4eab-ba5a-06b8062d5b4b
Markdown.parse("
__2.3__ Calculate the two-year forward rate starting three years from today (i.e., \$f_{3,5}\$).
")

# ╔═╡ d43cdfc5-a6fe-423b-83c7-522026fd6097
Foldable("Solution",Markdown.parse("
``\$\\left( 1+ \\frac{f_{3,5}}{2}\\right)^{2\\times 2}  = \\frac{\\left(1+ \\frac{r_{0,5}}{2}\\right)^{2\\times 5}}{\\left( 1+ \\frac{r_{0,3}}{2}\\right)^{2\\times 3}}\$``
	
``\$\\left( 1+ \\frac{f_{3,5}}{2}\\right)^{2\\times 2}  = \\frac{\\left(1+ \\frac{$(r50_2)\\%}{2}\\right)^{2\\times 5}}{\\left( 1+ \\frac{$(r30_2)\\%}{2}\\right)^{2\\times 3}}\$``
	
``\$f_{3,5} = $(roundmult(f30_50_2,1e-6)) = $(roundmult(f30_50_2*100,1e-4))\\%\$``
"))

# ╔═╡ d74dd608-b367-43f3-b5f1-bd654e5f87e2
Markdown.parse("
__2.4__ Calculate the 4-year forward rate starting one year from today (i.e., \$f_{1,5}\$).
")

# ╔═╡ 9b10cdd6-ba85-49f5-87cd-d018a301b3af
Foldable("Solution",Markdown.parse("
``\$\\left( 1+ \\frac{f_{1,5}}{2}\\right)^{2\\times 4}  = \\frac{\\left(1+ \\frac{r_{0,5}}{2}\\right)^{2\\times 5}}{\\left( 1+ \\frac{r_{0,1}}{2}\\right)^{2\\times 1}}\$``
	
``\$\\left( 1+ \\frac{f_{1,5}}{2}\\right)^{2\\times 4}  = \\frac{\\left(1+ \\frac{$(r50_2)\\%}{2}\\right)^{2\\times 5}}{\\left( 1+ \\frac{$(r10_2)\\%}{2}\\right)^{2\\times 1}}\$``
	
``\$f_{1,5} = $(roundmult(f10_50_2,1e-6)) = $(roundmult(f10_50_2*100,1e-4))\\%\$``
"))

# ╔═╡ 18252fe4-6aba-4b13-b6fb-6426bd9037ca
Markdown.parse("
__2.5__ Calculate the 3-year forward rate starting two years from today (i.e., \$f_{2,5}\$).
")

# ╔═╡ 16610ace-58fc-4619-a99c-90575607c1c0
Foldable("Solution",Markdown.parse("
``\$\\left( 1+ \\frac{f_{2,5}}{2}\\right)^{2\\times 3}  = \\frac{\\left(1+ \\frac{r_{0,5}}{2}\\right)^{2\\times 5}}{\\left( 1+ \\frac{r_{0,2}}{2}\\right)^{2\\times 2}}\$``
	
``\$\\left( 1+ \\frac{f_{2,5}}{2}\\right)^{2\\times 3}  = \\frac{\\left(1+ \\frac{$(r50_2)\\%}{2}\\right)^{2\\times 5}}{\\left( 1+ \\frac{$(r20_2)\\%}{2}\\right)^{2\\times 2}}\$``
	
``\$f_{2,5} = $(roundmult(f20_50_2,1e-6)) = $(roundmult(f20_50_2*100,1e-4))\\%\$``
"))

# ╔═╡ 738b8f7a-3cfd-4792-89e7-96ba3f55be81
vspace

# ╔═╡ e3c1b782-7f23-4c50-af3c-91aa8af0a88e
md"""
# Question 3
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

# ╔═╡ 6a8300c3-b1ae-46e4-ba04-0c15c10c3e0a
Foldable("Solution",Markdown.parse("

Forward Rate   | Value                                     | Calculation            
--------------:|------------------------------------------:|----------------------:
``f(0.5,1.0)``  | ``$(roundmult(f05_10_3*100,1e-3))\\%``   | ``$(strfVec_3[1])``
``f(1.0,1.5)``  | ``$(roundmult(f10_15_3*100,1e-3))\\%``   | ``$(strfVec_3[2])``
``f(1.5,2.0)``  | ``$(roundmult(f15_20_3*100,1e-3))\\%``   | ``$(strfVec_3[3])``
``f(0.5,2.0)``  | ``$(roundmult(f05_20_3*100,1e-3))\\%``   | ``$(strfVec_3[4])``

"))

# ╔═╡ d419a379-712e-47a6-99ed-d8350fbc1000
vspace

# ╔═╡ 6d1be573-3b15-4a18-89d7-5d887cea7e84
md"""
**2.** Suppose that $f(1, 1.5) = 4.5$%. (This should be almost 0.5 percentage points higher
than what you found in Part 1 above.) Using this value for $f(1, 1.5)$ and the given zero-coupon yields, construct an arbitrage trading strategy to take advantage of this mispricing.
- *Hint: Calculate zero-coupon bond prices for maturities of 1-year and 1.5-years. Then create a synthetic forward contract before forming a strategy.*
"""

# ╔═╡ 07c1fc06-d2c8-4512-89b0-9897d62ab35a
Foldable("Solution",md"""
- Bond Prices
  - 1-year zero-coupon bond price: $\frac{100}{1.0125^2} = 97.5461$ (Bond  `X`)
  - 1.5-year zero-coupon bond price: $\frac{100}{1.015^3} = 95.6317$ (Bond `Z`)

- Create a replicating portfolio to lend \$100 at $t=1$ that is repaid at $t=1.5$.

|Bond         | t = 0        |  t = 0.5       |  t = 1        |  t = 1.5    |
|:------------|-------------:|---------------:|--------------:|------------:|
| X (x units) | $-97.5461\times x$ | $0$      | $100\times x$ |  $0$        |
| Z (z units) | $-95.6317\times z$ | $0$      | $0$           |  $100 \times z$|
| Total       |  $0$               |  $0$     | $-100$        |  $100\times\left(1+\frac{f(0,1,1.5)}{2}\right)$ |

- Thus, 
$97.5461x − 95.6317\times z = 0$
$100\times x = -100$

- Solving, 
$x = -1$ 
$z = \frac{97.5461}{95.6317} = 1.020018$

- The arbitrage portfolio is

|             | t = 0        |  t = 0.5       |  t = 1        |  t = 1.5    |
|:------------|-------------:|---------------:|--------------:|------------:|
| Lend at $f(1,1.5)$=4.5% | $0$ | $0$ | $-100$ | $102.25$ |
| | | | |
| | | | |
| | | | |
| *(-1 of) Synthetic Forward* | | | | 
| Buy 1 Unit of X | $-97.5461\times x$ | $0$      | $100$ |  $0$        |
| Short 1.020018 units of Z | $+97.5461$ | $0$      | $0$           |  $-102.0018$|
| Total       |  $0$               |  $0$     | $-100$        |  $100\times\left(1+\frac{f(0,1,1.5)}{2}\right)$ |
| | | | |
| | | | |
| | | | |
|Total | $0$ | $0$ | $0$ | $0.2482$ |

""")

# ╔═╡ 9eae2846-7b22-4b6c-91db-ffa7cd67be92
vspace

# ╔═╡ f2ef9979-8f46-4d1d-a8fd-87d1bcb9abee
md"""
**3.** Suppose that we go back to Part 1. You enter into a forward rate agreement to lend \$100 at t = 0.5 and be repaid at t = 2 at the forward rate of $f(0.5, 2)$. What happens to the value of the forward rate agreement if all interest rates decline by one percentage point in the instant after you enter into the forward rate agreement?
- *Hint:* Write down the cash flows to the FRA that you enter into. Then, calculate the NPV using the new discount rates.
"""

# ╔═╡ d06cadc5-bed7-4fbb-8e78-3ad7bc2d1130
Foldable("Solution",md"""
The cash flow for the FRA is:

|        | t = 0 | t = 0.5 | ... | t = 2 |
|:--------|------:|--------:|----:|:-------|
|Cash flow to FRA | $0$ | $-100$ |  | $+100\left(1+\frac{0.0467}{2}\right)^3$ = $107.17$ |

- If all interest rates decline by one percentage point:

$\frac{-100}{1+\frac{0.01}{2}} + \frac{107.17}{\left(1+\frac{0.03}{2}\right)^4} = 1.47$


""")

# ╔═╡ eba16ced-1971-4636-a867-b66f7d8cc4bc
vspace

# ╔═╡ 5b74cd45-3432-4d95-bd8b-7b48d7846a15
md"""
**4.** What does your answer in  Part 3 imply about the modified durations of your cash outflows and cash inflows in the forward rate agreement?
"""

# ╔═╡ 7451c257-6394-4a94-9e2c-ca47982f9000
Foldable("Solution",md"""
They imply that the MD of the cash inflows are higher than the cash outflows as the
FRA has a positive net value if interest rates decline and a negative net value if interest
rates increase, compared to an initial value of zero. As a balance sheet, the FRA can
be thought of as:

|             Assets | Liabilities    |
|:-------------------|:---------------|
| \$107.17 to be received at t = 2 | \$100 to be paid at t = 0.5 | 
| $MD = \frac{2}{1+\frac{0.04}{2}} = 1.96$ | $MD = \frac{0.5}{1+\frac{0.02}{2}} = 0.495$ |


""")

# ╔═╡ 47a18fee-276c-4ea5-afbf-21147bb3ceaa
vspace

# ╔═╡ 5fd18248-1600-40ca-b3e5-a5c70fa83ff0
md"""
# Question 4
"""

# ╔═╡ c275fee5-5a06-49d8-8f24-6931c97d7cac
md"""
Suppose that it is December 31, 2022 and you can either buy a 1-year zero coupon bond (the bond's maturity date is December 31, 2023) for \$97 or you can enter into a forward contract today to buy a zero-coupon bond maturing on December 31, 2024. Via the forward contract, the actual purchase date would be in one year (December 31, 2023) for a price of $96. 
"""

# ╔═╡ db82ccfe-3223-4af3-bf73-72833ee78d28
md"""
**1.** If the Law of One Price holds, what should be the price of a *2-year* zero coupon bond today (i.e., the zero-coupon bond has a maturity date of December 31, 2024).
- *Hint: Write down what the cash flows are to buying the 2-year bond today. Then, use the 1-year bond and the forward contract to replicate that cash flow, buying `x` units of the 1-year bond and using `z` units of the forward contract.*
"""

# ╔═╡ ee5bd069-2a51-406c-9a74-2fc466a1faaf
Foldable("Solution",md"""
|                   | t = 0 | t = 1 | t = 2  |
|:------------------|-------:|------:|---------:|
| Buying 1 unit of the 2-yr bond | $-P_{2yr}$ | $0$ | $+100$ |
| Buying $x$ units of the 1-yr bond | $- 97\times x$ | $+100\times x$ | $0$ |
| Entering into $z$ units of $P(1, 2)$ | 0 | $-96\times z$ | $+100\times$ z|

- Recall that $P(1,2)$ simply denotes today's price for the (zero-coupon) bond to be bought in 1-year from today and this bond has maturity date in 2-year from today.

$100 \times x - 96z = 0$
$100\times z = 100$

$\Rightarrow z = 1\textrm{  and  } x = 0.96$

Thus, today's price of a two-year zero coupon bond ought to be

$P_{2yr} = 97\times x = 93.12$

""")

# ╔═╡ eb065b6f-5af5-4832-99bf-ed8452f9cef2
vspace

# ╔═╡ 7c5db96e-6c50-4c9f-83fd-ae4b2d4acdbc
md"""
**2.** If the 2-year bond is actually selling for $92, construct a trading strategy to take advantage of this violation of the Law of One Price.
"""

# ╔═╡ 31a7d953-bdb3-41b8-ad21-5eb71b951b0b
Foldable("Solution",md"""
- This means that the 2-year bond is too cheap. Buy the two-year bond and short the replicating portfolio.

|           |     t = 0   |   t = 1  | t = 2   |
|:----------|------------:|----------:|--------:|
| Buying 1 unit of the 2-yr bond | $-92$ | $0$ | $+100$ |
| Short 0.96 units of the 1-yr bond | $+93.12$ | $-96$ | $0$ |
| Short 1 unit of P(1, 2) | 0 | $+96$ | $-100$ |
| Total | $1.12$ | $0$ | $0$ |

""")

# ╔═╡ f5b33f69-5767-44ad-b9fa-4074f15262de
vspace

# ╔═╡ ed20508e-bfe2-4247-8a8a-cbf1860bfaa1
md"""
# Question  5
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
__5.1__ What must the forward rate agreed upon be so that there is no arbitrage?
"""

# ╔═╡ f74312b3-54f7-4d3f-902e-3eb6494fc236
Foldable("Solution",md"""
First, solve for the yields on the 6-month and the 1-year zero coupon bonds.
- 6mo zero: P=\$96.79

$$r_{0.5}=2\times \left(\left(\frac{100}{96.79}\right)^{\frac{1}{2\times 0.5}} -1 \right)=0.066329166=6.6329\%$$

- 1yr zero: P=\$93.51

$$r_{1.0}=2\times \left(\left(\frac{100}{93.51}\right)^{\frac{1}{2\times 1}} -1 \right)=0.068240161=6.82402\%$$

Next, solve for $f_{0.5,1}$

$$\left(1+\frac{r_{0.5}}{2}\right)\left(1+\frac{f_{0.5,1}}{2}\right) = \left(1+\frac{r_1}{2}\right)^2$$

Solving theis equation for the forward rates gives us

   $$f_{0.5,1} = 7.015925\%$$

Thus, you will pay \$100mm in Nov 2000 to receive
	$100 \times \left(1+\frac{0.0701592}{2}\right) = 103.51$ million
	in May 2001.
	

""")

# ╔═╡ 9cc24dc0-811a-4611-a681-7ba24bbbfad8
vspace

# ╔═╡ 95a7fe7f-f580-4f26-b47e-a5dac16d49f5
md"""
__5.2__  What is the value of the forward at inception?
"""

# ╔═╡ 719d529a-03e4-4f1b-a438-6dcfa57deec3
Foldable("Solution",md"""
The value of the forward at inception is 0.
""")

# ╔═╡ 875a73c8-4c11-4821-b256-6bd3b9ef437d
vspace

# ╔═╡ 16f078b5-a050-4876-9048-a06d3e2733be
md"""
__5.3__ Suppose that three months have passed, so it is August 15, 2000. You are given the following discount factors. What is the value of the forward agreement? 

*Hint: Think about what the cashflows to the forward agreement are.*

- August 15, 2000

|Maturity       |   $D(0,T)$
|:--------------|:---------
|Nov 2000 (3mo) |   0.9844
|Feb 2001 (6mo) |   0.9690
|May 2001 (9mo) |   0.9531
|Aug 2001 (12mo)|   0.9386



"""

# ╔═╡ 765e386b-be08-43d0-ac71-a62d0ebf23c7
Foldable("Solution",md"""

Though the value of the forward at inception was 0, interest
rates have changed since the forward rate agreement was made.
The most straightforward way to calculate the value of the
position is to write out the future cashflows and discount back
to today.
	
	  
| Time t                  | t = 0.25 (Nov 2000)  | t = 0.75 (May 2001) |
|:------------------------|:---------------------|:--------------------|
| Forward Rate Agreement  |                -100  |              103.51 |
	
	
- Value of forward rate agreement:

$$-100 \times 0.9844 + 103.51 \times 0.9531 = 0.215$$
""")

# ╔═╡ 99b4b3ec-5fde-4728-a49f-7f791ab0e0ad
vspace

# ╔═╡ eb77b6e7-2890-447a-98c7-74b581af4dd9
md"""
__5.4__ Now consider November 15, 2000. What is the value of the forward agreement now?

| Maturity         |  $D(0,T)$ |
|:-----------------|:--------|
| Feb 2001 (3mo)   | 0.9848  | 
| May 2001 (6mo)   | 0.9692  |
| Aug 2001 (9mo)   | 0.9545  |
| Nov 2001 (12mo)  | 0.9402  |
"""

# ╔═╡ f63ea571-6452-42c1-af7e-4fb789304a2d
Foldable("Solution",md"""
	  
| Time t                  | t = 0.0 (Nov 2000)   | t = 0.50 (May 2001) |
|:------------------------|:---------------------|:--------------------|
| Forward Rate Agreement  |                -100  |              103.51 |
	
	
- Value of forward rate agreement:

$$-100 + 103.51 \times 0.9692 = 0.32$$

""")

# ╔═╡ 885c0fb2-79b7-48c7-9a63-f6d4f4becb68
vspace

# ╔═╡ f61fc2af-e411-4075-bcda-3fd761da58cb
md"""
__5.5__ What is the six-month spot rate (semi-annually compounded) now?
"""

# ╔═╡ 3e75a33e-392b-4fd0-9978-07fad6a4faf1
Foldable("Solution",md"""

Recall that the spot rate can be calculated from the discount factor $D(T)$ using

$$D(T)=\frac{1}{(1+\frac{r_{T}}{2})^{2\times T}}$$

Plugging in $D(T=0.5)=0.9692$ gives us

$$r_{0.5} = 2\times \left( \left(\frac{1}{0.9692}\right)^{\frac{1}{2\times 0.5}} -1\right) = 0.0635557573 = 6.36\%$$
""")

# ╔═╡ d208120a-a450-460f-ab78-c0ca9e99c619
vspace

# ╔═╡ 82fe8645-a213-44ed-919d-18b0cbb0eeae
md"""
__5.6__ What is the cash flow in May 2001 if you invest \$100 million at the spot rate in Nov. 2000? Compare this to agreeing to the original forward rate agreement.
"""

# ╔═╡ 0e1c20db-5322-4f38-b9e0-f9333b8b743b
Foldable("Solution",md"""
- Investing in the spot rate:

$$100 \times \left(1+\frac{0.0636}{2}\right)=103.18$$

- Had we agree to the forward rate, we would invest at a rate of 7.016%.

$$100\times \left(1+\frac{0.07016}{2}\right)=103.51$$

""")

# ╔═╡ 9afe4152-2414-4826-9d65-489b6ffa7a8f
vspace

# ╔═╡ 3713b423-0ef4-4685-a22d-39ae73dbb094
md"""
# Question 6
"""

# ╔═╡ f41b3285-6ff5-4f16-b936-eca01600b5b4
md"""
Suppose the one-year spot interest rate is 4% and the two-year spot rate is 5%. Assume that all rates are annually compounded.

__6.1__ What is the forward rate at time 0 for borrowing at time 1 for one year (i.e. compute $f_{1,2}$)?
"""

# ╔═╡ 04feec75-3fdd-4a32-9010-7cccf2e93d57
Foldable("Solution",md"""
The forward rate is given by $$f_{1,2}=\frac{1.05^2}{1.04}=6.01$$%.
""")

# ╔═╡ 7f7c265d-237a-4bcf-98cf-601a360b7095
vspace

# ╔═╡ 2f641623-6c1c-476b-a57a-ebee39739137
md"""
__6.2__ Now suppose you want to borrow \$100 for one year one year from now and want to lock in the interest rate today. What investment strategy would you need to follow if you have access to the spot markets only (i.e. how can you synthetically replicate the forward contract using one-year and two-year zero coupon bonds)?
"""

# ╔═╡ 7958f21a-63af-47c8-9e7d-31a89ffa1645
Foldable("Solution",md"""
You want to implement a trading strategy that gives you \$100 one year from now, which you have to repay two years from now at the interest rate $f_{1,2}=6.01$%. The cash flow structure looks as follows:
	
| T | 0 | 1 | 2 |
| --- | --- | --- | --- |
| Forward Contract | 0 | +$100 | -\$100 $\times$ (1.0601) |
	
We can replicate this cash flow by investing $\frac{100}{1.04}$=\$96.15 for one year in $t=0$ and borrowing this amount for two years with a repayment of $96.15\times 1.05^2=$\$106.01. The trading strategy can be depicted as follows:
	
| T | 0 | 1 | 2 |
| --- | --- | --- | --- |
| Investing for one Year | -\$96.15 | +\$100 | 0 |
| Borrowing for two years | +\$96.15 | 0 | -\$106.01 |
| Total | 0 | +\$100 | -\$106.01 |
	
A combination of these two positions yields the same cash flows as a forward contract.
""")

# ╔═╡ d52e1caa-3a00-4bcc-9dec-6ac93e4bdb14
vspace

# ╔═╡ ccbfccc4-f3fd-4c86-a61e-7f6a2a0cf79b
md"""
__6.3__ Now both spot and forward contracts are traded. Suppose the forward rate was 5.5%. Explain how you could exploit this situation to make money without risk.
"""

# ╔═╡ 0eb1aa68-5c3a-46c8-9c29-c1288316d57c
Foldable("Solution",md"""
There are two ways to borrow money for two years. You can either borrow for two years in the spot market or borrow in the spot market for one year and enter into a forward contract for one more year. The cash flows from both strategies are known at t=0. 

The two-year interest rate implied by the latter strategy is $\sqrt{1.04\times1.055}-1=4.75\%$. 

That means you can borrow using the spot and future markets and then invest the proceeds for two years in the spot markets. This strategy involves no money up front but provides a cash flow at t=2. The following table clarifies this point.
	
| t | 0 | 1 | 2 |
| --- | --- | --- | --- |
| Borrowing for one year in the spot market | +$100 | -$104 | 0 |
| Borrowing from the forward market | 0 | +$104 | -$104\times1.055=$109.72 |
| Investing for two years in the spot market | -$100 | 0 | +$110.25 |
| Total | 0 | 0 | +$0.53 |
		
""")

# ╔═╡ 8d4541b1-83ef-485a-9502-336c079516f7
vspace

# ╔═╡ d6a1eca6-19da-411d-bcc7-cd2167678908
md"""
# Question 7
"""

# ╔═╡ ca61760e-9156-4d81-834e-e41c747e1e43
md"""
A one-year zero coupon bond with \$100 face value is currently trading for \$98. The forward rate for borrowing money one year from now for another year is 6%. Compute the arbitrage free two-year spot rate. Assume annual compounding.
"""

# ╔═╡ ece3723e-57a3-4cbc-8c36-9ee8ddc7130c
Foldable("Solution",md"""

The yield on the one-year zero coupon bond trading at \$98 is

$$y_1 = \left(\frac{100}{98}\right)-1=2.04\%$$
		
Rolling this investment over after year one at the forward rate of 6% must give you the same return as investing today at the 2-year spot rate. That means,
	
$$(1+y_1)\times (1+f_{1,2})=(1+y_2)^2$$
	
Solving for the two year spot rate gives us

$$y_2 = \sqrt{(1+y_1)\times(1+f_{1,2})}=4.00\%$$
	
""")

# ╔═╡ 4f74d455-78f9-40ab-b304-b026071d9fd6
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
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[compat]
DataFrames = "~1.3.2"
HTTP = "~1.7.3"
HypertextLiteral = "~0.9.3"
LaTeXStrings = "~1.3.0"
Plots = "~1.38.2"
PlutoUI = "~0.7.37"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "c6d890a52d2c4d55d326439580c3b8d0875a77d9"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.7"

[[ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random", "SnoopPrecompile"]
git-tree-sha1 = "aa3edc8f8dea6cbfa176ee12f7c2fc82f0608ed3"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.20.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "600cc5508d66b78aae350f7accdb58763ac18589"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.10"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "96b0bc6c52df76506efc8a441c6cf1adcb1babc4"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.42.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "ae02104e835f219b8930c7664b8012c93475c340"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.2"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "387d2b8b3ca57b791633f0993b31d8cb43ea3292"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.71.3"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "5982b5e20f97bff955e9a2343a14da96a746cd8c"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.71.3+0"

[[Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "d3b3624125c1474292d0d8ed0f65554ac37ddb23"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.74.0+2"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "eb5aa5e3b500e191763d35198f859e4b40fff4a6"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.7.3"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "f377670cda23b6b7c1c0b3893e37451c5c1a2185"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.5"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "2422f47b34d4b127720a18f86fa7b1aa2e141f29"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.18"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c7cb1f5d892775ba13767a87c7ada0b980ea0a71"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+2"

[[Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "946607f84feb96220f480e0422d3484c49c00239"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.19"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "cedb76b37bc5a6c702ade66be44f831fa23c681e"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.0"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "6503b77492fd7fcb9379bf73cd31035670e3c509"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.3.3"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6e9dba33f9f2c44e08a020b0caf6903be540004"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.19+0"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "85b5da0fa43588c75bb1ff986493443f821c70b7"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.3"

[[Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "5b7690dd212e026bbab1860016a6601cb077ab66"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.2"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Preferences", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SnoopPrecompile", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "a99bbd3664bb12a775cda2eba7f3b2facf3dad94"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.38.2"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "bf0a1121af131d9974241ba53f601211e9303a9e"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.37"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "db3a23166af8aebf4db5ef87ac5b00d36eb771e2"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.0"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RecipesBase]]
deps = ["SnoopPrecompile"]
git-tree-sha1 = "261dddd3b862bd2c940cf6ca4d1c8fe593e457c8"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.3"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase", "SnoopPrecompile"]
git-tree-sha1 = "e974477be88cb5e3040009f3767611bc6357846f"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.11"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "5ce79ce186cc678bbb5c5681ca3379d1ddae11a1"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.7.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "94f38103c984f89cf77c402f2a68dbd870f8165f"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.11"

[[URIs]]
git-tree-sha1 = "ac00576f90d8a259f2c9d823e91d1de3fd44d348"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.1"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "ed8d92d9774b077c53e1da50fd81a36af3744c1c"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "93c41695bc1c08c46c5899f4fe06d6ead504bb73"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.10.3+0"

[[XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "868e669ccb12ba16eaf50cb2957ee2ff61261c56"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.29.0+0"

[[libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9ebfc140cc56e8c2156a15ceac2f0302e327ac0a"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+0"
"""

# ╔═╡ Cell order:
# ╟─731c88b4-7daf-480d-b163-7003a5fbd41f
# ╟─19b58a85-e443-4f5b-a93a-8d5684f9a17a
# ╟─a5de5746-3df0-45b4-a62c-3daf36f015a5
# ╟─3eeb383c-7e46-46c9-8786-ab924b475d45
# ╟─9f9d1928-5806-46e9-8dab-2961da605826
# ╟─7ad75350-14a4-47ee-8c6b-6a2eac09ebb1
# ╟─23bb9890-718d-42fd-a9fa-51b4a7994ed7
# ╟─caad8479-654b-4a15-a994-56c8764728c7
# ╟─ac0cf027-4684-4e1e-87df-ac66ecc17461
# ╟─238cfc9b-434a-426e-93e7-419314b7dc41
# ╟─4302072c-2542-4901-8c3d-ba6170af3744
# ╟─a473c4cd-0a21-493b-9ec5-55ea66a0ed99
# ╟─1c95f7b3-6ff5-4b5e-bc26-4bf80d98425e
# ╟─5d00ce86-142d-4740-91e1-73704382c366
# ╟─40079ad2-79a8-4d15-906e-b4fdd8b6a88d
# ╟─5f84a5be-dbea-4eab-ba5a-06b8062d5b4b
# ╟─d43cdfc5-a6fe-423b-83c7-522026fd6097
# ╟─d74dd608-b367-43f3-b5f1-bd654e5f87e2
# ╟─9b10cdd6-ba85-49f5-87cd-d018a301b3af
# ╟─18252fe4-6aba-4b13-b6fb-6426bd9037ca
# ╟─16610ace-58fc-4619-a99c-90575607c1c0
# ╟─738b8f7a-3cfd-4792-89e7-96ba3f55be81
# ╟─e3c1b782-7f23-4c50-af3c-91aa8af0a88e
# ╟─3a4ba27e-26d7-40d9-8f9d-8f22535d9287
# ╟─86478c8f-aeee-4085-ad39-af31f8c9c037
# ╟─f68b5afd-cf8f-4cba-ad7f-03fcc3f291af
# ╟─6a8300c3-b1ae-46e4-ba04-0c15c10c3e0a
# ╟─d419a379-712e-47a6-99ed-d8350fbc1000
# ╟─6d1be573-3b15-4a18-89d7-5d887cea7e84
# ╟─07c1fc06-d2c8-4512-89b0-9897d62ab35a
# ╟─9eae2846-7b22-4b6c-91db-ffa7cd67be92
# ╟─f2ef9979-8f46-4d1d-a8fd-87d1bcb9abee
# ╟─d06cadc5-bed7-4fbb-8e78-3ad7bc2d1130
# ╟─eba16ced-1971-4636-a867-b66f7d8cc4bc
# ╟─5b74cd45-3432-4d95-bd8b-7b48d7846a15
# ╟─7451c257-6394-4a94-9e2c-ca47982f9000
# ╟─47a18fee-276c-4ea5-afbf-21147bb3ceaa
# ╟─5fd18248-1600-40ca-b3e5-a5c70fa83ff0
# ╟─c275fee5-5a06-49d8-8f24-6931c97d7cac
# ╟─db82ccfe-3223-4af3-bf73-72833ee78d28
# ╟─ee5bd069-2a51-406c-9a74-2fc466a1faaf
# ╟─eb065b6f-5af5-4832-99bf-ed8452f9cef2
# ╟─7c5db96e-6c50-4c9f-83fd-ae4b2d4acdbc
# ╟─31a7d953-bdb3-41b8-ad21-5eb71b951b0b
# ╟─f5b33f69-5767-44ad-b9fa-4074f15262de
# ╟─ed20508e-bfe2-4247-8a8a-cbf1860bfaa1
# ╟─c6270f22-51dc-44a9-80b9-ccd10dbc41ac
# ╟─4a8ce7d3-0315-4d13-9734-c47f7b87d21b
# ╟─f74312b3-54f7-4d3f-902e-3eb6494fc236
# ╟─9cc24dc0-811a-4611-a681-7ba24bbbfad8
# ╟─95a7fe7f-f580-4f26-b47e-a5dac16d49f5
# ╟─719d529a-03e4-4f1b-a438-6dcfa57deec3
# ╟─875a73c8-4c11-4821-b256-6bd3b9ef437d
# ╟─16f078b5-a050-4876-9048-a06d3e2733be
# ╟─765e386b-be08-43d0-ac71-a62d0ebf23c7
# ╟─99b4b3ec-5fde-4728-a49f-7f791ab0e0ad
# ╟─eb77b6e7-2890-447a-98c7-74b581af4dd9
# ╟─f63ea571-6452-42c1-af7e-4fb789304a2d
# ╟─885c0fb2-79b7-48c7-9a63-f6d4f4becb68
# ╟─f61fc2af-e411-4075-bcda-3fd761da58cb
# ╟─3e75a33e-392b-4fd0-9978-07fad6a4faf1
# ╟─d208120a-a450-460f-ab78-c0ca9e99c619
# ╟─82fe8645-a213-44ed-919d-18b0cbb0eeae
# ╟─0e1c20db-5322-4f38-b9e0-f9333b8b743b
# ╟─9afe4152-2414-4826-9d65-489b6ffa7a8f
# ╟─3713b423-0ef4-4685-a22d-39ae73dbb094
# ╟─f41b3285-6ff5-4f16-b936-eca01600b5b4
# ╟─04feec75-3fdd-4a32-9010-7cccf2e93d57
# ╟─7f7c265d-237a-4bcf-98cf-601a360b7095
# ╟─2f641623-6c1c-476b-a57a-ebee39739137
# ╟─7958f21a-63af-47c8-9e7d-31a89ffa1645
# ╟─d52e1caa-3a00-4bcc-9dec-6ac93e4bdb14
# ╟─ccbfccc4-f3fd-4c86-a61e-7f6a2a0cf79b
# ╟─0eb1aa68-5c3a-46c8-9c29-c1288316d57c
# ╟─8d4541b1-83ef-485a-9502-336c079516f7
# ╟─d6a1eca6-19da-411d-bcc7-cd2167678908
# ╟─ca61760e-9156-4d81-834e-e41c747e1e43
# ╟─ece3723e-57a3-4cbc-8c36-9ee8ddc7130c
# ╟─4f74d455-78f9-40ab-b304-b026071d9fd6
# ╟─d160a115-56ed-4598-998e-255b82ec37f9
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002

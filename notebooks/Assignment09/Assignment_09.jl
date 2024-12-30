### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# ╔═╡ d160a115-56ed-4598-998e-255b82ec37f9
# ╠═╡ show_logs = false
#Set-up packages
begin
	
	using Pkg
	#Pkg.upgrade_manifest()
	#Pkg.resolve()
	#Pkg.update()
	
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
TableOfContents(title="Exercise 07", indent=true, depth=2, aside=true)

# ╔═╡ a5de5746-3df0-45b4-a62c-3daf36f015a5
begin 
	html"""
	<p style="padding-bottom:1cm"> </p>
	<div align=center style="font-size:25px; font-family:family:Georgia"> FINC-462/662: Fixed Income Securities </div>
	<p style="padding-bottom:1cm"> </p>
	<p align=center style="font-size:25px; font-family:family:Georgia"> <b> Assignment 09
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

# ╔═╡ e3b00f74-f253-4c2d-96ae-8e43d9c5d032
vspace

# ╔═╡ 7ad75350-14a4-47ee-8c6b-6a2eac09ebb1
md"""
# Question 1
"""

# ╔═╡ c3f1cfaf-fcd4-4829-bcf9-7cadde289ec8
md"""
Suppose you are given the following term structure of interest rates (zero-coupon yields). All interest rates are annual, but semi-annually compounded.

| t           | 0.5   | 1       | 1.5    | 2      |  2.5    | 3     |
|:------------|:------|:--------|:-------|:-------|:--------|:------|
|  Spot rate  | 0.02  | 0.025   | 0.03   | 0.03   | 0.035   | 0.04  |

"""

# ╔═╡ fb21e25a-85ae-447f-8f0c-ff3336794ba9
md"""
__1.1__ What is the value of a three-year floating rate bond that pays coupons semi-annually based on the prevailing half-year spot rate at the start of each period? Suppose that the bond has a face value of \$100.
"""

# ╔═╡ 8a8e6644-2940-41b5-8fee-9d897588226f
Foldable("Solution",md"""
We are at an interest reset date before any interest rates have
changed. Thus, the value of the floating rate bond is its face value, 100.
""")

# ╔═╡ 95795b6b-3095-445e-af30-e5290eb9dd7d
vspace

# ╔═╡ ec2ab381-d098-4949-8704-cb0f16db8121
md"""
__1.2__  What is the value of a three-year zero coupon bond with a face value of \$100?

"""

# ╔═╡ 532d790e-5397-4911-89ce-cad0589c1737
Foldable("Solution",md"""
$P = \frac{100}{\left(1+\frac{4\%}{2}\right)^{2\times 3}} = 88.7971$

""")

# ╔═╡ 71e52081-01bd-4b6f-a272-508226d6188b
vspace

# ╔═╡ c1f9a1b2-8a5b-4d24-87e5-48a4e0f43e1d
md"""
__1.3__ What is the value of a security that has three years to maturity and at each six-month horizon pays $100\times\frac{r}{2}$ (there is no principal cash flow at maturity), where $r$ is the half-year spot rate at the start of the six month period? 
- For example, the first payment is $100\times\frac{0.02}{2} = 1$.
"""

# ╔═╡ 197824b0-1227-4e2b-93c2-88bfd1cacc24
Foldable("Solution",md"""
The security described is the set of coupon payments to the
floating rate bond in (a). The value is 100 - 88.7971 = 11.2029.
""")

# ╔═╡ 9874f738-0777-4782-82bd-4e0fc095b962
vspace

# ╔═╡ 0d2fa9e4-421c-4fe2-ba95-828bef51a94e
md"""
# Question 2
"""

# ╔═╡ 57cd074a-c21d-44e4-bb38-14a19ad4ae8e
md"""
__2.1__ Suppose that it is January 2, 2008. Use the LIBOR curve below. All interest rates are annual, but semi-annually compounded (and given as decimals, i.e. 0.0457 means 4.57%). You enter a 1-year fixed-for-floating interest rate swap with quarterly payments and a \$100mm notional. What is the fair one-year swap rate?

| t     | 1/12   | 2/12   | 3/12  | 4/12  | 5/12 |  6/12 | 7/12  | 8/12   | 9/12  | 10/12  | 11/12   | 12/12  |
|:-----|:-----|:-----|:-----|:-----|:-----|:-----|:-----|:-----|:-----|:-----|:-----  |:-----|
| r     | 0.0457  | 0.0464   | 0.0468  | 0.0465  | 0.0461 | 0.0457 | 0.045  | 0.0442   | 0.0435  | 0.0429  | 0.0424   | 0.0419  |

"""

# ╔═╡ 7e238731-6e10-4af9-abad-8e59f744dc96
Foldable("Solution",md"""
- Recall that we can add a cash flow of the principal amount to the end of both the fixed and floating side without changing anything.

- The value of the floating rate bond is 100. 
- The value of the fixed rate bond is: 

$$\begin{aligned}
	        \frac{C}{\left(1+\frac{0.0468}{2}\right)^{2\times 0.25}} + \frac{C}{\left(1+\frac{0.0457}{2}\right)^{2\times 0.50}} + \frac{C}{\left(1+\frac{0.0435}{2}\right)^{2\times 0.75}} + \frac{C + 100}{\left(1+\frac{0.0419}{2}\right)^{2\times 1.00}}
\end{aligned}$$

- Note that the first payment is in one quarter. Since the discount rates are semi-annually compounded, that is in a half period (one quarter is one half of a half year). Thus, the first cashflow is discounted by
	
$\left(1+\frac{0.0468}{2}\right)^{2\times 0.25}$.
	
- Set the fixed and floating bonds equal: 
	
$$\begin{aligned}
	        \frac{C}{\left(1+\frac{0.0468}{2}\right)^{2\times 0.25}} + \frac{C}{\left(1+\frac{0.0457}{2}\right)^{2\times 0.50}} + \frac{C}{\left(1+\frac{0.0435}{2}\right)^{2\times 0.75}} + \frac{C + 100}{\left(1+\frac{0.0419}{2}\right)^{2\times 1.00}} = 100
\end{aligned}$$
	
$$\rightarrow C = 1.0425$$
	
- Since the cash flow is $C=\frac{f}{4}\times100$, we have $f=4\times C / 100=0.0417$.
	
- The swap rate is $f=4.17\%$.

""")

# ╔═╡ 0d58533e-b618-4d40-9aa2-82affc393335
vspace

# ╔═╡ 334c5066-48c5-467d-9c49-4c450a276cb6
md"""
__2.2__ What is the value of the interest rate swap at inception?"""

# ╔═╡ 5c7ce965-ab98-46d4-a87a-0d4dfd1fa773
Foldable("Solution",md"""
The value of an interest rate swap at inception is 0.
""")

# ╔═╡ 2ce4d1c1-9ba7-4ca1-af50-c3490d01daf8
vspace

# ╔═╡ 520998e4-c8c2-43bf-b109-41edf49d1fad
md"""
__2.3__ Suppose that it is now Feb 1, 2008. Use the LIBOR curve for that date given below. What is the value of the interest rate swap? 

| t     | 1/12   | 2/12   | 3/12  | 4/12  | 5/12 |  6/12 | 7/12  | 8/12   | 9/12  | 10/12  | 11/12   | 12/12  |
|:-----|:-----|:-----|:-----|:-----|:-----|:-----|:-----|:-----|:-----|:-----|:-----  |:-----|
| t     | 0.0314  | 0.0311   | 0.0310  | 0.0307  | 0.0305 | 0.0302 | 0.0297  | 0.0292   | 0.0288  | 0.0285  | 0.0283   | 0.0282  |

- To do this, calculate the present value of the fixed and floating legs separately. Then determine the value of paying fixed and receiving floating.
"""

# ╔═╡ e1a57ffc-3e0d-412e-a863-83be5c83d966
Foldable("Solution",md"""
- Follow the same methodology as before, but with some minor changes. The floating rate bond is no longer worth \$100 because we are not at an interest reset date. 
- On Jan 2, 2008, the first coupon payment was locked in at $\frac{4.68}{4}$. 
- We also know that on the next interest reset date (in 2 months), the bond        will be worth \$100 after the coupon is paid. 
- Thus, the value of the floating rate bond is: 
$$\begin{aligned}
	        \frac{\frac{4.68}{4} + 100}{\left(1+\frac{0.0311}{2}\right)^{2\times \frac{2}{12}}} = 100.65
\end{aligned}$$
	
- The value of the fixed leg is: 
$$\begin{aligned}
	        \frac{1.0425}{\left(1+\frac{0.0311}{2}\right)^{2\times \frac{2}{12}}} + \frac{1.0425}{\left(1+\frac{0.0305}{2}\right)^{2\times \frac{5}{12}}} \frac{1.0425}{\left(1+\frac{0.0292}{2}\right)^{2\times \frac{8}{12}}} + \frac{1.0425+100}{\left(1+\frac{0.0283}{2}\right)^{2\times \frac{11}{12}}} = 101.56
\end{aligned}$$
	
- The value of the fixed-for-floating interest rate swap is 100.65 - 101.56 = -0.91.
""")

# ╔═╡ d9f49d24-d62f-446c-89ed-b0d85f59d7d0
vspace

# ╔═╡ ce159537-5bd7-4bee-8767-b5b9f95f2caa
md"""
# Question 3
"""

# ╔═╡ 094611b7-be02-4df0-9df6-e7deaa09b3b7
md"""
__3.1__ Suppose that you are given the following term structure of interest rates (zero-coupon yields). All interest rates are annual, but semi-annually compounded.
What is the fair fixed rate in an interest rate swap where payments are made semi-annually?

| t           | 0.5    | 1      | 1.5     | 2     | 2.5    | 3      |
|:------------|:-------|:-------|:--------|:------|:-------|:-------|
| Spot rate   | 0.02   | 0.025  | 0.03    | 0.03  | 0.035  | 0.04   |

"""

# ╔═╡ 60002e52-eb89-4ce1-8e08-b570d0281715
Foldable("Solution",md"""
- Use the methodology where we add a principal payment at the end of both the fixed side and the floating side. 
- Thus, the interest rate swap becomes a swap of a fixed-rate bond and a floating-rate bond.
	
- Value of fixed rate bond paying semi-annual coupons of $C$ per period: 
	
$\frac{C}{1.01^{2\times 0.5}} + \frac{C}{1.0125^{2\times 1}} + \frac{C}{1.015^{2\times 1.5}} + \frac{C}{1.015^{2\times 2.0}} + \frac{C}{1.0175^{2\times 2.5}} + \frac{C}{1.02^{2\times 3.0}} + \frac{100}{1.02^{2\times 3.0}}$
	
- Value of the floating rate bond in this case: 
$100$
	
- Set fixed and floating equal: 
$\frac{C}{1.01^{2\times 0.5}} + \frac{C}{1.0125^{2\times 1.0}} + \frac{C}{1.015^{2\times 1.5}} + \frac{C}{1.015^{2\times 2.0}} + \frac{C}{1.0175^{2\times 2.5}} + \frac{C}{1.02^{2\times 3.0}} + \frac{100}{1.02^{2\times 3.0}}=100$
	
- Solving, $C = 1.9762$.
- Since, $C=\frac{f}{2}\times 100$, we get $f = 2\times C/100=2\times 1.9762/100=0.0395$. 
- Thus, the fair fixed rate is 3.95% per year.
	

""")

# ╔═╡ 5b82672f-7979-43f2-9fe8-7bb81069b2c5
vspace

# ╔═╡ 47c9fb2f-8109-4d47-bca2-fe9489ef6b28
md"""
__3.2__ Suppose that you enter into a floating-for-fixed interest rate swap at the rate determined in 3.1. The notional is 100. Suppose that just a few minutes after you enter into this contract, the whole term structure of interest rates increases by one percentage point. What is the value of your interest rate swap position?
"""

# ╔═╡ 0b1c5be7-b95d-4bdb-9756-984e9c93b01a
Foldable("Solution", md"""
- New value of the fixed rate bond: 
$$\begin{aligned}
	        \frac{1.9762}{1.015^{2\times 0.5}} + \frac{1.9762}{1.0175^{2\times 1.0}} + \frac{1.9762}{1.02^{2\times 1.5}} + \frac{1.9762}{1.02^{2\times 2.0}} + \frac{1.9762}{1.0225^{2\times 2.5}} + \frac{1.9762}{1.025^{2\times 3.0}} + \frac{100}{1.025^{2\times 3.0}}=97.2242
\end{aligned}$$
	
- New value of the floating rate bond: 
$$\begin{aligned}
	        \frac{101}{1.015^{2\times 0.5}} = 99.5074
\end{aligned}$$
	
- Value of floating-for-fixed interest rate swap:
$$\begin{aligned}
        \text{Value of fixed coupon bond} - \text{Value of floating rate bond} &= 97.2242 - 99.5074\\
        &= -2.28
\end{aligned}$$
""")

# ╔═╡ d83f5933-6b5c-4420-967d-c2d8559d320f
vspace

# ╔═╡ 84e77f5c-2581-4f49-9a98-87061bc03cce
md"""
__3.3__  Did you make or lose money? What is the intuition behind this?
"""

# ╔═╡ 76b7b437-d1eb-4dc4-b058-cfbea4de2a98
Foldable("Solution",md"""
- Lost money. When interest rates go up, bond values go down.
- However, since fixed coupon bonds are typically more sensitive to interest rates than floating rate bonds, the fixed coupon bond went down in value more. 
- In a floating-for-fixed swap, we are paying floating and receiving fixed. 
- The value of what we are paying went down, but the value of what we are receiving went down more. 
- Thus, we lost money. (Conversely, the person on the other side of the trade made money.)
""")

# ╔═╡ e612f910-87c5-44d5-8088-ac70bf4b2079
vspace

# ╔═╡ 25c38444-81d9-4b3d-8302-78c22f884e0a
md"""
# Question 4
"""

# ╔═╡ 502dc548-40f9-4242-8612-60004f10dd8f
md"""
Suppose that we have the following zero-coupon yields. Assume interest rates are semi-annually compounded.

| Maturity  | r     |
|:----------|------:|
| 0.5       | 0.02  | 
| 1         | 0.025 | 
| 1.5       | 0.03  | 
| 2         | 0.04  | 

"""

# ╔═╡ 4890d07a-131b-4960-8ff2-f6c23cd55569
md"""
**4.1.** What is the fair fixed rate in a 2-year interest rate swap in which fixed and floating payments are exchanged every *six* months?
"""

# ╔═╡ e246ffb6-0721-4b8c-ba78-0cd16657d36e
Foldable("Solution",md"""

$\textrm{Value of Fixed} = \frac{FC/2}{1+\frac{0.02}{2}} + \frac{FC/2}{\left(1+\frac{0.025}{2}\right)^2} + \frac{FC/2}{\left(1+\frac{0.03}{2}\right)^3} + \frac{FC/2}{\left(1+\frac{0.04}{2}\right)^4} + \frac{100}{\left(1+\frac{0.04}{2}\right)^4}$

$\textrm{Value of Floating} = 100$

- Setting the two equal
$FC/2 = 1.98 \rightarrow = FC = 3.96$

- Thus, the fixed rate is $FC/100 = 0.0396$, or $3.96$%.


""")

# ╔═╡ 4da80ca8-3be4-4bda-a0cf-608f39e29695
vspace

# ╔═╡ 43587fed-90ff-418d-82b2-6f32645a4c10
md"""
**4.2.** Treat the two sides of the interest rate swap as a fixed coupon bond and a floating coupon bond as we did in class (by adding the notional to the end of the contract). Calculate the modified durations of the fixed coupon and floating coupon bonds.
"""

# ╔═╡ 597699fe-76e9-49bb-a8c7-8bc51b05bdea
Foldable("Solution",md"""

- MD of fixed:

$P(y) = 100$

$P(y + \Delta y) = \frac{1.98}{1+\frac{0.021}{2}} + \frac{1.98}{\left(1+\frac{0.026}{2}\right)^2} + \frac{1.98}{\left(1+\frac{0.031}{2}\right)^3} + \frac{101.98}{\left(1+\frac{0.041}{2}\right)^4} = 99.8089$

$P(y - \Delta y) = \frac{1.98}{1+\frac{0.019}{2}} + \frac{1.98}{\left(1+\frac{0.024}{2}\right)^2} + \frac{1.98}{\left(1+\frac{0.029}{2}\right)^3} + \frac{101.98}{\left(1+\frac{0.039}{2}\right)^4} = 100.1897$

$MD \approx -\frac{99.8089 - 100.1897}{2\times 0.001}\times \frac{1}{100} = 1.90$

- MD of floating:

$P(y) = 100$
$P(y + \Delta y) = \frac{1 + 100}{1 + \frac{0.021}{2}} = 99.9505$
$P(y - \Delta y) = \frac{1 + 100}{1 + \frac{0.019}{2}} = 100.0495$
$MD \approx - \frac{99.9505 - 100.0495}{2\times 0.001}\times\frac{1}{100} = 0.495$



""")

# ╔═╡ a15db47a-65ea-4d28-9eac-5dfb01fef2dd
vspace

# ╔═╡ 7e808313-db31-4913-a20d-2e3b9a90b82a
md"""
**4.3.** Suppose that half a year passes. The term structure of zero-coupon yields is now as shown below. Assume interest rates are semi-annually compounded.

| Maturity  | r     |
|:----------|------:|
| 0.5       | 0.04  | 
| 1         | 0.045 | 
| 1.5       | 0.05  | 

- If you entered into a fixed-for-floating contract previously (with a notional of \$100), what is the value of your position now? Why did you make or lose money? 
   - *Hint: Think about this in terms of how sensitive each side of the interest rate swap is to a change in interest rates.*
"""

# ╔═╡ 1c659621-2f9c-4fb5-8a02-f9f03f554ff8
Foldable("Solution",md"""

- You have three remaining fixed payments of \$1.98. You will also receive three floating rate payments. The fastest way to solve this is to use the fixed bond for floating bond methodology. Treat this as if you will pay \$1.98 each half-year and also \$100 at maturity – you then receive floating rate payments each half-year and also \$100 at maturity.

**Value of Fixed that you are paying**

$\frac{1.98}{1 + \frac{0.04}{2}} + \frac{1.98}{\left(1 + \frac{0.045}{2}\right)^2} + \frac{101.98}{\left(1+\frac{0.05}{2}\right)^3} = 98.53$

**Value of Floating that you are receiving**
- \$100 since this is a floating rate bond at an interest reset date.  
  - *Note: A common mistake is to re-value the floating, which we need to do if we are not at a reset date.  Here, it is six months later and we are at the next interest reset date.*


$\textrm{Value of fixed-for-floating swap} = 100 - 98.53 = 1.47$

""")

# ╔═╡ 70adf941-e0b0-46e0-b820-35efd6c01d15
vspace

# ╔═╡ e49eaa4a-ae49-4f1a-9e5a-bcc0013eb66b
md"""
# Question 5
"""

# ╔═╡ 45ceaafd-31c2-40c2-bc5a-790133381413
md"""
Suppose that we are considering using the 2-year interest rate swap in Question 4 to hedge interest rate risk. Suppose also that you have a liability where you have to pay \$100 every six months for the next two years.
"""

# ╔═╡ aaaaaf0a-6eb5-4a1d-8530-c4bc4bbb1c29
md"""
**5.1.** Calculate the value and modified duration of your liability.
"""

# ╔═╡ 05dbda18-7078-4586-8357-3b195cdbe1bc
Foldable("Solution",md"""
- Calculating the value of the liability is just a present value problem:

$\frac{100}{1.01} + \frac{100}{1.0125^2} + \frac{100}{1.015^3} + \frac{100}{1.02^4} = 384.57$

- Modified Duration:

$P(y + \Delta y) = \frac{100}{1.0105} + \frac{100}{1.013^2} + \frac{100}{1.0155^3} + \frac{100}{1.0205^4} = 384.1049$

$P(y - \Delta y) = \frac{100}{1.0095} + \frac{100}{1.012^2} + \frac{100}{1.0145^3} + \frac{100}{1.0195^4} = 385.0405$

$MD \approx -\frac{384.1049 - 385.0405}{2\times 0.001}\times\frac{1}{384.57} = 1.216$

""")

# ╔═╡ f9bd0430-f27f-4a9a-9011-56251496f5bd
vspace

# ╔═╡ 7c712f48-edf1-4ef8-b45c-c371a9cdfb98
md"""
**5.2.** If you want to enter into the two-year interest rate swap contract from Part 1 to hedge against this liability, do you want to enter into floating-for-fixed or fixed-for-floating? Explain why.
  - *Hint: Start by writing down the liability from Q1 on a balance sheet. If interest rates decrease, the value of your liability will increase. You will want to choose your interest rate swap position to offset this increase.*
"""

# ╔═╡ c7f8b043-7e5c-48e3-b2a4-8144f448d201
Foldable("Solution",md"""
- As interest rates decline, the value of your liability goes up. In an interest rate swap, as interest rates go down, the value of fixed goes up by more than the value of floating. If you enter into a floating-for-fixed interest rate swap, the value of your swap will increase in value (since you are receiving fixed) and help to offset the increase in the value of your liabilities. Thus, you want to enter into a floating-for-fixed interest rate swap to hedge against increases in value of the liability.
""")

# ╔═╡ 08802738-5ed0-4ded-b83d-fdb2e6120fbd
vspace

# ╔═╡ 6f3047ac-576d-49bf-8fe7-2d93994b0bca
md"""
**5.3.** Solve for how much of the interest rate swap contract to enter into.
  - *Hint: On one side of the balance sheet, write down \$x in a fixed coupon bond. On the other side, write down \$x of a floating rate bond. You already have their MD’s from Question 4. Then, set-up an MD quation and solve for x.*
"""

# ╔═╡ 7acb9eb6-38ec-418c-8fe9-5a6866ca572c
Foldable("Solution",md"""
- Setting up the balance sheet

|        Assets |      Liabilities      |
|:--------------|----------------------:|
| Fixed side of Interest Rate Swap  $x$ | Floating side of Interest Rate Swap  $x$ |
| $MD \approx 1.9$ | $MD \approx 0.495$ |
| | |
|                   | Liability & 384.57 |
|                   | $MD \approx 1.216$ |

- Setting up the equation:
$1.9\times x = 0.495\times x + 1.216\times(384.57)$

$\rightarrow x = 332.84$

""")

# ╔═╡ 8dcae432-0a93-4c18-83b9-24ee0de50c83
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
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
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

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "92fd5d4472f184bcf241ac3744b00ba757d302aa"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "c6d890a52d2c4d55d326439580c3b8d0875a77d9"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.7"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random", "SnoopPrecompile"]
git-tree-sha1 = "aa3edc8f8dea6cbfa176ee12f7c2fc82f0608ed3"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.20.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "600cc5508d66b78aae350f7accdb58763ac18589"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.10"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "00a2cccc7f098ff3b66806862d275ca3db9e6e5a"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.5.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "e8119c1a33d267e16108be441a287a6981ba1630"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.14.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "db2a9cb664fcea7836da4b414c3278d71dd602d2"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.6"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "387d2b8b3ca57b791633f0993b31d8cb43ea3292"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.71.3"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "5982b5e20f97bff955e9a2343a14da96a746cd8c"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.71.3+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "d3b3624125c1474292d0d8ed0f65554ac37ddb23"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.74.0+2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "eb5aa5e3b500e191763d35198f859e4b40fff4a6"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.7.3"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.InvertedIndices]]
git-tree-sha1 = "82aec7a3dd64f4d9584659dc0b62ef7db2ef3e19"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.2.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "f377670cda23b6b7c1c0b3893e37451c5c1a2185"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.5"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "2422f47b34d4b127720a18f86fa7b1aa2e141f29"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.18"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c7cb1f5d892775ba13767a87c7ada0b980ea0a71"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+2"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "946607f84feb96220f480e0422d3484c49c00239"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.19"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "cedb76b37bc5a6c702ade66be44f831fa23c681e"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "6503b77492fd7fcb9379bf73cd31035670e3c509"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.3.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6e9dba33f9f2c44e08a020b0caf6903be540004"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.19+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "8175fc2b118a3755113c8e68084dc1a9e63c61ee"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.3"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "5b7690dd212e026bbab1860016a6601cb077ab66"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.2"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Preferences", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SnoopPrecompile", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "a99bbd3664bb12a775cda2eba7f3b2facf3dad94"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.38.2"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eadad7b14cf046de6eb41f13c9275e5aa2711ab6"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.49"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
deps = ["SnoopPrecompile"]
git-tree-sha1 = "261dddd3b862bd2c940cf6ca4d1c8fe593e457c8"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.3"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase", "SnoopPrecompile"]
git-tree-sha1 = "e974477be88cb5e3040009f3767611bc6357846f"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.11"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "a4ada03f999bd01b3a25dcaa30b2d929fe537e00"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.0"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "c79322d36826aa2f4fd8ecfa96ddb47b174ac78d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "94f38103c984f89cf77c402f2a68dbd870f8165f"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.11"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "ac00576f90d8a259f2c9d823e91d1de3fd44d348"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "ed8d92d9774b077c53e1da50fd81a36af3744c1c"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "93c41695bc1c08c46c5899f4fe06d6ead504bb73"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.10.3+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "868e669ccb12ba16eaf50cb2957ee2ff61261c56"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.29.0+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
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
# ╟─e3b00f74-f253-4c2d-96ae-8e43d9c5d032
# ╟─7ad75350-14a4-47ee-8c6b-6a2eac09ebb1
# ╟─c3f1cfaf-fcd4-4829-bcf9-7cadde289ec8
# ╟─fb21e25a-85ae-447f-8f0c-ff3336794ba9
# ╟─8a8e6644-2940-41b5-8fee-9d897588226f
# ╟─95795b6b-3095-445e-af30-e5290eb9dd7d
# ╟─ec2ab381-d098-4949-8704-cb0f16db8121
# ╟─532d790e-5397-4911-89ce-cad0589c1737
# ╟─71e52081-01bd-4b6f-a272-508226d6188b
# ╟─c1f9a1b2-8a5b-4d24-87e5-48a4e0f43e1d
# ╟─197824b0-1227-4e2b-93c2-88bfd1cacc24
# ╟─9874f738-0777-4782-82bd-4e0fc095b962
# ╟─0d2fa9e4-421c-4fe2-ba95-828bef51a94e
# ╟─57cd074a-c21d-44e4-bb38-14a19ad4ae8e
# ╟─7e238731-6e10-4af9-abad-8e59f744dc96
# ╟─0d58533e-b618-4d40-9aa2-82affc393335
# ╟─334c5066-48c5-467d-9c49-4c450a276cb6
# ╟─5c7ce965-ab98-46d4-a87a-0d4dfd1fa773
# ╟─2ce4d1c1-9ba7-4ca1-af50-c3490d01daf8
# ╟─520998e4-c8c2-43bf-b109-41edf49d1fad
# ╟─e1a57ffc-3e0d-412e-a863-83be5c83d966
# ╟─d9f49d24-d62f-446c-89ed-b0d85f59d7d0
# ╟─ce159537-5bd7-4bee-8767-b5b9f95f2caa
# ╟─094611b7-be02-4df0-9df6-e7deaa09b3b7
# ╟─60002e52-eb89-4ce1-8e08-b570d0281715
# ╟─5b82672f-7979-43f2-9fe8-7bb81069b2c5
# ╟─47c9fb2f-8109-4d47-bca2-fe9489ef6b28
# ╟─0b1c5be7-b95d-4bdb-9756-984e9c93b01a
# ╟─d83f5933-6b5c-4420-967d-c2d8559d320f
# ╟─84e77f5c-2581-4f49-9a98-87061bc03cce
# ╟─76b7b437-d1eb-4dc4-b058-cfbea4de2a98
# ╟─e612f910-87c5-44d5-8088-ac70bf4b2079
# ╟─25c38444-81d9-4b3d-8302-78c22f884e0a
# ╟─502dc548-40f9-4242-8612-60004f10dd8f
# ╟─4890d07a-131b-4960-8ff2-f6c23cd55569
# ╟─e246ffb6-0721-4b8c-ba78-0cd16657d36e
# ╟─4da80ca8-3be4-4bda-a0cf-608f39e29695
# ╟─43587fed-90ff-418d-82b2-6f32645a4c10
# ╟─597699fe-76e9-49bb-a8c7-8bc51b05bdea
# ╟─a15db47a-65ea-4d28-9eac-5dfb01fef2dd
# ╟─7e808313-db31-4913-a20d-2e3b9a90b82a
# ╟─1c659621-2f9c-4fb5-8a02-f9f03f554ff8
# ╟─70adf941-e0b0-46e0-b820-35efd6c01d15
# ╟─e49eaa4a-ae49-4f1a-9e5a-bcc0013eb66b
# ╟─45ceaafd-31c2-40c2-bc5a-790133381413
# ╟─aaaaaf0a-6eb5-4a1d-8530-c4bc4bbb1c29
# ╟─05dbda18-7078-4586-8357-3b195cdbe1bc
# ╟─f9bd0430-f27f-4a9a-9011-56251496f5bd
# ╟─7c712f48-edf1-4ef8-b45c-c371a9cdfb98
# ╟─c7f8b043-7e5c-48e3-b2a4-8144f448d201
# ╟─08802738-5ed0-4ded-b83d-fdb2e6120fbd
# ╟─6f3047ac-576d-49bf-8fe7-2d93994b0bca
# ╟─7acb9eb6-38ec-418c-8fe9-5a6866ca572c
# ╟─8dcae432-0a93-4c18-83b9-24ee0de50c83
# ╟─d160a115-56ed-4598-998e-255b82ec37f9
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002

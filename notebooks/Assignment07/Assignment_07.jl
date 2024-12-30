### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# ╔═╡ 9dba51e3-0738-40a1-96d8-f5583cdc5729
# ╠═╡ show_logs = false
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

# ╔═╡ 41d7b190-2a14-11ec-2469-7977eac40f12
#add button to trigger presentation mode
html"<button onclick='present()'>present</button>"

# ╔═╡ 731c88b4-7daf-480d-b163-7003a5fbd41f
begin 
	html"""
	<p align=left style="font-size:36px; font-family:family:Georgia"> <b> FINC 462/662 - Fixed Income Securities</b> <p>
	"""
end

# ╔═╡ a5de5746-3df0-45b4-a62c-3daf36f015a5
begin 
	html"""
	<p style="padding-bottom:1cm"> </p>
	<div align=center style="font-size:25px; font-family:family:Georgia"> FINC-462/662: Fixed Income Securities </div>
	<p style="padding-bottom:1cm"> </p>
	<p align=center style="font-size:25px; font-family:family:Georgia"> <b> Assignment 7</b> <p>
	<p align=center style="font-size:25px; font-family:family:Georgia"> <b> Hedging and Bond Trading Strategies</b> <p>
	<p style="padding-bottom:1cm"> </p>
	<p align=center style="font-size:25px; font-family:family:Georgia"> Spring 2023 <p>
	<p style="padding-bottom:0.5cm"> </p>
	<div align=center style="font-size:20px; font-family:family:Georgia"> Prof. Matt Fleckenstein </div>
	<p style="padding-bottom:0.25cm"> </p>
	<div align=center style="font-size:20px; font-family:family:Georgia"> University of Delaware, 
	Lerner College of Business and Economics </div>
	<p style="padding-bottom:0cm"> </p>
	"""
end

# ╔═╡ 8bcc8106-31e8-4212-8f9e-8800e5737b11
vspace

# ╔═╡ 657e8ee4-5df9-42c1-8639-ba5ab37b51b4
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
	display("")
end

# ╔═╡ af866ea7-e8eb-4774-8d0d-66b4da87a01e
begin
	r4 = 5.0 #percent
	F4_1 = 1000
	T4_1 = 15
	T4_2 = 7
	MD4_1 = T4_1/(1+r4/100)
	MD4_2 = T4_2/(1+r4/100)
	P4_1 = F4_1/(1+(r4/100))^T4_1
	P4_2 = F4_1/(1+(r4/100))^T4_2
	T4_3 = 30

	lhs4 = [MD4_2 (T4_3/(1+r4/100))
         (0.5*(T4_2^2+T4_2)/(1+r4/100)^2) (0.5*(T4_3^2+T4_3)/(1+r4/100)^2)]
 	rhs4 = [(MD4_1*P4_1), (0.5*P4_1*(T4_1^2+T4_1)/(1+r4/100)^2)]
 	sol4 = inv(lhs4)*rhs4
		
	html"""<hr>"""
end

# ╔═╡ be7ce534-0249-42f5-8365-9af47376aa5b
vspace

# ╔═╡ 8c5d9a78-9040-41fc-94f2-a6aab6da5c6d
md"""
## Exercise 1
"""

# ╔═╡ 90f57146-71c8-448e-a644-7039853050c0
Markdown.parse("
- Suppose that we are a large firm and that we have issued a bond with \$ $(F4_1) par value. The bond is a zero-coupon bond with maturity in $(T4_1) years.
- Suppose that all interest rates are $(r4)% (annually compounded).
- To hedge our exposure, we can buy/sell a $(T4_2)-year zero-coupon bond in the financial market.
- Implement a duration hedge. What is the dollar position in the  $(T4_2)-year zero-coupon that we need to take to hedge the interest rate risk of the bond issue? 
")


# ╔═╡ 225cef3a-33eb-4aee-83af-442b441d4adc
vspace

# ╔═╡ 31be29e2-2457-4ef9-a95f-b2ac742ecd97
md"""
**Solution**
"""

# ╔═╡ 9ac02b23-b9fe-4061-93ad-bf79d9bd0d01
Markdown.parse("
- The value and the modified durations of the bonds are:
  -  ``P_{$(T4_1)}`` is the value in the $(T4_1)-year bond, i.e. `$(roundmult(P4_1,1e-4))`.
  -  ``P_{$(T4_2)}`` is the value in the $(T4_2)-year bond, i.e. `x`.

  -  ``MD_{$(T4_1)}`` = `$(roundmult(MD4_2,1e-4))`
  -  ``MD_{$(T4_2)}`` = `$(roundmult(MD4_1,1e-4))`
")

# ╔═╡ 6ae264cd-edc4-4abe-8b1e-9b34f664e314
Markdown.parse("
Assets            |  Liabilities
:-----------------|:--------------------
 $(T4_2)-year bond: `x` | $(T4_1)-year Bond: `$(roundmult(P4_1,1e-4))`
 ``MD_{$(T4_2)}``: `$(roundmult(MD4_2,1e-4))`| ``MD_{$(T4_1)}``: `$(roundmult(MD4_1,1e-4))`
``\\Delta P_{$(T4_2)}= x \\times (-$(roundmult(MD4_2,1e-4))) \\times \\Delta y`` | ``\\Delta P_{$(T4_1)}=$(roundmult(P4_1,1e-4)) \\times (-$(roundmult(MD4_1,1e-4))) \\times \\Delta y``
")

# ╔═╡ 04969d91-8e9b-44b0-8517-60b59c5f2ebe
Markdown.parse("
- To hedge the interest rate risk, we need to have
``\$x \\times (-$(roundmult(MD4_2,1e-4))) \\times \\Delta y \\stackrel{!}{=} $(roundmult(P4_1,1e-4)) \\times (-$(roundmult(MD4_1,1e-4))) \\times \\Delta y\$``
- Thus, our position on the $(T4_2)-year zero coupon bond ``x`` must be
``\$x = $(roundmult(P4_1,1e-4)) \\times \\frac{(-$(roundmult(MD4_1,1e-4)))}{(-$(roundmult(MD4_2,1e-4)))} = $(roundmult(P4_1*MD4_1/MD4_2,1e-4))\$``
- Thus, we buy \$ ``$(roundmult(P4_1*MD4_1/MD4_2,1e-4))`` of the $(T4_2)-year zero-coupon bond.
")

# ╔═╡ 796384ef-7f3d-4423-8748-45a2a892c34b
Markdown.parse("
- Pluggin in the market value of the $(T4_2)-year bond and solving for the face value ``F``
``\$ $(roundmult(P4_1*MD4_1/MD4_2,1e-4)) = \\frac{F}{(1+$(r4)\\%)^$(T4_2)}\$``
``\$ F= \\\$ $(roundmult(P4_1*MD4_1/MD4_2*(1+r4/100)^T4_2,1e-2))\$``
")

# ╔═╡ 0d010810-a2f9-4f78-a173-abb96eae4ecb
vspace

# ╔═╡ 2cd77b86-5578-4d2c-9650-c654f0322602
md"""
## Exercise 2
"""

# ╔═╡ 96463334-3f79-4086-848e-240b2532e563
md"""
- Suppose that we are managing a pension fund and have a liability of \$100mm per year for the next 100 years. Assume that the discount rate is 5% regardless of maturity (term structure is flat). Suppose that the pension fund is currently fully funded (i.e., the fund has cash in the amount of the current market value of the liability).
- Use 1-year and 30-year zero-coupon bonds to form a portfolio that hedges our liability.
- What are the position in the 1-year and the 30-year zero-coupon bonds that we need to take to hedge our liability (using a duration hedge).
"""

# ╔═╡ 8b8220f2-bfe4-45d9-968d-ed256a98bf79
vspace

# ╔═╡ ab4d9779-a1cf-49b2-87ff-9e4d523ea77f
md"""
**Solution**
"""

# ╔═╡ 88f518bb-a3be-46e9-95eb-65424dbf0708
md"""
- Let’s first value the pension liability. 

$\text{Value of Liability} = 100\times \frac{1}{0.05}\left[1 - \frac{1}{1.05^{100}}\right]= 1984.79102$.

- Let’s also suppose that the pension fund currently has 1984.79102 in cash. That is, the pension fund is neither under- nor overfunded.
"""

# ╔═╡ 05b4cca7-e2e0-40e5-a653-0f3a9751e92c
md"""
- Next, we calculate the modified duration of our liability.
$\textrm{Value of liability @ 5.0\%} = 1984.79102$

$\textrm{Value of liability @ 5.1\%} = 100\times \frac{1}{0.051}\left[1-\frac{1}{1.051^{100}}\right] = 1947.227482$

$\textrm{Value of liability @ 4.9\%} = 100\times \frac{1}{0.049}\left[1-\frac{1}{1.049^{100}}\right] = 2023.745478$

$MD \approx -\frac{1947.227482 - 2023.745478}{2\times 0.001} \times \frac{1}{1984.79102} = 19.2761$

- *Note how we can use our MD approximation formula even though it's not a bond.*
"""

# ╔═╡ 7033fc1f-f60b-44dc-8f37-f04adf486857
md"""
- Let's add the modified durations of the asset and liability sides.


|       Assets   |             |      Liabilities          |
|:---------------|:------------|--------------------------:|
| 1yr            | 30yr        |        Pension            |
| \$x            | \$z         |   \$1984.79102            |
| $MD = \frac{1}{1.05} = 0.9524$ | $MD = \frac{30}{1.05} = 28.5714$ | $MD = 19.2761$ |

Modified Duration Constraint:
$-0.9524x - 28.5714z = -19.2761(1984.79102)$

Assets = Liabilities Constraint:
$x + z = 1984.79102$

Solving: $x = 667.9925$, $z = 1316.799$

Face values: 
- 1yr:  $701.3921$
  -  Calculation: $667.9925\times (1.05)$
- 30yr: $5691.127$ 
  - Calculation: $1316.799\times(1.05)^{30}$
"""

# ╔═╡ f9fa048e-2a26-48a3-99c2-a107162439e8
md"""
- Thus, our hedging portfolio is as shown below.

|       Assets   |             |      Liabilities          |
|:---------------|:------------|--------------------------:|
| 1yr            | 30yr        |        Pension            |
| \$ 667.9925    | \$1316.799  |   \$1984.79102            |
"""

# ╔═╡ 09fc0f42-fdb2-4a50-88ae-e9c3da739d2f
vspace

# ╔═╡ a502041d-58ff-4d3b-b745-231fd6b21ac9
md"""
## Exercise 3
"""

# ╔═╡ f0a85acc-effa-4e3a-95e4-1be30a0b69f0
Markdown.parse("
- Suppose that we are a large firm and that we have issued a bond with \$ $(F4_1) par value. The bond is a zero-coupon bond with maturity in $(T4_1) years. Suppose that all interest rates are $(r4)% (annually compounded).
- Use $(T4_2) and $(T4_3)-year zero coupon bonds to hedge our interest rate risk using a duration-and-convexity hedge. What positions in the $(T4_2) and $(T4_3)-year zero coupon bonds do we need to take?

")

# ╔═╡ 0e211169-0204-4582-936d-feecf2aec3cd
vspace

# ╔═╡ f3d6b12c-3d76-4058-a0c9-e8bfc53e2143
md"""
**Solution**
"""

# ╔═╡ f8a823ae-1aa1-41c7-b88c-283f541b067d
Markdown.parse("
- Let's first calculate the duration, convexity, the percentage price change and the dollar price in response to a yield change ``\\Delta y`` for each of the three bonds.

")

# ╔═╡ fe0d9d46-2c7f-42ba-bb04-ccb741631e7c
Markdown.parse("
- ``$(T4_1)``-year Zero-coupon bond (liability)
  - ``MD_{$(T4_1)}=\\frac{T}{1+y} = \\frac{$(T4_1)}{1+$(r4)\\%} = $(roundmult(T4_1/(1+r4/100),1e-4))``
  - ``\\textrm{CX}_{$(T4_1)}= \\frac{T^2+T}{(1+y)^2}=\\frac{$(T4_1^2+T4_1)}{(1+$(r4)\\%)^2} = $(roundmult((T4_1^2+T4_1)/(1+r4/100)^2,1e-4))``
  - ``\\frac{\\Delta P_{$(T4_1)}}{P_{$(T4_1)}}= - MD_{$(T4_1)} \\times \\Delta y + \\frac{1}{2} \\times CX_{$(T4_1)} \\times \\left( \\Delta y \\right)^2``
  - ``\\Delta P_{$(T4_1)} = P_{$(T4_1)} \\times (- MD_{$(T4_1)}) \\times \\Delta y + P_{$(T4_1)} \\times \\frac{1}{2} \\times CX_{$(T4_1)} \\times \\left( \\Delta y \\right)^2``")


# ╔═╡ 020b481e-a212-430f-9744-b369d23bab74
Markdown.parse("
- ``$(T4_2)``-year Zero-coupon bond (liability)
  - ``MD_{$(T4_2)}=\\frac{T}{1+y} = \\frac{$(T4_2)}{1+$(r4)\\%} = $(roundmult(T4_2/(1+r4/100),1e-4))``
  - ``\\textrm{CX}_{$(T4_2)}= \\frac{T^2+T}{(1+y)^2}=\\frac{$(T4_2^2+T4_2)}{(1+$(r4)\\%)^2} = $(roundmult((T4_2^2+T4_2)/(1+r4/100)^2,1e-4))``
  - ``\\frac{\\Delta P_{$(T4_2)}}{P_{$(T4_2)}}= - MD_{$(T4_2)} \\times \\Delta y + \\frac{1}{2} \\times CX_{$(T4_2)} \\times \\left( \\Delta y \\right)^2``
  - ``\\Delta P_{$(T4_2)} = P_{$(T4_2)} \\times (- MD_{$(T4_2)}) \\times \\Delta y + P_{$(T4_2)} \\times \\frac{1}{2} \\times CX_{$(T4_2)} \\times \\left( \\Delta y \\right)^2``


")

# ╔═╡ c6ea0fc5-80ea-4f99-8426-590ed5917b66
Markdown.parse("
- ``$(T4_3)``-year Zero-coupon bond (liability)
  - ``MD_{$(T4_3)}=\\frac{T}{1+y} = \\frac{$(T4_3)}{1+$(r4)\\%} = $(roundmult(T4_3/(1+r4/100),1e-4))``
  - ``\\textrm{CX}_{$(T4_3)}= \\frac{T^2+T}{(1+y)^2}=\\frac{$(T4_3^2+T4_3)}{(1+$(r4)\\%)^2} = $(roundmult((T4_3^2+T4_3)/(1+r4/100)^2,1e-4))``
  - ``\\frac{\\Delta P_{$(T4_3)}}{P_{$(T4_3)}}= - MD_{$(T4_3)} \\times \\Delta y + \\frac{1}{2} \\times CX_{$(T4_3)} \\times \\left( \\Delta y \\right)^2``
  - ``\\Delta P_{$(T4_3)} = P_{$(T4_3)} \\times (- MD_{$(T4_3)}) \\times \\Delta y + P_{$(T4_3)} \\times \\frac{1}{2} \\times CX_{$(T4_3)} \\times \\left( \\Delta y \\right)^2``
")

# ╔═╡ f8582e96-7877-439b-870b-b68a551411f7
Markdown.parse("
- Next, let's write down the balance sheet.
Assets            |  Liabilities
:-----------------|:--------------------
 $(T4_2)-year bond: `x` | $(T4_1)-year Bond: `$(roundmult(P4_1,1e-4))`
 ``MD_{$(T4_2)}``: `$(roundmult(MD4_2,1e-4))`| ``MD_{$(T4_1)}``: `$(roundmult(MD4_1,1e-4))`
``\\textrm{CX}_{$(T4_2)}``: `$(roundmult((T4_2^2+T4_2)/(1+r4/100)^2,1e-4))` | ``\\textrm{CX}_{$(T4_1)}``: `$(roundmult((T4_1^2+T4_1)/(1+r4/100)^2,1e-4))`
``\\Delta P_{$(T4_2)}= x \\times (-$(roundmult(MD4_2,1e-4))) \\times \\Delta y + x \\times \\frac{1}{2} ($(roundmult((T4_2^2+T4_2)/(1+r4/100)^2,1e-4))) \\times (\\Delta y)^2`` | ``\\Delta P_{$(T4_1)}=$(roundmult(P4_1,1e-4)) \\times (-$(roundmult(MD4_1,1e-4))) \\times \\Delta y + $(roundmult(P4_1,1e-4)) \\times \\frac{1}{2} ($(roundmult((T4_1^2+T4_1)/(1+r4/100)^2,1e-4))) \\times (\\Delta y)^2``
                       |
$(T4_3)-year bond: `z` |
``MD_{$(T4_3)}``: `$(roundmult(T4_3/(1+r4/100),1e-4))`|
``\\textrm{CX}_{$(T4_3)}`` `$(roundmult((T4_3^2+T4_3)/(1+r4/100)^2,1e-4))` |
``\\Delta P_{$(T4_3)}= z \\times (-$(roundmult(T4_3/(1+r4/100),1e-4))) \\times \\Delta y + z \\times \\frac{1}{2} ($(roundmult((T4_3^2+T4_3)/(1+r4/100)^2,1e-4))) \\times (\\Delta y)^2`` |
")

# ╔═╡ 7c22ab3a-6678-4e50-b417-8a51f36e4917
Markdown.parse("
- This means, we need to have
``\$ \\Delta P_{$(T4_2)} + \\Delta P_{$(T4_3)} = \\Delta P_{$(T4_1)}\$``
")

# ╔═╡ 1fdd2193-0519-49ea-b57c-e94726de49f3
Markdown.parse("
``\$ x \\times (-$(roundmult(MD4_2,1e-4))) \\times \\Delta y + x \\times \\frac{1}{2} ($(roundmult((T4_2^2+T4_2)/(1+r4/100)^2,1e-4))) \\times (\\Delta y)^2 + \$``
``\$ z \\times (-$(roundmult(T4_3/(1+r4/100),1e-4))) \\times \\Delta y + z \\times \\frac{1}{2} ($(roundmult((T4_3^2+T4_3)/(1+r4/100)^2,1e-4))) \\times (\\Delta y)^2 = \$``
``\$ $(roundmult(P4_1,1e-4)) \\times (-$(roundmult(MD4_1,1e-4))) \\times \\Delta y + $(roundmult(P4_1,1e-4)) \\times \\frac{1}{2} ($(roundmult((T4_1^2+T4_1)/(1+r4/100)^2,1e-4))) \\times (\\Delta y)^2 \$``
")

# ╔═╡ c4a0dba8-f203-47e7-9625-7a71238790d0
Markdown.parse("
- Terms in ``\\Delta y``: **Modified Duration Equation**

``\$ x \\times (-$(roundmult(MD4_2,1e-4))) \\times \\Delta y + z \\times (-$(roundmult(T4_3/(1+r4/100),1e-4))) \\times \\Delta y  =$(roundmult(P4_1,1e-4)) \\times (-$(roundmult(MD4_1,1e-4))) \\times \\Delta y \$``

")

# ╔═╡ 16a07c05-9982-4305-b8ec-eac332fa7774
Markdown.parse("
- Terms in ``(\\Delta y)^2``: **Convexity Equation**

``\$ x \\times \\frac{1}{2} ($(roundmult((T4_2^2+T4_2)/(1+r4/100)^2,1e-4))) \\times (\\Delta y)^2 + z \\times \\frac{1}{2} ($(roundmult((T4_3^2+T4_3)/(1+r4/100)^2,1e-4))) \\times (\\Delta y)^2 = $(roundmult(P4_1,1e-4)) \\times \\frac{1}{2} ($(roundmult((T4_1^2+T4_1)/(1+r4/100)^2,1e-4))) \\times (\\Delta y)^2\$``
")

# ╔═╡ 83688847-afb0-44b9-a004-3a978f19dbc9
Markdown.parse("
- The solution to this system of 2 equations in 2 unknowns is 
``\$x = $(roundmult(sol4[1],1e-4)), z = $(roundmult(sol4[2],1e-4))\$``
- Thus, we enter a position with market value of \$ $(roundmult(sol4[1],1e-4)) in the $(T4_2)-year bond, and a position with market value of \$ $(roundmult(sol4[2],1e-4)) in the $(T4_3)-year bond.
- The corresponding face values in the ``$(T4_2)``-year bond and the ``$(T4_3)``-year bonds are
\$F_{$(T4_2)} = $(roundmult(sol4[1]*(1+r4/100)^T4_2,1e-2))\$
\$F_{$(T4_3)} = $(roundmult(sol4[2]*(1+r4/100)^T4_3,1e-2))\$
")

# ╔═╡ abd91e21-32d1-4d65-b535-1f241e0346c2
Markdown.parse("
- The balance sheet is now
- Next, let's write down the balance sheet as in the previous example.
Assets            |  Liabilities
:-----------------|:--------------------
 $(T4_2)-year bond: `$(roundmult(sol4[1],1e-4))` | $(T4_1)-year Bond: `$(roundmult(P4_1,1e-4))`
Face value ``F_{$(T4_2)}``: $(roundmult(sol4[1]*(1+r4/100)^T4_2,1e-2)) | Face value ``F_{$(T4_1)}``: $(roundmult(F4_1,1e-2))
                        |
$(T4_3)-year bond: `$(roundmult(sol4[2],1e-4))` |
Face value ``F_{$(T4_3)}``: $(roundmult(sol4[2]*(1+r4/100)^T4_3,1e-2)) | 
")

# ╔═╡ be90841e-c3eb-407b-8f6a-307c16ea49a8
vspace

# ╔═╡ 8c51274f-6bf0-4130-9671-aebd7d06a4b6
md"""
## Exercise 4
"""

# ╔═╡ 25a391f9-505d-4d00-8408-0bfbb6745c6a
md"""
- Suppose you are given the following table with zero-coupon yields (annually compounded) for one-year, two-year, three-year, four-year, and five-year zero coupon bonds on the dates indicated in the first column.
"""

# ╔═╡ 266cb4ca-3fbe-4929-8d6b-ff9b6202a4e2
# ╠═╡ show_logs = false
begin
 Dates_01 = Date.(["1/29/2010","2/26/2010","3/31/2010","4/30/2010","5/28/2010",
"6/30/2010","7/30/2010","8/31/2010","9/30/2010","10/29/2010","11/30/2010","12/31/2010"],dateformat"mm/dd/yyyy")

# yields are annually compounded.
yield1=[0.003,
0.0032,
0.0041,
0.0041,
0.0034,
0.0032,
0.0029,
0.0025,
0.0027,
0.0022,
0.0027,
0.0029]
	
yield2=
[0.0082214,
0.0081199,
0.0102313,
0.0097273,
0.007616,
0.0061089,
0.0055072,
0.0047052,
0.0042032,
0.003402,
0.0045041,
0.0061098]
	
yield3 = 
[0.0139027,
0.0136984,
0.0161273,
0.0152114,
0.0126817,
0.0100491,
0.0084319,
0.0072234,
0.0064174,
0.0051108,
0.0072239,
0.0102532]

yield4 = 
[0.0188426,
0.0185329,
0.0210274,
0.0199498,
0.0169909,
0.0140862,
0.0123058,
0.0103228,
0.0096154,
0.0084555,
0.0110401,
0.0153251]

yield5 = 
[0.0238826,
0.0234634,
0.0260306,
0.0247838,
0.0213768,
0.0181879,
0.0162378,
0.0134595,
0.0128522,
0.0118416,
0.0149114,
0.0204958]

df_1 = DataFrame(Date = Dates_01, OneYearYield=yield1, TwoYearYield=yield2, ThreeYearYield=yield3, FourYearYield=yield4, FiveYearYield=yield5)
#display("")
end

# ╔═╡ fa6da482-6110-4cbb-91c0-39131115b9e4
md"""
**1.**  It is November 30, 2010 and you hold a \$1 million (market value) long position in the 1-yr zero-coupon bond. Using modified durations, determine how much of the 5-yr zero-coupon bond you need to short so that your portfolio remains approximately unchanged if the 1-yr and 5-yr zero rates move in parallel. What is the market value of your portfolio?
  - *Note: This portfolio strategy is known as a steepener trade as you profit if the yield curve becomes steeper.*
"""

# ╔═╡ 6ae76da9-f233-4deb-b35b-53c9597b3b9f
Foldable("Solution",Markdown.parse("

\$y_1 = 0.27\\%, \\, y_5 = 1.4911\\%\$
\$MD_1 = \\frac{1}{1.0027} = 0.9973, \\,\\, MD_5 = \\frac{5}{1.014911}=4.9265\$

| Assets |  Liabilities |
|:-------|:-------------|
|\$1mm in 1-yr | \$x in 5-yr |
| ``MD_1=0.9973`` | ``MD_5``=4.9265 |
| If ``\\Delta y`` = 1% | If ``\\Delta y`` = 1% |
| ``\\Delta P \\approx 1,000,000(-0.009973)`` | ``\\Delta P \\approx x(-0.049265)`` |


\$0.9973\\times (1,000,000) = 4.9265 \\times x\$

\$\\rightarrow x = 202,435.7\$ 

$(L"\textrm{or 217,985.58 in face value of 5-year bond.}")

- The current portfolio value is \$ 1,000,000 - \$ 202,435.70 = \$797,564.30.
- Also note that \$ 1 million in market value of the 1-year bond is equivalent to 1,002,700 in face value of the 1-year bond.

"))

# ╔═╡ 8090852b-068d-408e-bc9e-6802e61df5ad
vspace

# ╔═╡ 2f360a18-76f1-48ba-9c7a-43ced4ec2fc7
md"""
**2.** Now, suppose that you enter into the position in (1). What actually happens during the following month? Calculate the value of your portfolio. A 1-yr bond is now an 11-month bond and a 5-yr bond becomes a 4-year 11-month bond. Assume for pricing purposes that the 5-yr rate applies to the 4-yr 11-month bond and the 1-yr rate applies to an 11-month bond when calculating bond prices. Why did your portfolio value change from before?

- *Note: This question is not asking you to construct a new portfolio. It is asking for the change in market value of the portfolio that you constructed in (1).*
"""

# ╔═╡ dd28225d-bf61-479f-a6be-12a10b5d895a
Foldable("Solution",Markdown.parse("
- Now, 
\$y_1=0.29\\%, y_5=2.0496\\%\$

- The yield curve has become steeper as predicted.

``\$ \\textrm{Portfolio value} = \\frac{1,002,700}{(1.0029)^{\\frac{11}{12}}} - \\frac{217,985.58}{(1.020496)^{4\\frac{11}{12}}} = 802,751.49\$``
- The portfolio value increased by \$ 5,187.19.

- By matching modified durations, the portfolio was hedged (approximately) against level movements in the yield curve.  The yield curve became steeper, so the portfolio value increased.  In addition, both bonds moved one month closer to maturity, which also had an effect on bond prices.
"))

# ╔═╡ 7f65764c-9948-44fe-8dc2-bfc5e296c36b
vspace

# ╔═╡ b0f3e6bd-06cc-4ad9-86a0-0b43d56233a3
md"""
**3.** What would the change in your portfolio value have been if the 1-yr rate had stayed the same and the 5-yr rate had gone down by 125 basis points?
"""

# ╔═╡ 3abc719d-57e3-4167-8ff4-32a9cc97aa39
Foldable("Solution",Markdown.parse("

``\$\\textrm{Portfolio value} = \\frac{1,002,700}{(1.0027)^{\\frac{11}{12}}} - \\frac{217,985.58}{(1.002411)^{4\\frac{11}{12}}} = 784,805.26\$``
- The portfolio value decreased by \$12,759.04
"))

# ╔═╡ dd5f91f6-b0a7-403b-a554-076106f4a365
vspace

# ╔═╡ af4c0216-0d9d-4841-9586-94329d575c64
md"""
# Exercise 5
"""

# ╔═╡ 34a2d854-f8cd-4f4d-9acd-5b1c57aba680
md"""
Suppose that you have a liability of $100 per year in perpetuity and the current interest rate for discounting this perpetuity is 10%. To hedge the value of this perpetuity, you decide to buy a 10-year zero coupon bond (which also has a discount rate of 10%). How much of a 10-year bond do you need to buy?
- Recall that the value of a perpetuity that pays \$1 each period is:

$\text{Value of perpetuity} = \frac{1}{r}$

"""

# ╔═╡ 9eddbe1b-0761-4cb7-b6ba-347af5c41261
Foldable("Solution",md"""
- First, calculate the value of the perpetuity.

$\text{Value of perpetuity} = 100\times \frac{1}{r} = \frac{100}{0.10} = 1000$

- Next, calculate the modified durations:

$MD_{10} = \frac{10}{1.1} = 9.09$

$\text{Value of perpetuity @ 10.1\%} = \frac{100}{0.101} = 990.10$

$\text{Value of perpetuity @ 9.9\%} = \frac{100}{0.099} = 1010.10$

$MD_{perpetuity} \approx -\frac{990.10 - 1010.10}{2\times 0.001}\times \frac{1}{1000}=10$

- Set up a balance sheet

| Assets | Liabilities |
|:-------|------------:|
| 10-yr bond       | Perpetuity  |
| \$x              | Market value = \$1000|
| MD = 9.09        |  MD = 10  |
| $\frac{\Delta P}{P}\approx -9.09 \Delta y$ | $\frac{\Delta P}{P} \approx -10\Delta y$ |
| $x\times(-9.09)\Delta y$ | $(1000)\times(-10)\Delta y$

- Solving for x: $x =$ \$ $1100$.

""")

# ╔═╡ 82e11615-f42a-4020-befe-c5dcee7b3210
vspace

# ╔═╡ d6cd726f-6a99-41ff-a1c4-284f0743186c
md"""
# Exercise 6
"""

# ╔═╡ a219b1a6-715a-4343-a7d3-31e21ef1ddd5
md"""
*One of the more popular strategies in the Fixed Income market is the Butterfly Strategy which constructs a trade that is profitable if the term structure of interest rates moves in parallel. In this problem, you will be asked to construct the right portfolio weights for this trade and to determine the profitability of the  trade.*
"""

# ╔═╡ 09fd333e-973c-493a-9ce0-6b2c1050e326
md"""
- Suppose you observe the following  zero-coupon bond yields in the market.
| Maturity  | Yield |
|:----------|------:|
| 2 years   | 5%    |
| 5 years   | 5%    |
| 10 years  | 5%    |
"""

# ╔═╡ 46f2e317-cde8-47c7-8ff7-a043bd35865c
md"""
The strategy is based on buying the 2-year and 10-year bonds and shorting the 5-year bond. It will end up having a positive convexity. The relative amounts to invest in each bond are given by the two constraints.

1. **It should be (modified) duration neutral.**
  - That is, construct the strategy such that the dollar value of your short position times the modified duration of your short position is equal to the dollar value of your long position times the modified duration of your long position. 
- Thus, it is hedged against small (level) changes in yields. (This is the constraint from a number of the examples given in class.)

2. **It should be “cash neutral”** 
  - That is, the initial value of the short position should equal the initial value of the long position.
"""

# ╔═╡ 76196e8f-c165-4b5a-9a25-3a7862acb254
vspace

# ╔═╡ 029754a7-bdbc-49d5-afbb-10c2733baff6
md"""
**1.** Calculate the modified durations of the 2-year, 5-year, and 10-year bonds.
"""

# ╔═╡ fd371e27-1f66-403b-99f5-c13ade3d989a
Foldable("Solution",md"""
$MD_2 = \frac{2}{1.05} = 1.905$
$MD_5 = \frac{5}{1.05} = 4.762$
$MD_{10} = \frac{10}{1.05} = 9.524$
""")

# ╔═╡ 963c3dc1-4108-41bc-94c6-0a5a9dcb4a78
vspace

# ╔═╡ fa56246e-d9e4-4fc0-af81-eea28958a14c
md"""
**2.** Suppose that you short $1,000 in face value of the 5-year bond. First, calculate the market value of the 5-year bond. Denote x to be the amount (market value) of the 2-year bond that you buy and z the amount (market value) of the 10-year bond you buy. Write down the two equations for the two constraints given above.
"""

# ╔═╡ 720c1612-1801-4aad-a003-7a6710e78992
Foldable("Solution",md"""

$\text{Market value of 5yr} = \frac{1000}{1.05^5} = 783.53$


| Short | Long |          |
|:------|------------------:|-----------------:|
| 5yr   |  2yr            |           10yr    |
|\$783.52 | \$x           |   \$z             |
| MD = 4.762 | MD = 1.905 | MD = 9.524 |

- If yields change by $\Delta y$:
 Short | Long |          |
|:------|------------------:|-----------------:|
| 5yr   |  2yr            |           10yr    |
| $\frac{\Delta P}{P} \approx -4.762\Delta y$ | $\frac{\Delta P}{P} \approx -1.905 \Delta y$ | $\frac{\Delta B}{B} \approx -9.524\Delta y$ | 


- This leads to two equations:
$1.905x + 9.524z = 4.762\times(783.53)$
$x + z = 783.53$

""")

# ╔═╡ c443b2d7-302f-439b-8dd1-21afc81db7f9
vspace

# ╔═╡ d6fdfab2-cfcc-4ee8-be3b-beda3f374b1f
md"""
**3.** Solve the two equations for x and z. These are the market values of the 2-year and 10-year bonds that you buy in this strategy. What are the face values of the 2-year and 10-year bonds that you buy? 
  - Assume for questions (4) and (5) that you have entered into this portfolio.
"""

# ╔═╡ 44d454f9-b6c4-4498-89eb-ce95852ffa50
Foldable("Solution",md"""
$x = 489.70$
$z = 293.82$

- We get $489.70\times(1.05^2) = 539.90$ in face value of 2yr.
- and $293.82\times(1.05^{10}) = 478.61$ in face value of 10yr.

""")

# ╔═╡ ee6d3b50-676e-4f99-a136-d04413a4f4b5
vspace

# ╔═╡ 0f011f1d-a770-4375-a01e-b3b750893d33
md"""
**4.** Suppose that yields move in parallel to 4.75%. What is the profit/loss to your strategy? What about 4.5%? Do this calculation for each 0.25% increment from a yield of 0% to a yield of 10% and plot the profit/loss against the yield. (You will want to use Excel for this.)
"""

# ╔═╡ d63e1c57-650f-422d-a766-e9d9ed767756
Foldable("Solution",md"""
- Note that the initial investment was 0, so the profit/loss is just the value of the overall position.\\

- If yields move to 4.75%: $\frac{539.90}{1.0475^2} + \frac{478.61}{1.0475^{10}} - \frac{1000}{1.0475^5} = 0.03$
- If yields move to 4.5%: $\frac{539.90}{1.045^2} + \frac{478.61}{1.045^{10}} - \frac{1000}{1.045^5} = 0.14$
""")

# ╔═╡ 64cbe47e-28d1-408c-a352-fc720db960a3
Foldable("Graph",LocalResource("butterfly_profit.jpg"))

# ╔═╡ 2dc5dcc9-d76e-42f6-a62d-d08d3ea5f3db
vspace

# ╔═╡ 476658cf-a225-432f-bcbb-36ff4c8a39cb
md"""
**5.** Suppose that instead, the yields move to y2 = 4%, y5 = 5%, and y10 = 7%. What is the profit/loss of your position?
"""

# ╔═╡ dc1a5151-3927-4df5-83cf-d2043fbe4ba9
Foldable("Solution",md"""
$\frac{539.90}{1.04^2} + \frac{478.61}{1.07^{10}} - \frac{1000}{1.05^5} = -41.06$

""")

# ╔═╡ 1b8410fa-9092-420f-92fb-36c21a8be9f6
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
DataFrames = "~1.3.1"
HTTP = "~0.9.17"
HypertextLiteral = "~0.9.3"
LaTeXStrings = "~1.3.0"
Plots = "~1.25.3"
PlutoUI = "~0.7.27"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "76494c3c4a544c292f089e8500c87c723fd32478"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "195c5505521008abea5aee4f96930717958eac6f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.4.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

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
git-tree-sha1 = "e7ff6cadf743c098e08fca25c91103ee4303c9bb"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.6"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

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
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

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

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.Extents]]
git-tree-sha1 = "5e1e4c53fa39afe63a7d356e30452249365fba99"
uuid = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
version = "0.1.1"

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

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "6872f5ec8fd1a38880f027a26739d42dcda6691f"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.2"

[[deps.GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "RelocatableFolders", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "c98aea696662d09e215ef7cda5296024a9646c75"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.64.4"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "bc9f7725571ddb4ab2c4bc74fa397c1c5ad08943"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.69.1+0"

[[deps.GeoInterface]]
deps = ["Extents"]
git-tree-sha1 = "fb28b5dc239d0174d7297310ef7b84a11804dfab"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.0.1"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "GeoInterface", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "fe9aea4ed3ec6afdfbeb5a4f39a2208909b162a6"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.5"

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
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

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

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

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
git-tree-sha1 = "6466e524967496866901a78fca3f2e9ea445a559"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.2"

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
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "5b7690dd212e026bbab1860016a6601cb077ab66"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.2"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "d16070abde61120e01b4f30f6f398496582301d6"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.25.12"

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
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "dc1e451e15d90347a7decc4221842a022b011714"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.5.2"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "cdbd3b1338c72ce29d9584fdbe9e9b70eeb5adca"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "0.1.3"

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

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

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

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "6954a456979f23d05085727adb17c4551c19ecd1"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.12"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

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

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "GPUArraysCore", "StaticArraysCore", "Tables"]
git-tree-sha1 = "b03a3b745aa49b566f128977a7dd1be8711c5e71"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.14"

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
git-tree-sha1 = "34db80951901073501137bdbc3d5a8e7bbd06670"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.1.2"

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
# ╟─41d7b190-2a14-11ec-2469-7977eac40f12
# ╟─731c88b4-7daf-480d-b163-7003a5fbd41f
# ╟─a5de5746-3df0-45b4-a62c-3daf36f015a5
# ╟─8bcc8106-31e8-4212-8f9e-8800e5737b11
# ╟─657e8ee4-5df9-42c1-8639-ba5ab37b51b4
# ╟─af866ea7-e8eb-4774-8d0d-66b4da87a01e
# ╟─be7ce534-0249-42f5-8365-9af47376aa5b
# ╟─8c5d9a78-9040-41fc-94f2-a6aab6da5c6d
# ╟─90f57146-71c8-448e-a644-7039853050c0
# ╟─225cef3a-33eb-4aee-83af-442b441d4adc
# ╟─31be29e2-2457-4ef9-a95f-b2ac742ecd97
# ╟─9ac02b23-b9fe-4061-93ad-bf79d9bd0d01
# ╟─6ae264cd-edc4-4abe-8b1e-9b34f664e314
# ╟─04969d91-8e9b-44b0-8517-60b59c5f2ebe
# ╟─796384ef-7f3d-4423-8748-45a2a892c34b
# ╟─0d010810-a2f9-4f78-a173-abb96eae4ecb
# ╟─2cd77b86-5578-4d2c-9650-c654f0322602
# ╟─96463334-3f79-4086-848e-240b2532e563
# ╟─8b8220f2-bfe4-45d9-968d-ed256a98bf79
# ╟─ab4d9779-a1cf-49b2-87ff-9e4d523ea77f
# ╟─88f518bb-a3be-46e9-95eb-65424dbf0708
# ╟─05b4cca7-e2e0-40e5-a653-0f3a9751e92c
# ╟─7033fc1f-f60b-44dc-8f37-f04adf486857
# ╟─f9fa048e-2a26-48a3-99c2-a107162439e8
# ╟─09fc0f42-fdb2-4a50-88ae-e9c3da739d2f
# ╟─a502041d-58ff-4d3b-b745-231fd6b21ac9
# ╟─f0a85acc-effa-4e3a-95e4-1be30a0b69f0
# ╟─0e211169-0204-4582-936d-feecf2aec3cd
# ╟─f3d6b12c-3d76-4058-a0c9-e8bfc53e2143
# ╟─f8a823ae-1aa1-41c7-b88c-283f541b067d
# ╟─fe0d9d46-2c7f-42ba-bb04-ccb741631e7c
# ╟─020b481e-a212-430f-9744-b369d23bab74
# ╟─c6ea0fc5-80ea-4f99-8426-590ed5917b66
# ╟─f8582e96-7877-439b-870b-b68a551411f7
# ╟─7c22ab3a-6678-4e50-b417-8a51f36e4917
# ╟─1fdd2193-0519-49ea-b57c-e94726de49f3
# ╟─c4a0dba8-f203-47e7-9625-7a71238790d0
# ╟─16a07c05-9982-4305-b8ec-eac332fa7774
# ╟─83688847-afb0-44b9-a004-3a978f19dbc9
# ╟─abd91e21-32d1-4d65-b535-1f241e0346c2
# ╟─be90841e-c3eb-407b-8f6a-307c16ea49a8
# ╟─8c51274f-6bf0-4130-9671-aebd7d06a4b6
# ╟─25a391f9-505d-4d00-8408-0bfbb6745c6a
# ╟─266cb4ca-3fbe-4929-8d6b-ff9b6202a4e2
# ╟─fa6da482-6110-4cbb-91c0-39131115b9e4
# ╟─6ae76da9-f233-4deb-b35b-53c9597b3b9f
# ╟─8090852b-068d-408e-bc9e-6802e61df5ad
# ╟─2f360a18-76f1-48ba-9c7a-43ced4ec2fc7
# ╟─dd28225d-bf61-479f-a6be-12a10b5d895a
# ╟─7f65764c-9948-44fe-8dc2-bfc5e296c36b
# ╟─b0f3e6bd-06cc-4ad9-86a0-0b43d56233a3
# ╟─3abc719d-57e3-4167-8ff4-32a9cc97aa39
# ╟─dd5f91f6-b0a7-403b-a554-076106f4a365
# ╟─af4c0216-0d9d-4841-9586-94329d575c64
# ╟─34a2d854-f8cd-4f4d-9acd-5b1c57aba680
# ╟─9eddbe1b-0761-4cb7-b6ba-347af5c41261
# ╟─82e11615-f42a-4020-befe-c5dcee7b3210
# ╟─d6cd726f-6a99-41ff-a1c4-284f0743186c
# ╟─a219b1a6-715a-4343-a7d3-31e21ef1ddd5
# ╟─09fd333e-973c-493a-9ce0-6b2c1050e326
# ╟─46f2e317-cde8-47c7-8ff7-a043bd35865c
# ╟─76196e8f-c165-4b5a-9a25-3a7862acb254
# ╟─029754a7-bdbc-49d5-afbb-10c2733baff6
# ╟─fd371e27-1f66-403b-99f5-c13ade3d989a
# ╟─963c3dc1-4108-41bc-94c6-0a5a9dcb4a78
# ╟─fa56246e-d9e4-4fc0-af81-eea28958a14c
# ╟─720c1612-1801-4aad-a003-7a6710e78992
# ╟─c443b2d7-302f-439b-8dd1-21afc81db7f9
# ╟─d6fdfab2-cfcc-4ee8-be3b-beda3f374b1f
# ╟─44d454f9-b6c4-4498-89eb-ce95852ffa50
# ╟─ee6d3b50-676e-4f99-a136-d04413a4f4b5
# ╟─0f011f1d-a770-4375-a01e-b3b750893d33
# ╟─d63e1c57-650f-422d-a766-e9d9ed767756
# ╟─64cbe47e-28d1-408c-a352-fc720db960a3
# ╟─2dc5dcc9-d76e-42f6-a62d-d08d3ea5f3db
# ╟─476658cf-a225-432f-bcbb-36ff4c8a39cb
# ╟─dc1a5151-3927-4df5-83cf-d2043fbe4ba9
# ╟─1b8410fa-9092-420f-92fb-36c21a8be9f6
# ╟─9dba51e3-0738-40a1-96d8-f5583cdc5729
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
